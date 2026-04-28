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

local warnEtherealShackles				= mod:NewCountAnnounce(1214038, 2)

local specWarnRefuelingProtocol			= mod:NewSpecialWarningCount(474345, nil, nil, nil, 2, 2)
local specWarnRepulsingSlam				= mod:NewSpecialWarningCount(474496, nil, nil, nil, 1, 2)
local specWarnArcaneExpulsion			= mod:NewSpecialWarningCount(1214081, nil, 28405, nil, 2, 2)

local timerRefuelingProtocolCD			= mod:NewCDCountTimer(20.5, 474345, nil, nil, nil, 6, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerRepulsingSlamCD				= mod:NewCDCountTimer(20.5, 474496, 182557, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Short Text "Slam"
local timerEtherealShacklesCD			= mod:NewCDCountTimer(20.5, 1214038, DBM_COMMON_L.DISPELS.." (%s)", nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerArcaneExpulsionCD			= mod:NewCDCountTimer(20.5, 1214081, 28405, nil, nil, 2)--Short text "Knockback"

mod:AddPrivateAuraSoundOption(1214089, true, 1214089, 1, 2, "watchfeet", 8)--Arcane Residue (GTFO)
mod:AddPrivateAuraSoundOption(1214038, true, 1214038, 1, 1, "debuffyou", 17)--Ethereal Shackles

mod.vb.protocolCount = 0
mod.vb.slamCount = 0
mod.vb.shacklesCount = 0
mod.vb.expulsionCount = 0
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
local function setFallback(self, dontSetAlerts)
	--Blizz API fallbacks
	if not dontSetAlerts then
		specWarnRefuelingProtocol:SetAlert(281, "catchballs", 12, 3)
		if self:IsTank() then
			specWarnRepulsingSlam:SetAlert(286, "carefly", 2, 2)
		end
		specWarnArcaneExpulsion:SetAlert(288, "carefly", 2, 3)
	end
	timerRefuelingProtocolCD:SetTimeline(281)
	timerRepulsingSlamCD:SetTimeline(286)
	timerEtherealShacklesCD:SetTimeline(287)
	timerArcaneExpulsionCD:SetTimeline(288)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.protocolCount = 1
	self.vb.slamCount = 1
	self.vb.shacklesCount = 1
	self.vb.expulsionCount = 1
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
		elseif timer == 45 then--Refueling Protocol
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
