local mod	= DBM:NewMod(2659, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231861)--Iffy, doesn't report as instance boss
mod:SetEncounterID(3071)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

DBM:RegisterAltSpellName(474496, 182557)--Repulsing Slam -> Slam
DBM:RegisterAltSpellName(1214081, 28405)--Arcane Expulsion -> Knockback
DBM:RegisterAltSpellName(1214038, DBM_COMMON_L.DISPELS)--Ethereal Shackles -> Dispels

local warnEtherealShackles				= mod:NewCountAnnounce(1214038, 2)

local specWarnRefuelingProtocol			= mod:NewSpecialWarningCount(474345, nil, nil, nil, 2, 2, nil, nil, "catchballs")
local specWarnRepulsingSlam				= mod:NewSpecialWarningCount(474496, nil, nil, nil, 1, 2, nil, nil, "carefly")
local specWarnArcaneExpulsion			= mod:NewSpecialWarningCount(1214081, nil, nil, nil, 2, 2, nil, nil, "carefly")

local timerRefuelingProtocolCD			= mod:NewCDCountTimer(20.5, 474345, nil, nil, nil, 6, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerRepulsingSlamCD				= mod:NewCDCountTimer(20.5, 474496, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEtherealShacklesCD			= mod:NewCDCountTimer(20.5, 1214038, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerArcaneExpulsionCD			= mod:NewCDCountTimer(20.5, 1214081, nil, nil, nil, 2)

--mod:AddAuraSoundOption(1214089, true, 1214089, 1, 2, "watchfeet", 8)--Arcane Residue (GTFO)
--mod:AddAuraSoundOption(1214038, true, 1214038, 1, 1, "debuffyou", 17)--Ethereal Shackles

mod.vb.protocolCount = 0
mod.vb.slamCount = 0
mod.vb.shacklesCount = 0
mod.vb.expulsionCount = 0
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	--Blizz API fallbacks
	if not dontSetAlerts then
		specWarnRefuelingProtocol:SetAlert(281, "catchballs", 12, 3)
		if self:IsTank() then
			specWarnRepulsingSlam:SetAlert(286, "carefly", 2, 2)
		end
		specWarnArcaneExpulsion:SetAlert(288, "carefly", 2, 3)
	end
	--If user has DBM bars enabled, we only want to register colors to the blizz api so that the blizz bars are also colorized.
	--If user has bars disabled, or we are in a bad state, onlyColor is false and we register countdowns as well.
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerRefuelingProtocolCD:SetTimeline(281, onlyColor)
	timerRepulsingSlamCD:SetTimeline(286, onlyColor)
	timerEtherealShacklesCD:SetTimeline(287, onlyColor)
	timerArcaneExpulsionCD:SetTimeline(288, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.protocolCount = 1
	self.vb.slamCount = 1
	self.vb.shacklesCount = 1
	self.vb.expulsionCount = 1
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
		--Logic confirmed against M+ only. Normal, Heroic, and M0 not covered
		if timer > 900 then--Ignored long placeholder artifacts seen in logged pull
			return
		elseif timer == 48 then--Ignored protocol/reset artifact seen in logged pull (always canceled early)
			return
		elseif timerExact == 45 then--Refueling Protocol (45 exact, an artifact such as 44.994 is not a real timer, but a resend that just happens to round to 45)
			timerRefuelingProtocolCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "protocol", "protocolCount"))
		elseif timer == 5 or timer == 6 or timer == 7 then--Repulsing Slam opener after pull/refuel (state 1 can round to 7)
			timerRepulsingSlamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "slam", "slamCount"))
		elseif timer == 15 or timer == 16 or timer == 17 then--Arcane Expulsion opener after pull/refuel (state 1 can round to 17)
			timerArcaneExpulsionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "expulsion", "expulsionCount"))
		elseif timer == 22 then--Ethereal Shackles real cast
			timerEtherealShacklesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "shackles", "shacklesCount"))
		elseif timer == 23 then--Repulsing Slam (22.5) or Arcane Expulsion (23.0)
			if timerExact < 22.75 then
				timerRepulsingSlamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "slam", "slamCount"))
			else
				timerArcaneExpulsionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "expulsion", "expulsionCount"))
			end
		else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
			badStateDetected = true
			self:ResumeBlizzardAPI()
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end
	--Note, bar state changing and canceling is handled by core
	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 then return end
		local eventID = eventInfo.id
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		--Ignore erratic garbage sent when boss bugs out and sends state 1 2 or 3 timers on start
		--Note. This is a known issue with this boss specifically and state filters on ENCOUNTER_TIMELINE_EVENT_ADDED aren't typically needed
		if eventState ~= 0 then return end
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
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "protocol" then
					specWarnRefuelingProtocol:Show(eventCount)
					specWarnRefuelingProtocol:Play("catchballs")
				elseif eventType == "slam" then
					if self:IsTank() then
						specWarnRepulsingSlam:Show(eventCount)
						specWarnRepulsingSlam:Play("carefly")
					end
				elseif eventType == "shackles" then
					warnEtherealShackles:Show(eventCount)
				elseif eventType == "expulsion" then
					specWarnArcaneExpulsion:Show(eventCount)
					specWarnArcaneExpulsion:Play("carefly")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
