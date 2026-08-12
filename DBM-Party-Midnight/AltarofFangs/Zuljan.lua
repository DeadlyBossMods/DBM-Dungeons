local mod	= DBM:NewMod(2880, "DBM-Party-Midnight", 9, 1322)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(231631)
mod:SetEncounterID(3458)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2993)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--local warnRecklessLeap			= mod:NewCountAnnounce(1283247, 2)

local specWarnBoneslicer			= mod:NewSpecialWarningCount(1301413, nil, nil, nil, 2, 2, nil, nil, "farfromline")
local specWarnRitualoftheFang		= mod:NewSpecialWarningSoakCount(1300876, nil, nil, nil, 2, 17, nil, nil, "soakbeam")
local specWarnAxegrinder			= mod:NewSpecialWarningCount(1301111, nil, nil, nil, 2, 3, nil, nil, "watchstep")
local specWarnChopDown				= mod:NewSpecialWarningDefensive(1301350, nil, nil, nil, 1, 3, nil, nil, "defensive")

local timerBoneslicerCD				= mod:NewCDCountTimer(8, 1301413, nil, nil, nil, 3)
local timerRitualoftheFangCD		= mod:NewCDCountTimer(8, 1300876, nil, nil, nil, 5)
local timerAxegrinderCD				= mod:NewCDCountTimer(8, 1301111, nil, nil, nil, 3)
local timerChopDownCD				= mod:NewCDCountTimer(8, 1301350, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--mod:AddAuraSoundOption(470966, true, 470966, 4, 1, "justrun", 2)

local badStateDetected = false
local nextFourteenIsAxegrinder = true
mod.vb.BoneslicerCount = 0
mod.vb.RitualoftheFangCount = 0
mod.vb.AxegrinderCount = 0
mod.vb.ChopDownCount = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnChopDown:SetAlert(824, "defensive", 2)
		end
		specWarnBoneslicer:SetAlert(821, "farfromline", 2, 3)
		specWarnRitualoftheFang:SetAlert(822, "soakbeam", 17, 3)
		specWarnAxegrinder:SetAlert(823, "watchstep", 2, 3)
	end
	--If user has DBM bars enabled, we only want to register colors to the blizz api so that the blizz bars are also colorized.
	--If user has bars disabled, or we are in a bad state, onlyColor is false and we register countdowns as well.
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerBoneslicerCD:SetTimeline(821, onlyColor)
	timerRitualoftheFangCD:SetTimeline(822, onlyColor)
	timerAxegrinderCD:SetTimeline(823, onlyColor)
	timerChopDownCD:SetTimeline(824, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	badStateDetected = false
	self.vb.BoneslicerCount = 1
	self.vb.RitualoftheFangCount = 1
	self.vb.AxegrinderCount = 1
	self.vb.ChopDownCount = 1
	nextFourteenIsAxegrinder = true
	if DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
		setFallback(self, true)
	else
		setFallback(self)
	end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	nextFourteenIsAxegrinder = true
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		--Confirmed against M+ PTR log. Each 64-second cycle has Axegrinder followed by Boneslicer at duration 14.
		if timer == 14 then
			if nextFourteenIsAxegrinder then
				nextFourteenIsAxegrinder = false
				timerAxegrinderCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "axegrinder", "AxegrinderCount"))
			else
				nextFourteenIsAxegrinder = true
				timerBoneslicerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "boneslicer", "BoneslicerCount"))
			end
		elseif timer == 26 or timer == 30 then
			timerChopDownCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "chopDown", "ChopDownCount"))
		elseif timer == 32 then
			timerBoneslicerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "boneslicer", "BoneslicerCount"))
		elseif timer == 64 then
			timerRitualoftheFangCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "ritualoftheFang", "RitualoftheFangCount"))
		else
			return
		end
		return true
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 then return end
		local eventID = eventInfo.id
		if C_EncounterTimeline.GetEventState(eventID) ~= 0 then return end
		local timerExact = eventInfo.duration
		local handled = timersAll(self, math.floor(timerExact + 0.5), timerExact, eventID)
		if not handled and not badStateDetected then
			badStateDetected = true
			self:ResumeBlizzardAPI()
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventID or not eventState then return end
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "boneslicer" then
					specWarnBoneslicer:Show(eventCount)
					specWarnBoneslicer:Play("farfromline")
				elseif eventType == "ritualoftheFang" then
					specWarnRitualoftheFang:Show(eventCount)
					specWarnRitualoftheFang:Play("soakbeam")
				elseif eventType == "axegrinder" then
					specWarnAxegrinder:Show(eventCount)
					specWarnAxegrinder:Play("watchstep")
				elseif eventType == "chopDown" and self:IsTanking("player", "boss1", nil, true) then
					specWarnChopDown:Show()
					specWarnChopDown:Play("defensive")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
