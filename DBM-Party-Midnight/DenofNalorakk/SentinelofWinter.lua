local mod	= DBM:NewMod(2777, "DBM-Party-Midnight", 5, 1311)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(244100)
mod:SetEncounterID(3208)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2825)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

local specWarnGlacialTorment			= mod:NewSpecialWarningCount(1235548, "Healer", nil, nil, 2, 3, nil, nil, "helpdispel")
local specWarnRagingSquall				= mod:NewSpecialWarningCount(1235623, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnShatteringFrostspike		= mod:NewSpecialWarningCount(1235783, nil, nil, nil, 2, 1, nil, nil, "mobsoon")
local specWarnFrozenTempest				= mod:NewSpecialWarningCount(1235656, nil, nil, nil, 2, 3, nil, nil, "pushbackincoming")

local timerGlacialTormentCD				= mod:NewCDCountTimer(20.5, 1235548, nil, nil, nil, 5)
local timerRagingSquallCD				= mod:NewCDCountTimer(20.5, 1235623, nil, nil, nil, 3)
local timerShatteringFrostspikeCD		= mod:NewCDCountTimer(20.5, 1235783, nil, nil, nil, 1)
local timerFrozenTempestCD				= mod:NewCDCountTimer(20.5, 1235656, nil, nil, nil, 2)

--Custom Aura Sounds
mod:AddAuraSoundOption(1235641, true, 1235641, 1, 2, "watchfeet", 8)--Raging Squall

mod.vb.tormentCount = 0
mod.vb.squallCount = 0
mod.vb.frostspikeCount = 0
mod.vb.tempestCount = 0
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsHealer() then
			specWarnGlacialTorment:SetAlert(67, "helpdispel", 2, 3)
		end
		specWarnRagingSquall:SetAlert(68, "watchstep", 2, 2)
		specWarnShatteringFrostspike:SetAlert(69, "mobsoon", 2, 1)
		specWarnFrozenTempest:SetAlert(70, "pushbackincoming", 13, 3)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerGlacialTormentCD:SetTimeline(67, onlyColor)
	timerRagingSquallCD:SetTimeline(68, onlyColor)
	timerShatteringFrostspikeCD:SetTimeline(69, onlyColor)
	timerFrozenTempestCD:SetTimeline(70, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.tormentCount = 1
	self.vb.squallCount = 1
	self.vb.frostspikeCount = 1
	self.vb.tempestCount = 1
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
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		if timer == 61 or timer == 63 then--Long placeholder bars are canceled during the recurring reset
			return true
		elseif timer == 7 then
			timerGlacialTormentCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "torment", "tormentCount"))
			return true
		elseif timer == 13 then
			timerRagingSquallCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "squall", "squallCount"))
			return true
		elseif timer == 25 then
			timerShatteringFrostspikeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "frostspike", "frostspikeCount"))
			return true
		elseif timer == 50 then
			timerFrozenTempestCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "tempest", "tempestCount"))
			return true
		end
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
				if eventType == "torment" and self:IsHealer() then
					specWarnGlacialTorment:Show(eventCount)
					specWarnGlacialTorment:Play("helpdispel")
				elseif eventType == "squall" then
					specWarnRagingSquall:Show(eventCount)
					specWarnRagingSquall:Play("watchstep")
				elseif eventType == "frostspike" then
					specWarnShatteringFrostspike:Show(eventCount)
					specWarnShatteringFrostspike:Play("mobsoon")
				elseif eventType == "tempest" then
					specWarnFrozenTempest:Show(eventCount)
					specWarnFrozenTempest:Play("pushbackincoming")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
