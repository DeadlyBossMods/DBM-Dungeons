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
--Does not currently support timeline API, making functionality EXTREMELY limited
--Custom Sounds on cast/cooldown expiring
--DBM:RegisterAltSpellName(1256358, DBM_COMMON_L.DEBUFF)

--local warnDevouringEssence					= mod:NewCountAnnounce(1256358, 2)
--
--local specWarnImplodingStrike				= mod:NewSpecialWarningDefensive(1256355, nil, nil, nil, 1, 2, nil, nil, "defensive")
--
--local timerDevouringEssenceCD				= mod:NewCDCountTimer(20.5, 1256358, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
--
--local badStateDetected = false
--
--local function setFallback(self)
--	--Blizz API fallbacks
--end

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
--	self:TLCountReset()
	--if DBM.Options.HardcodedTimer and not badStateDetected then
	--	self:IgnoreBlizzardAPI()
	--	self:RegisterShortTermEvents(
	--		"ENCOUNTER_TIMELINE_EVENT_ADDED",
	--		"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
	--	)
	--else
	--	setFallback(self)
	--end
	--if self:IsMythic() then
	--	self:SetCreatureID(252892)
	--else
	--	self:SetCreatureID(244752)
	--end
end

function mod:OnCombatEnd()
--	self:TLCountReset()
--	self:UnregisterShortTermEvents()
end

--[[
do
	--Timers tank verified for both prot and fury warrior
	---@param self DBMMod
	---@param timer number
	---@param eventID number
	local function timersAll(self, timerExact, eventID)
		--Placeholder
		if self:IsRoundedTimer(timerExact, 21.5, 0.5) then

		else--Hardcode failed; disable and fall back to Blizzard API
			badStateDetected = true
			if DBM.Options.IgnoreBlizzAPI then
				DBM.Options.IgnoreBlizzAPI = false
				DBM:FireEvent("DBM_ResumeBlizzAPI")
			end
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000TormentsRise: Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
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
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventID or not eventState then return end
		local eventType, eventCount = self:TLCountFinish(eventID)
		if eventType and eventCount then
			if eventState == 1 and eventType == "void" then

			elseif eventState == 2 then--Finished
				if eventType == "void" then

				end
			elseif eventState == 3 then--Canceled
				self:TLCountCancel(eventID)
			end
		end
	end
end
--]]
