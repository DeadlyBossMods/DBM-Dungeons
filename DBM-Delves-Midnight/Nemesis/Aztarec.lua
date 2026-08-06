local mod	= DBM:NewMod("Aztarec", "DBM-Delves-Midnight", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(244752)--Not known which 2 are nemesis boss yet and which 2 are random spawns
mod:SetEncounterID(3508, 3525)
mod:SetHotfixNoticeRev(20250220000000)
mod:SetMinSyncRevision(20250220000000)
mod:SetZone(3079)

mod:RegisterCombat("combat")

--NOTES:
--DBM:RegisterAltSpellName(1256358, DBM_COMMON_L.DEBUFF)

local warnVoidToxin							= mod:NewCountAnnounce(1293824, 2)--Hardcode Only
local warnEchoCast							= mod:NewCountAnnounce(1288125, 3)

--Memory Game/intermission
local specWarnSermonofUlatek				= mod:NewSpecialWarningCount(1309375, nil, nil, nil, 2, 2, nil, nil, "phasechange")
local specWarnEchoofUlatek					= mod:NewSpecialWarningCount(1288125, nil, nil, nil, 2, 2, nil, nil, "stilldanger")

--reg Abilities
local specWarnNoxiousBile					= mod:NewSpecialWarningDefensive(1291555, nil, nil, nil, 2, 15, nil, nil, "frontal")
local specWarnSerpentsStrike				= mod:NewSpecialWarningDefensive(1293825, nil, nil, nil, 1, 2, nil, nil, "defensive")
local specWarnSoulExtinction				= mod:NewSpecialWarningInterruptCount(1294963, nil, nil, nil, 3, 2, nil, nil, "kickcast")
local specWarnVenomStorm					= mod:NewSpecialWarningDodgeCount(1309418, nil, nil, nil, 2, 2, nil, nil, "watchwave")

local timerNoxiousBileCD					= mod:NewCDCountTimer(20.5, 1291555, nil, nil, nil, 3)
local timerVoidToxinCD						= mod:NewCDCountTimer(20.5, 1293824, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSerpentsStrikeCD					= mod:NewCDCountTimer(20.5, 1293825, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSoulExtinctionCD					= mod:NewCDCountTimer(20.5, 1294963, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerVenomStormCD						= mod:NewCDCountTimer(20.5, 1309418, nil, nil, nil, 3)

local badStateDetected = false
local timelineEvents = {}

mod.vb.sermonCount = 0
mod.vb.echoFinished = true
mod.vb.echoCount = 1
mod.vb.noxiousBileCount = 0
mod.vb.voidToxinCount = 0
mod.vb.soulExtinctionCount = 0
mod.vb.venomStormCount = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	--Blizz API fallbacks
	if not dontSetAlerts then
		specWarnNoxiousBile:SetAlert({978, 983}, "frontal", 15, 2)
		warnVoidToxin:SetAlert({979, 984}, "incomingdebuff", 15, 2)
		specWarnSerpentsStrike:SetAlert({980, 985}, "defensive", 2, 2)
		specWarnSoulExtinction:SetAlert({981, 986}, "kickcast", 2, 2)
		specWarnVenomStorm:SetAlert({982, 987}, "watchwave", 2, 2)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerNoxiousBileCD:SetTimeline({978, 983}, onlyColor)
	timerVoidToxinCD:SetTimeline({979, 984}, onlyColor)
	timerSerpentsStrikeCD:SetTimeline({980, 985}, onlyColor)
	timerSoulExtinctionCD:SetTimeline({981, 986}, onlyColor)
	timerVenomStormCD:SetTimeline({982, 987}, onlyColor)
end

--[[
local function isTankInGroup()
	if not IsInGroup() then
		tankFound = UnitGroupRolesAssigned("player") == "TANK"
	else
		local groupType = IsInRaid() and "raid" or "party"
		for i = 1, GetNumGroupMembers() do
			if UnitIsGroupLeader(groupType..i) then
				tankFound = UnitGroupRolesAssigned(groupType..i) == "TANK"
				return
			end
		end
	end
end
--]]

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	timelineEvents = {}
	self.vb.echoFinished = true
	self.vb.echoCount = 1
	self.vb.sermonCount = 1
	self.vb.noxiousBileCount = 1
	self.vb.voidToxinCount = 1
	self.vb.soulExtinctionCount = 1
	self.vb.venomStormCount = 1
	--UNIT events always used even in non hardcode, no ambiguity to them
	self:RegisterShortTermEvents(
		"UNIT_SPELLCAST_CHANNEL_START boss1",
		"UNIT_SPELLCAST_CHANNEL_STOP boss1",
		"UNIT_SPELLCAST_START boss1"
	)
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
	--Not known yet
	--if self:IsMythic() then
	--	self:SetCreatureID(252892)
	--else
	--	self:SetCreatureID(244752)
	--end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	timelineEvents = {}
	self:UnregisterShortTermEvents()
end

function mod:UNIT_SPELLCAST_CHANNEL_START()
	specWarnSermonofUlatek:Show(self.vb.sermonCount)
	specWarnSermonofUlatek:Play("phasechange")
	self.vb.sermonCount = self.vb.sermonCount + 1
	self.vb.echoFinished = false
	self.vb.echoCount = 1
end

function mod:UNIT_SPELLCAST_CHANNEL_STOP()
	specWarnEchoofUlatek:Show(self.vb.sermonCount)
	specWarnEchoofUlatek:Play("stilldanger")
end

function mod:UNIT_SPELLCAST_START()
	if not self.vb.echoFinished then
		---@diagnostic disable-next-line: param-type-mismatch
		warnEchoCast:Show(self.vb.echoCount .. "/4")
		self.vb.echoCount = self.vb.echoCount + 1
		if self.vb.echoCount == 4 then
			self.vb.echoFinished = true
		end
	end
end

do
	---@param eventType string
	---@return number?
	local function expectedTimer(eventType)
		local now = GetTime()
		local closest
		for _, eventInfo in pairs(timelineEvents) do
			if eventInfo.eventType == eventType and not eventInfo.pausedAt then
				local difference = math.abs(now - (eventInfo.startedAt + eventInfo.timer))
				if not closest or difference < closest then
					closest = difference
				end
			end
		end
		return closest
	end

	---@param self DBMMod
	local function failHardcode(self)
		badStateDetected = true
		if DBM.Options.IgnoreBlizzAPI then
			DBM.Options.IgnoreBlizzAPI = false
			DBM:FireEvent("DBM_ResumeBlizzAPI")
		end
		self:UnregisterShortTermEvents()
		setFallback(self)
		DBM:Debug("|cffff0000Aztarec: Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
	end

	---@param self DBMMod
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timerExact, eventID)
		--These intentionally narrow buckets cover Shadow Priest + healer NPC Normal and Mythic pulls.
		--Nemesis timers vary by player role/spec, so new duration variants should fall back until verified.
		if timerExact == 6
			or self:IsRoundedTimer(timerExact, 20.75, 0.3)
			or self:IsRoundedTimer(timerExact, 21.3, 0.14) then
			local count = self:TLCountStart(eventID, "noxiousBile", "noxiousBileCount")
			timerNoxiousBileCD:TLStart(timerExact, eventID, count)
			timelineEvents[eventID] = {eventType = "noxiousBile", timer = timerExact, startedAt = GetTime()}
		elseif timerExact == 10 then
			local count = self:TLCountStart(eventID, "voidToxin", "voidToxinCount")
			timerVoidToxinCD:TLStart(timerExact, eventID, count)
			timelineEvents[eventID] = {eventType = "voidToxin", timer = timerExact, startedAt = GetTime()}
		elseif self:IsRoundedTimer(timerExact, 21.65, 0.2) then
			local noxiousDifference = expectedTimer("noxiousBile")
			local voidDifference = expectedTimer("voidToxin")
			if noxiousDifference and (not voidDifference or noxiousDifference < voidDifference) then
				local count = self:TLCountStart(eventID, "noxiousBile", "noxiousBileCount")
				timerNoxiousBileCD:TLStart(timerExact, eventID, count)
				timelineEvents[eventID] = {eventType = "noxiousBile", timer = timerExact, startedAt = GetTime()}
			elseif voidDifference then
				local count = self:TLCountStart(eventID, "voidToxin", "voidToxinCount")
				timerVoidToxinCD:TLStart(timerExact, eventID, count)
				timelineEvents[eventID] = {eventType = "voidToxin", timer = timerExact, startedAt = GetTime()}
			else
				failHardcode(self)
			end
		elseif timerExact == 18 or self:IsRoundedTimer(timerExact, 35.5, 0.55) then
			local count = self:TLCountStart(eventID, "soulExtinction", "soulExtinctionCount")
			timerSoulExtinctionCD:TLStart(timerExact, eventID, count)
			timelineEvents[eventID] = {eventType = "soulExtinction", timer = timerExact, startedAt = GetTime()}
		elseif timerExact == 23 or self:IsRoundedTimer(timerExact, 25.65, 0.2) or self:IsRoundedTimer(timerExact, 28.5, 0.1) then
			local count = self:TLCountStart(eventID, "venomStorm", "venomStormCount")
			timerVenomStormCD:TLStart(timerExact, eventID, count)
			timelineEvents[eventID] = {eventType = "venomStorm", timer = timerExact, startedAt = GetTime()}
		else--Hardcode failed; disable and fall back to Blizzard API
			failHardcode(self)
		end
	end

	--Note, bar state changing and canceling is handled by core
	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 then return end
		local eventID = eventInfo.id
		local timerExact = eventInfo.duration
		if not badStateDetected then
			timersAll(self, timerExact, eventID)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		if not eventID then return end
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventState then return end
		local eventInfo = timelineEvents[eventID]
		if eventState == 1 and eventInfo then
			eventInfo.pausedAt = GetTime()
		elseif eventState == 0 and eventInfo and eventInfo.pausedAt then
			eventInfo.startedAt = eventInfo.startedAt + GetTime() - eventInfo.pausedAt
			eventInfo.pausedAt = nil
		elseif eventState == 2 then--Finished
			timelineEvents[eventID] = nil
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "noxiousBile" then
					specWarnNoxiousBile:Show()
					specWarnNoxiousBile:Play("frontal")
				elseif eventType == "voidToxin" then
					warnVoidToxin:Show(eventCount)
				elseif eventType == "soulExtinction" then
					specWarnSoulExtinction:Show(L.name, eventCount)
					specWarnSoulExtinction:Play("kickcast")
				elseif eventType == "venomStorm" then
					specWarnVenomStorm:Show(eventCount)
					specWarnVenomStorm:Play("watchwave")
				end
			end
		elseif eventState == 3 then--Canceled
			timelineEvents[eventID] = nil
			self:TLCountCancel(eventID)
		end
	end
end
