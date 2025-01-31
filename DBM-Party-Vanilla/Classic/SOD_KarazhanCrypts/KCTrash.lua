if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("KCTrash", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2875)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_PERIODIC_DAMAGE 17742 1222939",
	"SPELL_PERIODIC_MISSED 17742 1222939",
	"SPELL_AURA_APPLIED 17742 1222939"
)

-- Notable Trash abilities

-- Thunderclap
-- Slows casting and attacks, annoying, but timer rather random
-- "Thunderclap-15588-npc:238191-00019A42B7 = pull:105.5, 19.4",
-- "Thunderclap-15588-npc:238191-00021A42B7 = pull:202.1, 16.2, 25.9, 29.1",

-- Disease clouds
-- Same spell ID as Scholomance, also just 350 DPS, but harder to see in the darkness and annoying to heal if half the group stands in it.
-- "<118.43 16:16:05> [CLEU] SPELL_AURA_APPLIED#Creature-0-5209-2875-4757-239725-00001A4631#[DNT] Disease Summon#Player-5827-0272A77A#Tandanu#17742#Cloud of Disease#DEBUFF#nil#nil#nil#nil#nil",
-- "<119.43 16:16:06> [CLEU] SPELL_PERIODIC_DAMAGE#Creature-0-5209-2875-4757-239725-00001A4631#[DNT] Disease Summon#Player-5827-0272A77A#Tandanu#17742#Cloud of Disease",

-- Fiery Remnant
-- Fire on ground, don't stand in it. It's cast by the player themselves, lol.
-- "<164.22 19:50:39> [CLEU] SPELL_AURA_APPLIED##nil#Player-5827-01CD3776#Xiga#1222939#Fiery Remnant#DEBUFF#nil#nil#nil#nil#nil",
-- "<164.22 19:50:39> [UNIT_SPELLCAST_SUCCEEDED] PLAYER_SPELL{Xiga} -Fiery Remnant- [[party2:Cast-3-5252-2875-24589-1222939-00029BC9FF:1222939]]",
-- "<164.71 19:50:40> [CLEU] SPELL_PERIODIC_DAMAGE##nil#Player-5827-01CD3776#Xiga#1222939#Fiery Remnant",


-- Can't use the "block" here because it's not yet in Core. Maybe time to merge.
local specWarnGTFO	= mod:NewSpecialWarningGTFO(17742, nil, nil, nil, 1, 8)

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if (spellId == 17742 or spellId == 1222939) and destGUID == UnitGUID("player") and self:AntiSpam(3.5, "gtfo") then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(17742, 1222939) and args:IsPlayer() and self:AntiSpam(3.5, "gtfo") then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
