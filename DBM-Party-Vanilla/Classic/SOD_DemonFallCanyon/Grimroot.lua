local mod	= DBM:NewMod("Grimroot", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3023)
mod:SetCreatureID(4275)

mod:RegisterCombat("combat")

-- Corrupted Tears is odd:
-- "<111.95 21:43:33> [UNIT_SPELLCAST_SUCCEEDED] Grimroot(29.2%-0.0%){Target:Unbanned} -Corrupted Tears- [[target:Cast-3-5252-2784-26746-460509-000292D8E5:460509]]",
-- "<111.95 21:43:33> [CLEU] SPELL_CAST_SUCCESS#68168#Creature-0-5252-2784-26746-226923-000012D5C6#Grimroot##nil#460509#Corrupted Tears#nil#nil#nil#nil#nil#nil",
-- "<111.95 21:43:33> [UNIT_TARGET] target#Grimroot#Target: Tandanu#TargetOfTarget: Grimroot",
-- "<114.95 21:43:36> [CLEU] SPELL_DAMAGE##nil#Player-5826-01FB73B2#Spec#460512#Corrupted Tears",
-- "<114.96 21:43:36> [CLEU] SPELL_AURA_APPLIED##nil#Player-5826-01FB73B2#Spec#460515#Corrupted Tears#DEBUFF#nil#nil#nil#nil#nil",
-- "<114.96 21:43:36> [UNIT_SPELLCAST_SUCCEEDED] PLAYER_SPELL{Spec} -Corrupted Tears- [[party2:Cast-3-5252-2784-26746-460515-000192D8E8:460515]]",
-- "<114.96 21:43:36> [CLEU] SPELL_CAST_SUCCESS##nil#Player-5826-01FB73B2#Spec#460515#Corrupted Tears#nil#nil#nil#nil#nil#nil",
-- Looks like he targeting someone for corrupted tears, but I probably dodged and someone else got hit?
-- And getting hit by it makes you cast a spell, that's a bit odd.
-- There's also SPELL_PERIODIC_DAMAGE if you just don't move.
-- My log has a case of SPELL_DAMAGE with no SPELL_AURA_APPLIED for it, so using SPELL_DAMAGE/MISSED.

-- Gloom seems very predictable
-- "Gloom-460727-npc:226923-000012D5C6 = pull:30.8, 30.8, 30.7",
-- "Gloom-460727-npc:226923-000012D91C = pull:30.8, 30.8",
-- Needs to be kicked, we did this once and got 30.7 instead of 30.8, I guess 30.7 timer is good enough

-- Tender's rage isn't predictable (but maybe it's based on health?)
-- "Tender's Rage-460703-npc:226923-000012D5C6 = pull:19.4, 44.8",
-- "Tender's Rage-460703-npc:226923-000012D91C = pull:23.5, 28.0",
-- "<87.01 21:47:15> [CLEU] SPELL_AURA_APPLIED#2632#Creature-0-5252-2784-26746-226923-000012D91C#Grimroot#Creature-0-5252-2784-26746-226923-000012D91C#Grimroot#460703#Tender's Rage#BUFF#nil#nil#nil#nil#nil",
-- "<94.53 21:47:23> [CLEU] SPELL_AURA_REFRESH#2632#Creature-0-5252-2784-26746-226923-000012D91C#Grimroot#Creature-0-5252-2784-26746-226923-000012D91C#Grimroot#460703#Tender's Rage#BUFF#nil#nil#nil#nil#nil",
-- "<102.52 21:47:31> [CLEU] SPELL_AURA_REMOVED#2632#Creature-0-5252-2784-26746-226923-000012D91C#Grimroot#Creature-0-5252-2784-26746-226923-000012D91C#Grimroot#460703#Tender's Rage#BUFF#nil#nil#nil#nil#nil",
-- Can be refreshed :o
-- It's a "Frenzy" effect so we can probably dispel it with Tranquilizing Shot once MC is out, fun mechanic


mod:RegisterEventsInCombat(
	"SPELL_DAMAGE 460512",
	"SPELL_PERIODIC_DAMAGE 460512",
	"SPELL_MISSED 460512",
	"SPELL_PERIODIC_MISSED 460512",
	"SPELL_CAST_SUCCESS 460509",
	"SPELL_CAST_START 460727",
	"SPELL_AURA_APPLIED 460703",
	"SPELL_AURA_REFRESH 460703",
	"SPELL_AURA_REMOVED 460703"
)

local specWarnGTFO		= mod:NewSpecialWarningGTFO(460512, nil, nil, nil, 1, 8)
local specWarnGloom		= mod:NewSpecialWarningInterrupt(460727, "HasInterrupt", nil, nil, 1, 2)
local specWarnFrenzy	= mod:NewSpecialWarningDispel(460703, "RemoveEnrage", nil, nil, 1, 2)

local yellTears			= mod:NewIconRepeatYell(460512)

local timerGloom		= mod:NewCDTimer(30.7, 460727, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerFrenzy		= mod:NewBuffActiveTimer(8, 460703, nil, nil, nil, 5)

local playerGuid = UnitGUID("player")
local playerName = UnitName("player")

function mod:OnCombatStart(delay)
	timerGloom:Start(30.8 - delay)
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 460512 and destGUID == playerGuid and self:AntiSpam(2.5, 1) then -- Spam every 3 ticks
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
mod.SPELL_PERIODIC_DAMAGE = mod.SPELL_DAMAGE
mod.SPELL_PERIODIC_MISSED = mod.SPELL_DAMAGE

-- TODO: i'm not sure if this is correct, the log above has the SPELL_AURA_APPLIED on a different player than the target
-- But the target was me, and I probably dodged, so worth trying.
function mod:CorruptedTearsTarget(target)
	if target == playerName then
		yellTears:Yell(8)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	-- FIXME: due to lack of boss infos/unit ids in classic the test for this doesn't work -- which is bad
	self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CorruptedTearsTarget", 0.1, 4)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(460727) then
		timerGloom:Start()
		specWarnGloom:Show(args.sourceName)
		specWarnGloom:Play("kickcast")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(460703) then
		specWarnFrenzy:Show(args.destName)
		specWarnFrenzy:Play("trannow")
		timerFrenzy:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpell(460703) then
		timerFrenzy:Stop()
	end
end

function mod:SPELL_AURA_REFRESH(args)
	if args:IsSpell(460703) then
		timerFrenzy:AddTime(8)
	end
end
