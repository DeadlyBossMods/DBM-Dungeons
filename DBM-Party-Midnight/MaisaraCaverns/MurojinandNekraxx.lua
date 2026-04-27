local mod	= DBM:NewMod(2810, "DBM-Party-Midnight", 7, 1315)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(247570)--Muro, Nekraxx is 247572
mod:SetEncounterID(3212)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2874)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnCarrionSwoop			= mod:NewBlizzTargetAnnounce(1249478, 2)

local specWarnFlankingSpear		= mod:NewSpecialWarningCount(1266480, nil, nil, nil, 1, 2)
local specWarnFetidQuillstorm	= mod:NewSpecialWarningDodgeCount(1243900, nil, nil, nil, 2, 2)
local specWarnFreezingTrap		= mod:NewSpecialWarningDodgeCount(1243741, nil, nil, nil, 2, 19)
local specWarnBarrage			= mod:NewSpecialWarningDodgeCount(1260643, nil, nil, nil, 2, 2)
local specWarnInfectedPinions	= mod:NewSpecialWarningCount(1246666, "RemoveDisease", nil, nil, 1, 2)

local timerFlankingSpearCD		= mod:NewCDCountTimer(20.5, 1266480, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFetidQuillstormCD	= mod:NewCDCountTimer(20.5, 1243900, nil, nil, nil, 3)
local timerFreezingTrapCD		= mod:NewCDCountTimer(20.5, 1243741, nil, nil, nil, 1)
local timerBarrageCD			= mod:NewCDCountTimer(20.5, 1260643, nil, nil, nil, 3)
local timerInfectedPinionsCD	= mod:NewCDCountTimer(20.5, 1246666, nil, nil, nil, 5, nil, DBM_COMMON_L.DISEASE_ICON)
local timerCarrionSwoopCD		= mod:NewCDCountTimer(20.5, 1249478, nil, nil, nil, 3, nil, DBM_COMMON_L.IMPORTANT_ICON)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1243741, true, 1243741, 1, 1, "stunyou", 19)--Freezing Trap Stun
mod:AddPrivateAuraSoundOption(1260643, true, 1260643, 1, 1, "frontalyou", 19)--Barrage
mod:AddPrivateAuraSoundOption(1249478, true, 1249478, 1, 1, "behindice", 19)--Carrion Swoop

mod.vb.flankingSpearCount = 0
mod.vb.fetidQuillstormCount = 0
mod.vb.freezingTrapCount = 0
mod.vb.barrageCount = 0
mod.vb.infectedPinionsCount = 0
mod.vb.carrionSwoopCount = 0

local cycleStep = 0
local badStateDetected = false
local activeEvents = {}
local deadBoss = nil--"muro" only; Nekraxx can be resurrected so full cycle remains valid
local last45EventType = nil
local cancelWindowStart = 0
local muroCancelCount = 0
local pendingResume = {}
local pendingResumeUntil = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnFlankingSpear:SetAlert(150, "defensive", 2)
		end
		specWarnFetidQuillstorm:SetAlert(151, "watchstep", 2)
		specWarnFreezingTrap:SetAlert(152, "trapsincoming", 19)
		specWarnBarrage:SetAlert(154, "frontal", 15)
	end
	timerFlankingSpearCD:SetTimeline(150)
	timerFetidQuillstormCD:SetTimeline(151)
	timerFreezingTrapCD:SetTimeline(152)
	timerBarrageCD:SetTimeline(153)
	timerInfectedPinionsCD:SetTimeline(154)
	timerCarrionSwoopCD:SetTimeline(155)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	cycleStep = 0
	badStateDetected = false
	activeEvents = {}
	deadBoss = nil
	last45EventType = nil
	cancelWindowStart = 0
	muroCancelCount = 0
	pendingResume = {}
	pendingResumeUntil = 0
	self.vb.flankingSpearCount = 1
	self.vb.fetidQuillstormCount = 1
	self.vb.freezingTrapCount = 1
	self.vb.barrageCount = 1
	self.vb.infectedPinionsCount = 1
	self.vb.carrionSwoopCount = 1
	if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
		--SetTimeline events since user has disabled DBM Bars (so they can still get countdowns in blizzard timeline API instead)
		if DBM.Options.HideDBMBars then
			setFallback(self, true)
		end
	else
		setFallback(self)
	end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	cycleStep = 0
	activeEvents = {}
	deadBoss = nil
	last45EventType = nil
	cancelWindowStart = 0
	muroCancelCount = 0
	pendingResume = {}
	pendingResumeUntil = 0
	self:UnregisterShortTermEvents()
end

