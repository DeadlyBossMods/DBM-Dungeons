local mod	= DBM:NewMod(658, "DBM-Party-MoP", 1, 313)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56732)
mod:SetEncounterID(1416)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 106797",
	"SPELL_CAST_SUCCESS 106823 106841",
	"SPELL_AURA_REMOVED 106797",
	"SPELL_DAMAGE 107110",
	"SPELL_MISSED 107110",
	"SPELL_PERIODIC_DAMAGE 118540",
	"SPELL_PERIODIC_MISSED 118540",
	"UNIT_DIED"
)

--[[
(ability.id = 106797 or ability.id = 107045) and type = "begincast"
 or (ability.id = 106823 or ability.id = 106841) and type = "cast"
 or ability.id = 106797
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnDragonStrike			= mod:NewSpellAnnounce(106823, 2)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnJadeDragonStrike		= mod:NewSpellAnnounce(106841, 3)
local warnPhase3				= mod:NewPhaseAnnounce(3)

local specWarnGTFO				= mod:NewSpecialWarningGTFO(118540, nil, nil, nil, 1, 8)

local timerDragonStrikeCD		= mod:NewNextTimer(15.7, 106823, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerJadeDragonStrikeCD	= mod:NewNextTimer(15.7, 106841, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerDragonStrikeCD:Start(11.6-delay)
end

 function mod:SPELL_CAST_START(args)
	if args.spellId == 106797 then--Jade Essence (Phase 2 trigger)
		warnPhase2:Show()
		timerDragonStrikeCD:Cancel()
		timerJadeDragonStrikeCD:Start(2.7)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 106823 then--Phase 1 dragonstrike
		warnDragonStrike:Show()
		timerDragonStrikeCD:Start()
	elseif args.spellId == 106841 then--phase 2 dragonstrike
		warnJadeDragonStrike:Show()
		timerJadeDragonStrikeCD:Start()
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

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 56762 then--Fight ends when Yu'lon dies.
		DBM:EndCombat(self)
	end
end
