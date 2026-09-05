local mod	= DBM:NewMod(2772, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(247676)
mod:SetEncounterID(3202)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

DBM:RegisterAltSpellName(1246372, DBM_COMMON_L.ADDS)--Awaken Lightbloom --> Adds
DBM:RegisterAltSpellName(1253690, DBM_COMMON_L.TANK .. " " .. DBM_COMMON_L.LINE)--Lightbeam --> Tank Line
DBM:RegisterAltSpellName(1246858, DBM_COMMON_L.ORB .. " " .. DBM_COMMON_L.GROUPSOAKS)--Lightbloom's Essence --> Orb Soaks
DBM:RegisterAltSpellName(1247685, DBM_COMMON_L.TANKBUSTER)--Thornspike --> Tank Buster
local specWarnAwakenLightbloom				= mod:NewSpecialWarningCount(1246372, nil, nil, nil, 2, 2, nil, nil, "mobsoon")
local specWarnThornspike					= mod:NewSpecialWarningDefensive(1247685, nil, nil, nil, 1, 2, nil, nil, "defensive")
local specWarnLightbloomsEssence			= mod:NewSpecialWarningCount(1246858, nil, nil, nil, 2, 2, nil, nil, "catchballs")
local specWarnLightbeam						= mod:NewSpecialWarningBlizzYou(1253690, nil, nil, nil, 2, 19, nil, nil, "beamyou")

local timerAwakenLightbloomCD				= mod:NewCDCountTimer(20.5, 1246372, nil, nil, nil, 1)
local timerThornspikeCD						= mod:NewCDCountTimer(20.5, 1247685, nil, "Tank", nil, 5)
local timerLightbeamCD						= mod:NewCDCountTimer(20.5, 1253690, nil, nil, nil, 3)
local timerLightbloomsEssenceCD				= mod:NewCDCountTimer(20.5, 1246858, nil, nil, nil, 5)

--Custom Aura Sounds
--mod:AddAuraSoundOption(1253690, true, 1253690, 1, 1, "movetomobs", 14)--Concentrated Lightbeam, FIX ME if not pre positioned spell
--mod:AddAuraSoundOption(1246751, true, 1246751, 1, 2, "watchfeet", 8)--Concentrated Lightbeam
mod:AddAuraSoundOption(1246753, true, 1246753, 1, 2, "watchfeet", 8)--Lightsap

mod.vb.awakenLightbloomCount = 0
mod.vb.thornspikeCount = 0
mod.vb.lightbeamCount = 0
mod.vb.lightbloomsEssenceCount = 0
local badStateDetected = false
local nextFiftyTimer = 1

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnAwakenLightbloom:SetAlert(189, "mobsoon", 2, 3)
		if self:IsTank() then
			specWarnThornspike:SetAlert(190, "defensive", 1, 2)
		end
		specWarnLightbloomsEssence:SetAlert(192, "catchballs", 12, 3)
		specWarnLightbeam:SetAlert(191, "beamyou", 19, 2, 0)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerAwakenLightbloomCD:SetTimeline(189, onlyColor)
	timerThornspikeCD:SetTimeline(190, onlyColor)
	timerLightbeamCD:SetTimeline(191, onlyColor)
	timerLightbloomsEssenceCD:SetTimeline(192, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.awakenLightbloomCount = 1
	self.vb.thornspikeCount = 1
	self.vb.lightbeamCount = 1
	self.vb.lightbloomsEssenceCount = 1
	nextFiftyTimer = 1
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
	nextFiftyTimer = 1
	self:UnregisterShortTermEvents()
end

do
	local function timersAll(self, timer, timerExact, eventID)
		if timer == 4 then
			timerAwakenLightbloomCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "awakenLightbloom", "awakenLightbloomCount"))
		elseif timer == 14 then
			timerLightbloomsEssenceCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightbloomsEssence", "lightbloomsEssenceCount"))
		elseif timer == 26 then
			timerThornspikeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "thornspike", "thornspikeCount"))
		elseif timer == 40 then
			timerLightbeamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightbeam", "lightbeamCount"))
		elseif timer == 50 then
			--PTR M+ timeline order is Awaken -> Essence -> Thornspike -> Lightbeam.
			--Each replacement bar arrives immediately before the previous bar reaches state 2.
			if nextFiftyTimer == 1 then
				timerAwakenLightbloomCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "awakenLightbloom", "awakenLightbloomCount"))
			elseif nextFiftyTimer == 2 then
				timerLightbloomsEssenceCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightbloomsEssence", "lightbloomsEssenceCount"))
			elseif nextFiftyTimer == 3 then
				timerThornspikeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "thornspike", "thornspikeCount"))
			else
				timerLightbeamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightbeam", "lightbeamCount"))
			end
			nextFiftyTimer = nextFiftyTimer % 4 + 1
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
				if eventType == "awakenLightbloom" then
					specWarnAwakenLightbloom:Show(eventCount)
					specWarnAwakenLightbloom:Play("mobsoon")
				elseif eventType == "thornspike" then
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnThornspike:Show()
						specWarnThornspike:Play("defensive")
					end
				elseif eventType == "lightbeam" then
					specWarnLightbeam:Show(eventCount, "beamyou")
				elseif eventType == "lightbloomsEssence" then
					specWarnLightbloomsEssence:Show(eventCount)
					specWarnLightbloomsEssence:Play("catchballs")
				end
			end
		elseif eventState == 1 or eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
