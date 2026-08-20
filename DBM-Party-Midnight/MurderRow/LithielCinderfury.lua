local mod	= DBM:NewMod(2682, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(237415)
mod:SetEncounterID(3105)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--TODO, add https://www.wowhead.com/beta/spell=1218203/fingers-of-guldan if it's targeting private aura
--NOTE, need to find private aura for Infernal Fixate
--NOTE, https://www.wowhead.com/beta/spell=1217262/seed-of-corruption has a private aura but not in journal
local specWarnFingersofGuldan				= mod:NewSpecialWarningCount(1218203, nil, nil, nil, 2, 2, nil, nil, "range5")
local specWarnSummonVilefiend				= mod:NewSpecialWarningCount(474408, nil, nil, nil, 1, 2, nil, nil, "bigmob")
local specWarnMaleficWave					= mod:NewSpecialWarningCount(1224478, nil, nil, nil, 2, 2, nil, nil, "usegate")

local timerFingersofGuldanCD				= mod:NewCDCountTimer(20.5, 1218203, nil, nil, nil, 1)
local timerSummonVilefiendCD				= mod:NewCDCountTimer(20.5, 474408, nil, nil, nil, 1)
local timerMaleficWaveCD					= mod:NewCDCountTimer(20.5, 1224478, nil, nil, nil, 2)

mod.vb.fingersCount = 0
mod.vb.vilefiendCount = 0
mod.vb.waveCount = 0
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnFingersofGuldan:SetAlert(37, "range5", 2, 2)
		specWarnSummonVilefiend:SetAlert(38, "bigmob", 1, 2)
		specWarnMaleficWave:SetAlert(207, "usegate", 19, 2)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerFingersofGuldanCD:SetTimeline(37, onlyColor)
	timerSummonVilefiendCD:SetTimeline(38, onlyColor)
	timerMaleficWaveCD:SetTimeline(207, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.fingersCount = 1
	self.vb.vilefiendCount = 1
	self.vb.waveCount = 1
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
		if timer == 10 or timer == 57 then
			timerSummonVilefiendCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "vilefiend", "vilefiendCount"))
			return true
		elseif timer == 15 or timer == 55 then
			timerFingersofGuldanCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fingers", "fingersCount"))
			return true
		elseif timer == 24 or timer == 59 then
			--Blizzards timer is actually a bit more variable with confirmedd 57.3-59 range
			timerMaleficWaveCD:TLStart(timer == 59 and "v57.3-59" or timerExact, eventID, self:TLCountStart(eventID, "wave", "waveCount"))
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
				if eventType == "fingers" then
					specWarnFingersofGuldan:Show(eventCount)
					specWarnFingersofGuldan:Play("range5")
				elseif eventType == "vilefiend" then
					specWarnSummonVilefiend:Show(eventCount)
					specWarnSummonVilefiend:Play("bigmob")
				elseif eventType == "wave" then
					specWarnMaleficWave:Show(eventCount)
					specWarnMaleficWave:Play("usegate")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
