local mod	= DBM:NewMod(2813, "DBM-Party-Midnight", 8, 1316)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(241539)--Iffy, not reported as a boss
mod:SetEncounterID(3328)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2915)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local specWarnCoresparkDetonation	= mod:NewSpecialWarningCount(1257509, nil, nil, nil, 2, 2)
local specWarnLeylineArray			= mod:NewSpecialWarningCount(1251183, nil, nil, nil, 2, 3)
local specWarnFluxCollapse			= mod:NewSpecialWarningCount(1264048, nil, nil, nil, 2, 2)
local warnRefluxCharge				= mod:NewCountAnnounce(1251785, 2)

local timerCoresparkDetonationCD	= mod:NewCDCountTimer(38, 1257509, nil, nil, nil, 3)
local timerRefluxChargeCD			= mod:NewCDCountTimer(12, 1251785, nil, nil, nil, 3)
local timerLeylineArrayCD			= mod:NewCDCountTimer(11, 1251183, nil, nil, nil, 3)
local timerFluxCollapseCD			= mod:NewCDCountTimer(13, 1264048, nil, nil, nil, 3)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1251785, true, 1251785, 1, 1, "movetobeam", 19)--Reflux Charge
mod:AddPrivateAuraSoundOption(1264042, true, 1264042, 1, 2, "watchfeet", 8)--Arcane Spill

mod.vb.coresparkDetonationCount = 0
mod.vb.refluxChargeCount = 0
mod.vb.leylineArrayCount = 0
mod.vb.fluxCollapseCount = 0

local badStateDetected = false
local coresparkAddedCount = 0
local activeOddCorespark = {}
local activeOtherEvents = {}
local pendingRebase = {}
local pendingRebaseUntil = 0

---@param self DBMMod
local function setFallback(self)
	specWarnCoresparkDetonation:SetAlert(106, "watchstep", 2)
	specWarnLeylineArray:SetAlert(108, "farfromline", 2)
	specWarnFluxCollapse:SetAlert(172, "watchstep", 2)
	timerCoresparkDetonationCD:SetTimeline(106)
	timerRefluxChargeCD:SetTimeline(107)
	timerLeylineArrayCD:SetTimeline(108)
	timerFluxCollapseCD:SetTimeline(172)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.coresparkDetonationCount = 1
	self.vb.refluxChargeCount = 1
	self.vb.leylineArrayCount = 1
	self.vb.fluxCollapseCount = 1
	badStateDetected = false
	coresparkAddedCount = 0
	activeOddCorespark = {}
	activeOtherEvents = {}
	pendingRebase = {}
	pendingRebaseUntil = 0
	if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
	else
		setFallback(self)
	end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	activeOddCorespark = {}
	activeOtherEvents = {}
	pendingRebase = {}
	self:UnregisterShortTermEvents()
end

do
	---@param timerExact number
	---@return string?
	local function consumeRebasedEventType(timerExact)
		if #pendingRebase == 0 or GetTime() > pendingRebaseUntil then
			return nil
		end
		local bestIndex, bestDiff
		for i = 1, #pendingRebase do
			local diff = math.abs(pendingRebase[i].remaining - timerExact)
			if not bestDiff or diff < bestDiff then
				bestDiff = diff
				bestIndex = i
			end
		end
		if bestIndex and bestDiff and bestDiff <= 1.25 then
			local eventType = pendingRebase[bestIndex].eventType
			table.remove(pendingRebase, bestIndex)
			return eventType
		end
		return nil
	end

	---@param self DBMMod
	local function snapshotRemainingForRebase(self)
		pendingRebase = {}
		local now = GetTime()
		for _, info in pairs(activeOtherEvents) do
			local remaining = info.duration - (now - info.startTime)
			if remaining > 0.2 then
				table.insert(pendingRebase, {
					eventType = info.eventType,
					remaining = remaining
				})
			end
		end
		pendingRebaseUntil = now + 20
	end

	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		local handled = false
		if timer == 38 then--Corespark Detonation has bugged duplicate ADDEDs; odd ADDED is real, even ADDED is false start
			coresparkAddedCount = coresparkAddedCount + 1
			if coresparkAddedCount % 2 == 1 then
				timerCoresparkDetonationCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "coresparkDetonation", "coresparkDetonationCount"))
				activeOddCorespark[eventID] = true
			end
			handled = true
		else
			local eventType = consumeRebasedEventType(timerExact)
			if not eventType then
				if timer == 1 or timer == 11 then
					eventType = "leylineArray"
				elseif timer == 5 or timer == 12 then
					eventType = "refluxCharge"
				elseif timer == 10 or timer == 13 then
					eventType = "fluxCollapse"
				end
			end
			if eventType == "leylineArray" then
				timerLeylineArrayCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "leylineArray", "leylineArrayCount"))
				activeOtherEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
				handled = true
			elseif eventType == "refluxCharge" then
				timerRefluxChargeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "refluxCharge", "refluxChargeCount"))
				activeOtherEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
				handled = true
			elseif eventType == "fluxCollapse" then
				timerFluxCollapseCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fluxCollapse", "fluxCollapseCount"))
				activeOtherEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
				handled = true
			end
		end
		if not handled then
			badStateDetected = true
			self:ResumeBlizzardAPI()
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 then return end
		local eventID = eventInfo.id
		local timerExact = eventInfo.duration
		local timer = math.floor(timerExact + 0.5)
		if not badStateDetected then
			timersAll(self, timer, timerExact, eventID)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventID or not eventState then return end
		if eventState == 2 then
			activeOddCorespark[eventID] = nil
			activeOtherEvents[eventID] = nil
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "coresparkDetonation" then
					specWarnCoresparkDetonation:Show(eventCount)
					specWarnCoresparkDetonation:Play("watchstep")
				elseif eventType == "leylineArray" then
					specWarnLeylineArray:Show(eventCount)
					specWarnLeylineArray:Play("farfromline")
				elseif eventType == "refluxCharge" then
					warnRefluxCharge:Show(eventCount)
				elseif eventType == "fluxCollapse" then
					specWarnFluxCollapse:Show(eventCount)
					specWarnFluxCollapse:Play("watchstep")
				end
			end
		elseif eventState == 3 then
			if activeOddCorespark[eventID] then
				--Blizzard bug: odd Corespark ADDED resolves as state 3 when it actually detonates.
				--Snapshot remaining times of non-Corespark events so rebased follow-up ADDEDs can be matched.
				snapshotRemainingForRebase(self)
				activeOddCorespark[eventID] = nil
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType == "coresparkDetonation" and eventCount then
					specWarnCoresparkDetonation:Show(eventCount)
					specWarnCoresparkDetonation:Play("watchstep")
				end
			else
				activeOtherEvents[eventID] = nil
				self:TLCountCancel(eventID)
			end
		end
	end
end
