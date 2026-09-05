local mod	= DBM:NewMod(2776, "DBM-Party-Midnight", 5, 1311)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248710)
mod:SetEncounterID(3207)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2825)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

DBM:RegisterAltSpellName(1253268, DBM_COMMON_L.FRONTAL)--Earthshatter Slam --> Frontal
DBM:RegisterAltSpellName(1234233, DBM_COMMON_L.GROUPSOAKS)--Spoiled Supplies --> Soaks
DBM:RegisterAltSpellName(1235118, DBM_COMMON_L.AOEDAMAGE)--Ravenous Bellow --> AoE
local specWarnSpoiledSupplies				= mod:NewSpecialWarningCount(1234233, nil, nil, nil, 2, 2, nil, nil, "greenmushroomcoming")
local specWarnEarthshatterSlam				= mod:NewSpecialWarningCount(1253268, nil, nil, nil, 2, 2, nil, nil, "frontal")
local specWarnRavenousBellow				= mod:NewSpecialWarningCount(1235118, nil, nil, nil, 2, 2, nil, nil, "aesoon")

local timerSpoiledSuppliesCD				= mod:NewCDCountTimer(20.5, 1234233, nil, nil, nil, 5)
local timerEarthshatterSlamCD				= mod:NewCDCountTimer(20.5, 1253268, nil, nil, nil, 3)
local timerRavenousBellowCD					= mod:NewCDCountTimer(20.5, 1235118, nil, nil, nil, 2)

--Custom Aura Sounds
mod:AddAuraSoundOption(1235405, true, 1235405, 1, 2, "watchfeet", 8)--Bonespiked
--mod:AddAuraSoundOption(1234846, false, 1234846, 1, 1, "toxic", 2)--Toxic Spores (off by default, i don't think it needs a sound, since we can't alert stacks, the PA anchor will handle it

mod.vb.suppliesCount = 0
mod.vb.slamCount = 0
mod.vb.bellowCount = 0
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnSpoiledSupplies:SetAlert(86, "greenmushroomcoming", 12, 2)
		specWarnEarthshatterSlam:SetAlert(87, "frontal", 15, 2)
		specWarnRavenousBellow:SetAlert(88, "aesoon", 2, 2)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerSpoiledSuppliesCD:SetTimeline(86, onlyColor)
	timerEarthshatterSlamCD:SetTimeline(87, onlyColor)
	timerRavenousBellowCD:SetTimeline(88, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.suppliesCount = 1
	self.vb.slamCount = 1
	self.vb.bellowCount = 1
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
		if timer == 99 then--Long placeholder bars are canceled during the recurring reset
			return true
		elseif timer == 30 then
			timerSpoiledSuppliesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "supplies", "suppliesCount"))
			return true
		elseif timer == 16 then
			timerEarthshatterSlamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "slam", "slamCount"))
			return true
		elseif timer == 6 then
			timerRavenousBellowCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bellow", "bellowCount"))
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
				if eventType == "supplies" then
					specWarnSpoiledSupplies:Show(eventCount)
					specWarnSpoiledSupplies:Play("greenmushroomcoming")
				elseif eventType == "slam" then
					specWarnEarthshatterSlam:Show(eventCount)
					specWarnEarthshatterSlam:Play("frontal")
				elseif eventType == "bellow" then
					specWarnRavenousBellow:Show(eventCount)
					specWarnRavenousBellow:Play("aesoon")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