do
	---@param timerExact number
	---@return string?
	local function consumeResumeEventType(timerExact)
		if #pendingResume == 0 then return nil end
		if GetTime() > pendingResumeUntil then
			pendingResume = {}
			return nil
		end
		local bestIndex
		local bestDiff
		for i = 1, #pendingResume do
			local diff = math.abs(pendingResume[i].remaining - timerExact)
			if not bestDiff or diff < bestDiff then
				bestDiff = diff
				bestIndex = i
			end
		end
		if bestIndex and bestDiff and bestDiff <= 1.25 then
			local eventType = pendingResume[bestIndex].eventType
			table.remove(pendingResume, bestIndex)
			return eventType
		end
		return nil
	end

	---@param eventType string
	---@param remaining number
	local function queuePendingResume(eventType, remaining)
		if remaining <= 0.2 then return end
		table.insert(pendingResume, {
			eventType = eventType,
			remaining = remaining
		})
		pendingResumeUntil = GetTime() + 20
	end

	---@param eventType string?
	---@return boolean
	local function isMuroAbility(eventType)
		return eventType == "flankingSpear" or eventType == "freezingTrap" or eventType == "barrage"
	end

	---@param eventType string?
	local function detectDeathFromCancels(eventType)
		if deadBoss or not eventType then return end
		if not isMuroAbility(eventType) then return end
		local now = GetTime()
		if (now - cancelWindowStart) > 2 then
			cancelWindowStart = now
			muroCancelCount = 0
		end
		muroCancelCount = muroCancelCount + 1
		if muroCancelCount >= 2 then
			deadBoss = "muro"
		end
	end

	---@param eventType string?
	---@return string
	local function getNext45EventType(eventType)
		if deadBoss == "muro" then
			if eventType == "infectedPinions" then
				return "fetidQuillstorm"
			elseif eventType == "fetidQuillstorm" then
				return "carrionSwoop"
			end
			return "infectedPinions"
		end
		cycleStep = cycleStep + 1
		if cycleStep > 6 then cycleStep = 1 end
		if cycleStep == 1 then
			return "flankingSpear"
		elseif cycleStep == 2 then
			return "infectedPinions"
		elseif cycleStep == 3 then
			return "freezingTrap"
		elseif cycleStep == 4 then
			return "fetidQuillstorm"
		elseif cycleStep == 5 then
			return "barrage"
		end
		return "carrionSwoop"
	end

	---@param self DBMMod
	---@param eventType string
	---@param timerExact number
	---@param eventID number
	---@return boolean
	local function startTimerByEventType(self, eventType, timerExact, eventID)
		if eventType == "flankingSpear" then
			activeEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
			timerFlankingSpearCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "flankingSpearCount"))
			return true
		elseif eventType == "infectedPinions" then
			activeEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
			timerInfectedPinionsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "infectedPinionsCount"))
			return true
		elseif eventType == "freezingTrap" then
			activeEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
			timerFreezingTrapCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "freezingTrapCount"))
			return true
		elseif eventType == "fetidQuillstorm" then
			activeEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
			timerFetidQuillstormCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "fetidQuillstormCount"))
			return true
		elseif eventType == "barrage" then
			activeEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
			timerBarrageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "barrageCount"))
			return true
		elseif eventType == "carrionSwoop" then
			activeEvents[eventID] = {eventType = eventType, startTime = GetTime(), duration = timerExact}
			timerCarrionSwoopCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, "carrionSwoopCount"))
			return true
		end
		return false
	end

	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		local handled = false
		local resumedEventType = consumeResumeEventType(timerExact)
		if resumedEventType then
			handled = startTimerByEventType(self, resumedEventType, timerExact, eventID)
			if handled and timer == 45 then
				last45EventType = resumedEventType
			end
		elseif timer == 5 then--Flanking Spear (opener)
			handled = startTimerByEventType(self, "flankingSpear", timerExact, eventID)
		elseif timer == 12 then--Infected Pinions (opener)
			handled = startTimerByEventType(self, "infectedPinions", timerExact, eventID)
		elseif timer == 20 then--Freezing Trap (opener)
			handled = startTimerByEventType(self, "freezingTrap", timerExact, eventID)
		elseif timer == 28 then--Fetid Quillstorm (opener)
			handled = startTimerByEventType(self, "fetidQuillstorm", timerExact, eventID)
		elseif timer == 35 then--Barrage (opener)
			handled = startTimerByEventType(self, "barrage", timerExact, eventID)
		elseif timer == 41 then--Carrion Swoop (opener)
			handled = startTimerByEventType(self, "carrionSwoop", timerExact, eventID)
		elseif timer == 45 then--Cycling post-opener; after one boss dies, route survivor-only sequence
			local eventType = getNext45EventType(last45EventType)
			handled = startTimerByEventType(self, eventType, timerExact, eventID)
			if handled then
				last45EventType = eventType
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
		local activeInfo = activeEvents[eventID]
		local activeEventType = activeInfo and activeInfo.eventType
		if eventState == 2 then
			activeEvents[eventID] = nil
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "flankingSpear" then
					if self:IsTank() then
						specWarnFlankingSpear:Show(eventCount)
						specWarnFlankingSpear:Play("defensive")
					end
				elseif eventType == "fetidQuillstorm" then
					specWarnFetidQuillstorm:Show(eventCount)
					specWarnFetidQuillstorm:Play("watchstep")
				elseif eventType == "freezingTrap" then
					specWarnFreezingTrap:Show(eventCount)
					specWarnFreezingTrap:Play("trapsincoming")
				elseif eventType == "barrage" then
					specWarnBarrage:Show(eventCount)
					specWarnBarrage:Play("frontal")
				elseif eventType == "infectedPinions" then
					specWarnInfectedPinions:Show(eventCount)
					specWarnInfectedPinions:Play("helpdispel")
				elseif eventType == "carrionSwoop" then
					warnCarrionSwoop:Show(eventCount)
				end
			end
		elseif eventState == 3 then
			if activeInfo and activeEventType then
				local remaining = activeInfo.duration - (GetTime() - activeInfo.startTime)
				queuePendingResume(activeEventType, remaining)
			end
			activeEvents[eventID] = nil
			detectDeathFromCancels(activeEventType)
			self:TLCountCancel(eventID)
		end
	end
end
