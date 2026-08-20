local mod	= DBM:NewMod(2793, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248015)
mod:SetEncounterID(3287)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--TODO, void cascade has two private auras, but neitehr appear to be pre target aura and rather ones you just get if in beam
local specWarnUnstableSingularity			= mod:NewSpecialWarningCount(1282770, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnCosmicCrash					= mod:NewSpecialWarningCount(1227264, nil, nil, nil, 2, 2, nil, nil, "scatter")
local specWarnGraviticOrbs					= mod:NewSpecialWarningCount(1263982, nil, nil, nil, 2, 2, nil, nil, "specialsoon")
local specWarnVoidCascade					= mod:NewSpecialWarningCount(1222758, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnDarkWaves						= mod:NewSpecialWarningCount(1311923, nil, nil, nil, 2, 2, nil, nil, "specialsoon")

local timerUnstableSingularityCD			= mod:NewCDCountTimer(20.5, 1282770, nil, nil, nil, 3)
local timerCosmicCrashCD					= mod:NewCDCountTimer(20.5, 1227264, nil, nil, nil, 2)
local timerGraviticOrbsCD					= mod:NewCDCountTimer(20.5, 1263982, nil, nil, nil, 3)
local timerVoidCascadeCD					= mod:NewCDCountTimer(20.5, 1222758, nil, nil, nil, 3)
local timerDarkWavesCD						= mod:NewCDCountTimer(20.5, 1311923, nil, nil, nil, 5)
--Custom Aura Sounds
mod:AddAuraSoundOption(1263983, true, 1263982, 4, 1, "orbrun", 2)--Condensed Mass
mod:AddAuraSoundOption(1282770, true, 1282770, 1, 1, "runout", 2)--Unstable Singularity Pre debuff
mod:AddAuraSoundOption(1248130, true, 1282770, 1, 2, "watchfeet", 8)--GTFO

mod.vb.singularityCount = 0
mod.vb.crashCount = 0
mod.vb.orbsCount = 0
mod.vb.cascadeCount = 0
mod.vb.wavesCount = 0
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnUnstableSingularity:SetAlert(56, "watchstep", 2, 2)
		specWarnCosmicCrash:SetAlert(57, "carefly", 2, 2)
		specWarnGraviticOrbs:SetAlert(58, "specialsoon", 2, 2, 0)
		specWarnVoidCascade:SetAlert(171, "watchstep", 2, 2)
		specWarnDarkWaves:SetAlert(961, "specialsoon", 2, 2, 0)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerUnstableSingularityCD:SetTimeline(56, onlyColor)
	timerCosmicCrashCD:SetTimeline(57, onlyColor)
	timerGraviticOrbsCD:SetTimeline(58, onlyColor)
	timerVoidCascadeCD:SetTimeline(171, onlyColor)
	timerDarkWavesCD:SetTimeline(961, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.singularityCount = 1
	self.vb.crashCount = 1
	self.vb.orbsCount = 1
	self.vb.cascadeCount = 1
	self.vb.wavesCount = 1
	if DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents("ENCOUNTER_TIMELINE_EVENT_ADDED", "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
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
	local function timersAll(self, timer, timerExact, eventID)
		if timer == 5 then
			timerUnstableSingularityCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "singularity", "singularityCount"))
		elseif timer == 17 then
			timerCosmicCrashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "crash", "crashCount"))
		elseif timer == 28 then
			timerGraviticOrbsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "orbs", "orbsCount"))
		elseif timer == 34 then
			timerDarkWavesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "waves", "wavesCount"))
		elseif timer == 43 then
			timerVoidCascadeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "cascade", "cascadeCount"))
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
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "singularity" then
					specWarnUnstableSingularity:Show(eventCount)
					specWarnUnstableSingularity:Play("watchstep")
				elseif eventType == "crash" then
					specWarnCosmicCrash:Show(eventCount)
					specWarnCosmicCrash:Play("carefly")
				elseif eventType == "orbs" then
					specWarnGraviticOrbs:Show(eventCount)
					specWarnGraviticOrbs:Play("specialsoon")
				elseif eventType == "waves" then
					specWarnDarkWaves:Show(eventCount)
					specWarnDarkWaves:Play("specialsoon")
				elseif eventType == "cascade" then
					specWarnVoidCascade:Show(eventCount)
					specWarnVoidCascade:Play("watchstep")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
