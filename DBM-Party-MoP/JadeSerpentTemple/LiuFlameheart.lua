local mod	= DBM:NewMod(658, "DBM-Party-MoP", 1, 313)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56732)
mod:SetEncounterID(1416)
mod:SetHotfixNoticeRev(20221127000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 106797 106823 106841 106856 106864 396907",
	"SPELL_AURA_REMOVED 106797",
	"SPELL_DAMAGE 107110",
	"SPELL_MISSED 107110",
	"SPELL_PERIODIC_DAMAGE 118540",
	"SPELL_PERIODIC_MISSED 118540"
--	"UNIT_DIED"
)

--[[
(ability.id = 106797 or ability.id = 107045 or ability.id = 106823 or ability.id = 106841 or ability.id = 396907) and type = "begincast"
 or ability.id = 106797
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnDragonStrike			= mod:NewSpellAnnounce(106823, 2)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnJadeDragonStrike		= mod:NewSpellAnnounce(106841, 3)
local warnPhase3				= mod:NewPhaseAnnounce(3)

local specWarnDragonStrike		= mod:NewSpecialWarningDefensive(106823, nil, nil, nil, 1, 2)
local specWarnDragonKick		= mod:NewSpecialWarningDodge(106856, nil, nil, nil, 2, 2)
local specWarnJadeDragonStrike	= mod:NewSpecialWarningDefensive(106841, nil, nil, nil, 1, 2)
local specWarnJadeDragonKick	= mod:NewSpecialWarningDodge(106864, nil, nil, nil, 2, 2)
local specWarnJadeBreath		= mod:NewSpecialWarningDodge(396907, nil, nil, nil, 2, 2)
local specWarnGTFO				= mod:NewSpecialWarningGTFO(118540, nil, nil, nil, 1, 8)

local timerDragonStrikeCD		= mod:NewNextTimer(15.7, 106823, nil, nil, 2, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.HEALER_ICON)--Kicks affect entire group as well (which are part of tank combo)
local timerJadeDragonStrikeCD	= mod:NewNextTimer(15.7, 106841, nil, nil, 2, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.HEALER_ICON)--Kicks affect entire group as well (which are part of tank combo)

function mod:OnCombatStart(delay)
	timerDragonStrikeCD:Start(11.6-delay)
end

 function mod:SPELL_CAST_START(args)
	if args.spellId == 106797 then--Jade Essence (Phase 2 trigger)
		warnPhase2:Show()
		timerDragonStrikeCD:Cancel()
		timerJadeDragonStrikeCD:Start(2.7)
	elseif args.spellId == 106823 then--Phase 1 dragonstrike
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnDragonStrike:Show()
			specWarnDragonStrike:Play("defensive")
		else
			warnDragonStrike:Show()
		end
		timerDragonStrikeCD:Start()
	elseif args.spellId == 106841 then--phase 2 dragonstrike
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnJadeDragonStrike:Show()
			specWarnJadeDragonStrike:Play("defensive")
		else
			warnJadeDragonStrike:Show()
		end
		timerJadeDragonStrikeCD:Start()
	elseif spellId == 106856 then
		specWarnDragonKick:Show()
		if self:IsMelee() then
			specWarnDragonKick:Play("runout")
		end
		specWarnDragonKick:ScheduleVoice(1, "watchwave")
	elseif spellId == 106864 then
		specWarnJadeDragonKick:Show()
		if self:IsMelee() then
			specWarnJadeDragonKick:Play("runout")
		end
		specWarnJadeDragonKick:ScheduleVoice(1, "watchwave")
	elseif spellId == 396907 then
		specWarnJadeBreath:Show()
		specWarnJadeBreath:Play("breathsoon")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 106797 then--Jade Essence removed, (Phase 3 trigger)
		warnPhase3:Show()
		timerJadeDragonStrikeCD:Cancel()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 107110 and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 118540 and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
--12/18 19:35:56.323  UNIT_DIED,0000000000000000,nil,0x80000000,0x80000000,Creature-0-4218-960-7065-56732-00001FAC81,"Liu Flameheart",0xa48,0x0,0
--12/18 19:35:56.323  ENCOUNTER_END,1416,"Liu Flameheart",8,5,1,93650
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 56762 then--Fight ends when Yu'lon dies.
		DBM:EndCombat(self)
	end
end
--]]
