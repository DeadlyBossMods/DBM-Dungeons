local mod	= DBM:NewMod(2679, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(252458)
mod:SetEncounterID(3101)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--NOTE: Chaos Barrage has no event ID, but some wierd spell called "escape" (https://www.wowhead.com/spell=1248184/escape) does
local specWarnMirrorImages					= mod:NewSpecialWarningCount(1264095, nil, nil, nil, 1, 2, nil, nil, "crowdcontrol")
local specWarnFelSpray						= mod:NewSpecialWarningBlizzTarget(1253811, nil, nil, nil, 2, 2, nil, nil, "frontal")
local specWarnFelNova						= mod:NewSpecialWarningCount(474240, nil, nil, nil, 2, 3, nil, nil, "watchstep")

local timerMirrorImagesCD					= mod:NewCDCountTimer(20.5, 1264095, nil, nil, nil, 1)
local timerFelSprayCD						= mod:NewCDCountTimer(20.5, 1253811, nil, nil, nil, 3)
local timerFelNovaCD						= mod:NewCDCountTimer(20.5, 474240, nil, nil, nil, 3)

--Light Infusion has no routeable timeline event and is handled by ENCOUNTER_WARNING.
mod:AddCustomAlertSoundOption(1230304, true, 2)--Light Infusion; no timeline timer
--Custom Aura Sounds
mod:AddAuraSoundOption(1253813, true, 1253813, 1, 2, "watchfeet", 8)--Fel Spray

mod.vb.mirrorImagesCount = 0
mod.vb.felSprayCount = 0
mod.vb.felNovaCount = 0
local badStateDetected = false
local batchTimerValues = {
	[8] = true,
	[12] = true,
	[15] = true,
	[28] = true,
	[30] = true,
}

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnMirrorImages:SetAlert(120, "crowdcontrol", 3, 2)
		specWarnFelSpray:SetAlert(122, "frontal", 15, 2)
		specWarnFelNova:SetAlert(202, "watchstep", 2, 3)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerMirrorImagesCD:SetTimeline(120, onlyColor)
	timerFelSprayCD:SetTimeline(122, onlyColor)
	timerFelNovaCD:SetTimeline(202, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self:TLBatchReset()
	self.vb.mirrorImagesCount = 1
	self.vb.felSprayCount = 1
	self.vb.felNovaCount = 1
	--Light Infusion is ENCOUNTER_WARNING-only, so retain its Blizzard alert in hardcoded timer mode.
	self:EnableAlertOptions(1230304, 610, "targetchange", 2, 1, 0)--No timer, text warning only, override sound type 0
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
	self:TLBatchReset()
	self:UnregisterShortTermEvents()
end

do
	local function timersAll(self, timer, timerExact, eventID)
		if timer == 8 or timer == 28 then
			self:TLBatchStart(timer, timerFelSprayCD, timerExact, eventID, "felSpray", "felSprayCount", batchTimerValues)
		elseif timer == 15 or timer == 30 then
			self:TLBatchStart(timer, timerMirrorImagesCD, timerExact, eventID, "mirrorImages", "mirrorImagesCount", batchTimerValues)
		elseif timer == 12 then
			self:TLBatchStart(timer, timerFelNovaCD, timerExact, eventID, "felNova", "felNovaCount", batchTimerValues)
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
		if not timersAll(self, math.floor(timerExact + 0.5), timerExact, eventID) and not badStateDetected then
			badStateDetected = true
			self:ResumeBlizzardAPI()
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		if not eventID then return end
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		self:TLBatchUntrack(eventID)
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "felSpray" then
					specWarnFelSpray:Show(eventCount, "frontal")
				elseif eventType == "mirrorImages" then
					specWarnMirrorImages:Show(eventCount)
					specWarnMirrorImages:Play("crowdcontrol")
				elseif eventType == "felNova" then
					specWarnFelNova:Show(eventCount)
					specWarnFelNova:Play("watchstep")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
