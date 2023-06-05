local mod	= DBM:NewMod(1665, "DBM-Party-Legion", 5, 767)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(91004)
mod:SetEncounterID(1791)
mod:SetHotfixNoticeRev(20230529000000)
mod:SetUsedIcons(8)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 198496 198428 193375",
--	"SPELL_CAST_SUCCESS 216290",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 198496 or ability.id = 198428 or ability.id = 193375) and type = "begincast"
 or ability.id = 216290 and type = "cast"
  or (source.type = "NPC" and source.firstSeen = timestamp) and source.id = 100818 or (target.type = "NPC" and target.firstSeen = timestamp) and target.id = 100818
 or target.id = 100818 and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnStrikeofMountain			= mod:NewTargetAnnounce(216290, 2)
local warnBellowofDeeps				= mod:NewSpellAnnounce(193375, 2)--Change to special warning if they become important enough to switch to
local warnStanceofMountain			= mod:NewSpellAnnounce(216249, 2)

local specWarnSunder				= mod:NewSpecialWarningDefensive(198496, "Tank", nil, 2, 1, 2)
local specWarnStrikeofMountain		= mod:NewSpecialWarningDodge(216290, nil, nil, nil, 1, 2)
--local yellStrikeofMountain			= mod:NewYell(216290)

local timerSunderCD					= mod:NewCDTimer(7.5, 198496, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerStrikeCD					= mod:NewCDTimer(15, 216290, nil, nil, nil, 3)
local timerBelowofDeepsCD			= mod:NewCDTimer(33.9, 193375, nil, nil, nil, 1)
local timerStanceOfMountainCD		= mod:NewCDTimer(50, 216249, nil, nil, nil, 6)

local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerSunderCD:GetRemaining() < ICD then
		local elapsed, total = timerSunderCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerSunderCD extended by: "..extend, 2)
		timerSunderCD:Update(elapsed, total+extend)
	end
	if timerBelowofDeepsCD:GetRemaining() < ICD then
		local elapsed, total = timerBelowofDeepsCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerBelowofDeepsCD extended by: "..extend, 2)
		timerBelowofDeepsCD:Update(elapsed, total+extend)
	end
	if timerStrikeCD:GetRemaining() < ICD then
		local elapsed, total = timerStrikeCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerStrikeCD extended by: "..extend, 2)
		timerStrikeCD:Update(elapsed, total+extend)
	end
end

function mod:OnCombatStart(delay)
	timerSunderCD:Start(7-delay)
	timerStrikeCD:Start(15.8-delay)
	timerBelowofDeepsCD:Start(20.4-delay)
--	timerStanceOfMountainCD:Start(60-delay)--First one still seems kinda random, 35-60
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 198496 then
		specWarnSunder:Show()
		specWarnSunder:Play("defensive")
		timerSunderCD:Start()
		updateAllTimers(self, 4.8)
	elseif spellId == 198428 then
		specWarnStrikeofMountain:Show()
		specWarnStrikeofMountain:Play("watchstep")
		timerStrikeCD:Start()
		updateAllTimers(self, 4.8)
	elseif spellId == 193375 then
		warnBellowofDeeps:Show()
		timerBelowofDeepsCD:Start()
		updateAllTimers(self, 6)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 216290 then
		if args:IsPlayer() then
			specWarnStrikeofMountain:Show()
			specWarnStrikeofMountain:Play("targetyou")
			yellStrikeofMountain:Yell()
		else
			warnStrikeofMountain:Show(args.destName)
		end
	end
end
--]]

--"<430.63 21:52:24> [ENCOUNTER_START] 1791#Ularogg Cragshaper#8#5", -- [3535]
--"<490.86 21:53:24> [UNIT_SPELLCAST_SUCCEEDED] Ularogg Cragshaper(53.1%-0.0%){Target:Gimlly} -Stance of the Mountain- [[boss1:Cast-3-4249-1458-17779-198509-0011F25FB4:198509]]", -- [3764]
--"<490.86 21:53:24> [DBM_Announce] Stance of the Mountain#136182#spell#216249#1665#false", -- [3765]
--"<519.03 21:53:52> [UNIT_SPELLCAST_SUCCEEDED] Ularogg Cragshaper(50.7%-0.0%){Target:??} -Stance of the Mountain- [[boss1:Cast-3-4249-1458-17779-198631-0016F25FD0:198631]]", -- [3843]
--"<569.86 21:54:43> [UNIT_SPELLCAST_SUCCEEDED] Ularogg Cragshaper(12.1%-0.0%){Target:Gimlly} -Stance of the Mountain- [[boss1:Cast-3-4249-1458-17779-198509-0009F26003:198509]]", -- [4028]
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 198509 then--Stance of the Mountain
		warnStanceofMountain:Show()
		timerSunderCD:Stop()
		timerStrikeCD:Stop()
		timerBelowofDeepsCD:Stop()
	elseif spellId == 198631 then--Stance of mountain ending
		--All abilities are spell queued up and can be cast in any order coming out
		--timerSunderCD:Start(2)
		--timerStrikeCD:Start(2)
		--timerBelowofDeepsCD:Start(2)
		timerStanceOfMountainCD:Start(50)
	end
end
