local mod	= DBM:NewMod(2475, "DBM-Party-Dragonflight", 2, 1197)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(184580, 184581, 184582)
mod:SetEncounterID(2555)
--mod:SetUsedIcons(1, 2, 3)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20230508000000)
mod:SetMinSyncRevision(20230508000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 369573 369563 369791 369677 375924",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 369602 377825",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED"
	"SPELL_PERIODIC_DAMAGE 377825",
	"SPELL_PERIODIC_MISSED 377825"
)

--TODO, verify target scanners. If they work, maybe upgrade it to UNIT_TARGET method
--TODO, can wild cleave be dodged? Once known, create special warning to dodge it or defensive it.
--TODO, verify defensive bulwark and if it's actually interruptable
--https://www.warcraftlogs.com/reports/wjYgPmDaLMxqJWFN#fight=last&pins=2%24Off%24%23244F4B%24expression%24(ability.id%20%3D%20369573%20or%20ability.id%20%3D%20369563%20or%20ability.id%20%3D%20369791%20or%20ability.id%20%3D%20369677%20or%20ability.id%20%3D%20375924)%20and%20type%20%3D%20%22begincast%22%20%20or%20ability.id%20%3D%20369602%20%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
--[[
(ability.id = 369573 or ability.id = 369563 or ability.id = 369791 or ability.id = 369677 or ability.id = 375924) and type = "begincast"
 or ability.id = 369602
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Baelog
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24740))
local warnHeavyArrow							= mod:NewTargetNoFilterAnnounce(369573, 3)
local warnWildCleave							= mod:NewSpellAnnounce(369563, 3, nil, "Tank")

local specWarnHeavyArrow						= mod:NewSpecialWarningDodge(369573, nil, nil, nil, 2, 2)

local timerHeavyArrowCD							= mod:NewCDTimer(20.6, 369573, nil, nil, nil, 3)
local timerWildCleaveCD							= mod:NewCDTimer(17, 369563, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Council fights can be messy, on for everyone for now

--Eric "The Swift"
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24781))
local specWarnSkullcracker						= mod:NewSpecialWarningDodge(369791, nil, nil, nil, 2, 2)

local timerSkullcrackerCD						= mod:NewCDTimer(26.6, 369791, nil, nil, nil, 3)
--Olaf
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24782))
local warnRicochetingShield						= mod:NewTargetNoFilterAnnounce(369677, 3)

local specWarnRicochetingShield					= mod:NewSpecialWarningYou(369677, nil, nil, nil, 1, 2)
local yellRicochetingShield						= mod:NewYell(369677)
local specWarnDefensiveBulwark					= mod:NewSpecialWarningInterrupt(369602, "HasInterrupt", nil, nil, 1, 2)

local timerRicochetingShieldCD					= mod:NewCDTimer(16.9, 369677, nil, nil, nil, 3)
local timerDefensiveBulwarkCD					= mod:NewCDTimer(35, 369602, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--Longboat Raid!
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24783))
local timerLongboatRaidCD						= mod:NewCDTimer(27.4, 375924, nil, nil, nil, 6)

local specWarnGTFO								= mod:NewSpecialWarningGTFO(377825, nil, nil, nil, 1, 8)

--local berserkTimer							= mod:NewBerserkTimer(600)

mod:AddRangeFrameOption(5, 369677)
--mod:AddInfoFrameOption(361651, true)
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

function mod:ShieldTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnRicochetingShield:Show()
		specWarnRicochetingShield:Play("targetyou")
		yellRicochetingShield:Yell()
	else
		warnRicochetingShield:Show(targetname)
	end
end

local function scanBosses(self, delay)
	for i = 1, 3 do
		local unitID = "boss"..i
		if UnitExists(unitID) then
			local cid = self:GetUnitCreatureId(unitID)
			local bossGUID = UnitGUID(unitID)
			if cid == 184581 then--Baelog
				timerWildCleaveCD:Start(7.1-delay, bossGUID)
				timerHeavyArrowCD:Start(19.6-delay, bossGUID)
			elseif cid == 184580 then--Olaf
				timerRicochetingShieldCD:Start(11.1-delay, bossGUID)
				timerDefensiveBulwarkCD:Start(16.2-delay, bossGUID)
			elseif cid == 184582 then--Eric "The Swift"
				timerSkullcrackerCD:Start(5-delay, bossGUID)
			end
		end
	end
end

function mod:OnCombatStart(delay)
	self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss guids
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(5)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 369573 then
		specWarnHeavyArrow:Show()
		specWarnHeavyArrow:Play("shockwave")
		timerHeavyArrowCD:Start(nil, args.sourceGUID)
	elseif spellId == 369563 then
		warnWildCleave:Show()
		timerWildCleaveCD:Start(nil, args.sourceGUID)
	elseif spellId == 369791 then
		specWarnSkullcracker:Show()
		specWarnSkullcracker:Play("chargemove")
		timerSkullcrackerCD:Start(nil, args.sourceGUID)
	elseif spellId == 369677 then
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "ShieldTarget", 0.1, 8, true)
		timerRicochetingShieldCD:Start(nil, args.sourceGUID)
	elseif spellId == 375924 then
		local bossUid = DBM:GetUnitIdFromGUID(args.sourceGUID)
		local bossPower = UnitPower(bossUid)--If boss power is ever less than 100 when this is cast, they're defeated
		if bossPower == 100 and self:AntiSpam(8, 1) then--at least one caster is alive, start next timer
			timerLongboatRaidCD:Start(79)
		end
		local cid = self:GetCIDFromGUID(args.sourceGUID)
		if cid == 184581 then--Baelog
			timerHeavyArrowCD:Stop(args.sourceGUID)
			timerWildCleaveCD:Stop(args.sourceGUID)
			if bossPower == 100 then--Alive, restart timers
				timerWildCleaveCD:Start(24.9, args.sourceGUID)
				timerHeavyArrowCD:Start(35, args.sourceGUID)
			end
		elseif cid == 184580 then--Olaf
			timerRicochetingShieldCD:Stop(args.sourceGUID)
			timerDefensiveBulwarkCD:Stop(args.sourceGUID)
			if bossPower == 100 then--Alive, restart timers
				timerRicochetingShieldCD:Start(30, args.sourceGUID)
				timerDefensiveBulwarkCD:Start(35, args.sourceGUID)
			end
		elseif cid == 184582 then--Eric "The Swift"
			timerSkullcrackerCD:Stop(args.sourceGUID)
			if bossPower == 100 then--Alive, restart timers
				timerSkullcrackerCD:Start(24.9, args.sourceGUID)
			end
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 362805 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 369602 then
		timerDefensiveBulwarkCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDefensiveBulwark:Show(args.sourceName)
			specWarnDefensiveBulwark:Play("kickcast")
		end
	elseif spellId == 377825 and args:IsPlayer() and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 377825 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
