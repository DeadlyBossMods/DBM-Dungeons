local mod	= DBM:NewMod(2657, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231631)
mod:SetEncounterID(3058)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnRecklessLeap				= mod:NewCountAnnounce(1283247, 2)
local warnBladestorm				= mod:NewCountAnnounce(470966, 2, nil, false)

local specWarnRampage				= mod:NewSpecialWarningCount(467620, nil, nil, nil, 1, 2)
local specWarnIntimidatingShout		= mod:NewSpecialWarningCount(1253026, nil, nil, nil, 2, 2)
local specWarnRallyingBellow		= mod:NewSpecialWarningSwitchCount(472043, nil, nil, DBM_COMMON_L.ADDS, 2, 3)

local timerRampageCD				= mod:NewCDCountTimer(30, 467620, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerIntimidatingShoutCD		= mod:NewCDCountTimer(45, 1253026, nil, nil, nil, 2, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerRecklessLeapCD			= mod:NewCDCountTimer(37, 1283247, nil, nil, nil, 3)
local timerBladestormCD				= mod:NewCDCountTimer(8, 470966, nil, nil, nil, 2)

mod:AddPrivateAuraSoundOption(470966, true, 470966, 4, 1, "justrun", 2)--Bladestorm target
mod:AddPrivateAuraSoundOption(468924, true, 470966, 1, 2, "watchfeet", 8)--Bladestorm GTFO
mod:AddPrivateAuraSoundOption(1283247, true, 1283247, 1, 1, "runout", 2)--Reckless Leap target

mod.vb.rampageCount = 0
mod.vb.intimidatingShoutCount = 0
mod.vb.recklessLeapCount = 0
mod.vb.bladestormCount = 0
mod.vb.rallyingBellowCount = 0

local badStateDetected = false
local activeEventTypes = {}
local lastRallyingBellow = 0

---@param self DBMMod
local function setFallback(self)
	if self:IsTank() then
		specWarnRampage:SetAlert({210, 556}, "defensive", 2)
	end
	specWarnIntimidatingShout:SetAlert({211, 213}, "gathershare", 2)
	specWarnRallyingBellow:SetAlert(215, "mobsoon", 2, 3, 0)
	timerRampageCD:SetTimeline({210, 556})
	timerIntimidatingShoutCD:SetTimeline({211, 213})
	timerRecklessLeapCD:SetTimeline({212, 214})
	timerBladestormCD:SetTimeline(216)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.rampageCount = 1
	self.vb.intimidatingShoutCount = 1
	self.vb.recklessLeapCount = 1
	self.vb.bladestormCount = 1
	self.vb.rallyingBellowCount = 0
	badStateDetected = false
	activeEventTypes = {}
	lastRallyingBellow = 0
	if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
	else
		setFallback(self)
	end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	activeEventTypes = {}
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		--Confirmed against logged M+ pulls.
		--This fight emits >900 second placeholder bars after real casts; ignore them in hardcode.
		if timer > 900 then
			return
		elseif timerExact < 1 then
			--Bladestorm startup artifacts show up as 0.001s events before the real 8s cadence.
			return
		elseif timer == 3 or timer == 30 then
			activeEventTypes[eventID] = "rampage"
			timerRampageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "rampage", "rampageCount"))
		elseif timer == 18 or timer == 45 then
			activeEventTypes[eventID] = "intimidatingShout"
			timerIntimidatingShoutCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "intimidatingShout", "intimidatingShoutCount"))
		elseif timer == 10 or timer == 37 then
			activeEventTypes[eventID] = "recklessLeap"
			timerRecklessLeapCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "recklessLeap", "recklessLeapCount"))
		elseif timer == 8 then
			activeEventTypes[eventID] = "bladestorm"
			timerBladestormCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bladestorm", "bladestormCount"))
		else
			badStateDetected = true
			self:ResumeBlizzardAPI()
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 then return end
		local eventID = eventInfo.id
		local timerExact = eventInfo.duration
		local timer = math.floor(timerExact + 0.5)
		if not badStateDetected then
			timersAll(self, timer, timerExact, eventID)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventID or not eventState then return end
		local eventType = activeEventTypes[eventID]
		if eventState == 1 then
			if eventType and eventType ~= "bladestorm" and GetTime() - lastRallyingBellow > 5 then
				lastRallyingBellow = GetTime()
				self.vb.rallyingBellowCount = self.vb.rallyingBellowCount + 1
				specWarnRallyingBellow:Show(self.vb.rallyingBellowCount)
				specWarnRallyingBellow:Play("mobsoon")
				--Bladestorm always begins 4 seconds after rally
				timerBladestormCD:Start(4, self.vb.bladestormCount)
			end
		elseif eventState == 2 then
			activeEventTypes[eventID] = nil
			local finishedEventType, eventCount = self:TLCountFinish(eventID)
			if finishedEventType and eventCount then
				if finishedEventType == "rampage" then
					if self:IsTank() then
						specWarnRampage:Show(eventCount)
						specWarnRampage:Play("defensive")
					end
				elseif finishedEventType == "intimidatingShout" then
					specWarnIntimidatingShout:Show(eventCount)
					specWarnIntimidatingShout:Play("gathershare")
				elseif finishedEventType == "recklessLeap" then
					warnRecklessLeap:Show(eventCount)
				elseif finishedEventType == "bladestorm" then
					warnBladestorm:Show(eventCount)
				end
			end
		elseif eventState == 3 then
			activeEventTypes[eventID] = nil
			self:TLCountCancel(eventID)
		end
	end
end
