local mod	= DBM:NewMod(2778, "DBM-Party-Midnight", 5, 1311)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID()--TOO many IDs to guess
mod:SetEncounterID(3209)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2825)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, https://www.wowhead.com/spell=1262846/spirit-thrash seems to be older version of fury of the war god
--NOTE, 909-911 are 12.1 versions of spells, likely custom alert texts added to fill void of private aura alert removals
local warnEchoingMaul						= mod:NewCountAnnounce(1242860, 3)

local specWarnFuryoftheWarGod				= mod:NewSpecialWarningCount(1243011, nil, nil, nil, 2, 3, nil, nil, "specialsoon")
local specWarnOverwhelmingOnslaught			= mod:NewSpecialWarningCount(1243569, nil, nil, nil, 2, 2, nil, nil, "findshield")

local timerEchoingMaulCD					= mod:NewCDCountTimer(20.5, 1242860, nil, nil, nil, 3)
local timerFuryoftheWarGodCD				= mod:NewCDCountTimer(20.5, 1243011, nil, nil, nil, 5)
local timerOverwhelmingOnslaughtCD			= mod:NewCDCountTimer(20.5, 1243569, nil, nil, nil, 5)

--Custom Aura Sounds
mod:AddAuraSoundOption(1242869, true, 1242869, 1, 1, "scatter", 2)--Echoing Maul
mod:AddAuraSoundOption(1261781, true, 1261781, 1, 1, "safenow", 2)--Defensive Stance

mod.vb.maulCount = 0
mod.vb.furyCount = 0
mod.vb.onslaughtCount = 0
local next25IsMaul = true
local timerTypeByEventID = {}
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnFuryoftheWarGod:SetAlert({91, 910}, "specialsoon", 2, 3)
		if self:IsTank() then
			specWarnOverwhelmingOnslaught:SetAlert(92, "findshield", 2, 2)
		end
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerEchoingMaulCD:SetTimeline({90, 909, 911}, onlyColor)
	timerFuryoftheWarGodCD:SetTimeline({91, 910}, onlyColor)
	timerOverwhelmingOnslaughtCD:SetTimeline(92, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.maulCount = 1
	self.vb.furyCount = 1
	self.vb.onslaughtCount = 1
	next25IsMaul = true
	timerTypeByEventID = {}
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
		local eventType
		if timer == 5 then
			eventType = "maul"
		elseif timer == 13 then
			eventType = "onslaught"
		elseif timer == 54 then
			eventType = "fury"
		elseif timer == 25 then
			eventType = next25IsMaul and "maul" or "onslaught"
			next25IsMaul = not next25IsMaul
			timerTypeByEventID[eventID] = eventType .. "25"
		else
			return
		end
		timerTypeByEventID[eventID] = timerTypeByEventID[eventID] or eventType
		if eventType == "maul" then
			timerEchoingMaulCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "maulCount"))
		elseif eventType == "onslaught" then
			timerOverwhelmingOnslaughtCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "onslaughtCount"))
		else
			timerFuryoftheWarGodCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "furyCount"))
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
				if eventType == "maul" then
					warnEchoingMaul:Show(eventCount)
				elseif eventType == "onslaught" and self:IsTank() then
					specWarnOverwhelmingOnslaught:Show(eventCount)
					specWarnOverwhelmingOnslaught:Play("findshield")
				elseif eventType == "fury" then
					specWarnFuryoftheWarGod:Show(eventCount)
					specWarnFuryoftheWarGod:Play("specialsoon")
				end
			end
		elseif eventState == 3 then
			if timerTypeByEventID[eventID] == "maul25" and not next25IsMaul then
				next25IsMaul = true
			elseif timerTypeByEventID[eventID] == "onslaught25" and next25IsMaul then
				next25IsMaul = false
			end
			self:TLCountCancel(eventID)
			timerTypeByEventID[eventID] = nil
		end
	end
end
