local mod	= DBM:NewMod(2769, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(243028)--Meittik only one reported as a main boss
mod:SetEncounterID(3199)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

DBM:RegisterAltSpellName(1234753, DBM_COMMON_L.TANKBUSTER)--Bedrock Slam --> Tank Buster
DBM:RegisterAltSpellName(1235564, DBM_COMMON_L.GROUPSOAKS)--Lightblossom Beam --> Soaks
local warnThornblade						= mod:NewCountAnnounce(1261276, 2)

local specWarnBedrockSlam					= mod:NewSpecialWarningCount(1234753, "Tank", nil, nil, 1, 2, nil, nil, "defensive")
local specWarnLightsowerDash				= mod:NewSpecialWarningCount(1234850, nil, nil, nil, 2, 2, nil, nil, "chargemove")
local specWarnLightblossomBeam				= mod:NewSpecialWarningCount(1235564, nil, nil, nil, 1, 2, nil, nil, "helpsoak")

local timerBedrockSlamCD					= mod:NewCDCountTimer(20.5, 1234753, nil, "Tank", nil, 5)
local timerThornbladeCD						= mod:NewCDCountTimer(20.5, 1261276, nil, nil, nil, 3)
local timerLightsowerDashCD					= mod:NewCDCountTimer(20.5, 1234850, nil, nil, nil, 3)
local timerLightblossomBeamCD				= mod:NewCDCountTimer(20.5, 1235564, nil, nil, nil, 5)

mod:AddAuraSoundOption(1261276, true, 1261276, 1, 1, "defensive", 2)--Thornblade
mod:AddAuraSoundOption(1235828, true, 1235828, 1, 2, "watchfeet", 8)--Light-Scorched Earth

mod.vb.bedrockSlamCount = 0
mod.vb.thornbladeCount = 0
mod.vb.lightsowerDashCount = 0
mod.vb.lightblossomBeamCount = 0
local badStateDetected = false
local nextFortyFiveTimer = 1
local thornbladeEvents = {}

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnBedrockSlam:SetAlert(173, "defensive", 2, 3)
		end
		specWarnLightsowerDash:SetAlert(174, "chargemove", 2, 2)
		specWarnLightblossomBeam:SetAlert(177, "helpsoak", 2, 2)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerBedrockSlamCD:SetTimeline(173, onlyColor)
	timerLightsowerDashCD:SetTimeline(174, onlyColor)
	timerThornbladeCD:SetTimeline({175, 176}, onlyColor)
	timerLightblossomBeamCD:SetTimeline(177, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.bedrockSlamCount = 1
	self.vb.thornbladeCount = 1
	self.vb.lightsowerDashCount = 1
	self.vb.lightblossomBeamCount = 1
	nextFortyFiveTimer = 1
	thornbladeEvents = {}
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
	self:Unschedule()
	thornbladeEvents = {}
	self:UnregisterShortTermEvents()
end

do
	local function finishThornblade(self, eventID)
		if not thornbladeEvents[eventID] then return end
		thornbladeEvents[eventID] = nil
		local eventType, eventCount = self:TLCountFinish(eventID)
		if eventType == "thornblade" and eventCount then
			warnThornblade:Show(eventCount)
		end
	end

	local function startThornblade(self, timerExact, eventID)
		timerThornbladeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "thornblade", "thornbladeCount"))
		thornbladeEvents[eventID] = true
		self:Schedule(timerExact, finishThornblade, eventID)
	end

	local function timersAll(self, timer, timerExact, eventID)
		if timer == 5 then
			timerBedrockSlamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bedrockSlam", "bedrockSlamCount"))
		elseif timer == 8 then
			startThornblade(self, timerExact, eventID)
		elseif timer == 20 then
			timerLightsowerDashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightsowerDash", "lightsowerDashCount"))
		elseif timer == 35 then
			timerLightblossomBeamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightblossomBeam", "lightblossomBeamCount"))
		elseif timer >= 41 and timer <= 45 then
			if nextFortyFiveTimer == 1 then
				timerBedrockSlamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bedrockSlam", "bedrockSlamCount"))
			elseif nextFortyFiveTimer == 2 then
				startThornblade(self, timerExact, eventID)
			elseif nextFortyFiveTimer == 3 then
				timerLightsowerDashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightsowerDash", "lightsowerDashCount"))
			else
				timerLightblossomBeamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightblossomBeam", "lightblossomBeamCount"))
			end
			nextFortyFiveTimer = nextFortyFiveTimer % 4 + 1
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
			if thornbladeEvents[eventID] then return end--Blizzard bug: state 2 fires immediately; finishThornblade handles the raw-duration completion
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "bedrockSlam" then
					if self:IsTank() then
						specWarnBedrockSlam:Show(eventCount)
						specWarnBedrockSlam:Play("defensive")
					end
				elseif eventType == "lightsowerDash" then
					specWarnLightsowerDash:Show(eventCount)
					specWarnLightsowerDash:Play("chargemove")
				elseif eventType == "lightblossomBeam" then
					specWarnLightblossomBeam:Show(eventCount)
					specWarnLightblossomBeam:Play("helpsoak")
				end
			end
		elseif eventState == 3 then
			if thornbladeEvents[eventID] then
				thornbladeEvents[eventID] = nil
				self:Unschedule(finishThornblade, eventID)
			end
			self:TLCountCancel(eventID)
		end
	end
end
