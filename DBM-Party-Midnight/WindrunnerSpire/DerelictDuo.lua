local mod	= DBM:NewMod(2656, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231626)--Kalis flagged as main boss, Latch (231629) is secondary
mod:SetEncounterID(3057)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--NOTE: Heaving Yank happens at same time as Shriek and doesn't need it's own timer/warnings
local warnSplatteringSpew			= mod:NewCountAnnounce(472745, 2)

local specWarnHeavingYank			= mod:NewSpecialWarningBlizzYou(472793, nil, nil, nil, 3, 2)
local specWarnBoneHack				= mod:NewSpecialWarningCount(472888, nil, nil, nil, 1, 2)
local specWarnDebilitatingShriek	= mod:NewSpecialWarningCount(472736, nil, nil, nil, 2, 2)
local specWarnCurseofDarkness		= mod:NewSpecialWarningCount(474105, nil, nil, nil, 2, 2)

local timerBoneHackCD				= mod:NewCDCountTimer(17.3, 472888, nil, "Tank", nil, 2, nil, DBM_COMMON_L.TANK_ICON)
local timerCurseofDarknessCD		= mod:NewCDCountTimer(22.7, 474105, nil, nil, 2, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerDebilitatingShriekCD		= mod:NewCDCountTimer(48, 472736, nil, nil, nil, 2, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerSplatteringSpewCD		= mod:NewCDCountTimer(27.3, 472777, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption({1253834,1215803}, true, 474105, 4, 1, "justrun", 2)--Curse of Darkness
--mod:AddPrivateAuraSoundOption(472793, true, 472795, 1, 1, "behindboss", 2)--Heaving Yank
mod:AddPrivateAuraSoundOption(474129, true, 472745, 1, 1, "poolyou", 18)--Splattering Spew
mod:AddPrivateAuraSoundOption(472777, true, 472777, 4, 2, "watchfeet", 8)--Gunk Splatter GTFO

mod.vb.boneHackCount = 0
mod.vb.curseofDarknessCount = 0
mod.vb.debilitatingShriekCount = 0
mod.vb.splatteringSpewCount = 0

local badStateDetected = false
local activeEventTypes = {}
local shriekTiming = {}

---@param self DBMMod
---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnBoneHack:SetAlert(25, "defensive", 2)
		end
		specWarnCurseofDarkness:SetAlert(26, "mobsoon", 2)
		specWarnDebilitatingShriek:SetAlert(27, "aesoon", 2)
		specWarnHeavingYank:SetAlert(29, "behindboss", 2, 4, 0)
	end
	timerBoneHackCD:SetTimeline(25)
	timerCurseofDarknessCD:SetTimeline(26)
	timerDebilitatingShriekCD:SetTimeline(27)
	timerSplatteringSpewCD:SetTimeline(28)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.boneHackCount = 1
	self.vb.curseofDarknessCount = 1
	self.vb.debilitatingShriekCount = 1
	self.vb.splatteringSpewCount = 1
	badStateDetected = false
	activeEventTypes = {}
	shriekTiming = {}
	if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
		--SetTimeline events since user has disabled DBM Bars (so they can still get countdowns in blizzard timeline API instead)
		if DBM.Options.HideDBMBars then
			setFallback(self, true)
		end
	else
		setFallback(self)
	end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	activeEventTypes = {}
	shriekTiming = {}
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		--Logic confirmed against M+ pull logs only.
		if timer == 8 or timer == 27 then--Splattering Spew alternates 8.0 / 27.333
			activeEventTypes[eventID] = "splatteringSpew"
			timerSplatteringSpewCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "splatteringSpew", "splatteringSpewCount"))
		elseif timer == 17 then--Bone Hack at 17.333
			activeEventTypes[eventID] = "boneHack"
			timerBoneHackCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "boneHack", "boneHackCount"))
		elseif timer == 23 then--Curse of Darkness at 22.666
			activeEventTypes[eventID] = "curseofDarkness"
			timerCurseofDarknessCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "curseofDarkness", "curseofDarknessCount"))
		elseif timer == 48 then--Debilitating Shriek; successful cast resolves as state 3 when the cooldown expires
			activeEventTypes[eventID] = "debilitatingShriek"
			local shriekCount = self:TLCountStart(eventID, "debilitatingShriek", "debilitatingShriekCount")
			timerDebilitatingShriekCD:TLStart(timerExact, eventID, shriekCount)
			shriekTiming[eventID] = {
				startTime = GetTime(),
				duration = timerExact
			}
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
		if eventState == 2 then
			activeEventTypes[eventID] = nil
			shriekTiming[eventID] = nil
			local finishedEventType, eventCount = self:TLCountFinish(eventID)
			if finishedEventType and eventCount then
				if finishedEventType == "splatteringSpew" then
					warnSplatteringSpew:Show(eventCount)
				elseif finishedEventType == "boneHack" then
					if self:IsTank() then
						specWarnBoneHack:Show(eventCount)
						specWarnBoneHack:Play("defensive")
					end
				elseif finishedEventType == "curseofDarkness" then
					specWarnCurseofDarkness:Show(eventCount)
					specWarnCurseofDarkness:Play("mobsoon")
				end
			end
		elseif eventState == 3 then
			if eventType == "debilitatingShriek" then
				local timing = shriekTiming[eventID]
				local elapsed = timing and (GetTime() - timing.startTime) or 0
				local duration = timing and timing.duration or 0
				activeEventTypes[eventID] = nil
				shriekTiming[eventID] = nil
				if timing and math.abs(elapsed - duration) <= 1.0 then
					local finishedEventType, eventCount = self:TLCountFinish(eventID)
					if finishedEventType == "debilitatingShriek" and eventCount then
						specWarnDebilitatingShriek:Show(eventCount)
						specWarnDebilitatingShriek:Play("aesoon")
						specWarnHeavingYank:Show(eventCount, "behindboss")
					end
				else
					self:TLCountCancel(eventID)
				end
			else
				activeEventTypes[eventID] = nil
				shriekTiming[eventID] = nil
				self:TLCountCancel(eventID)
			end
		end
	end
end
