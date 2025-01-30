if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("CreepingMalison", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3146)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

-- The GTFO warning uses in combat events on purpose despite the fire staying around after the fight.
-- The warning is just annoying if you are looking for the Relics after the fight.
mod:RegisterEventsInCombat(
	"SPELL_PERIODIC_DAMAGE 1222097",
	"SPELL_PERIODIC_MISSED 1222097",
	"SPELL_AURA_APPLIED 1222097"
)

-- This fight was completely free, just tank and spank.
-- Without a Shaman tank you should probably burn the eggs to avoid adds, that creates some fire on the floor to watch out for.

local specWarnGTFO	= mod:NewSpecialWarningGTFO(1222097, nil, nil, nil, 1, 8)

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 1222097 and destGUID == UnitGUID("player") and self:AntiSpam(3.5, "gtfo") then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(1222097) and args:IsPlayer() and self:AntiSpam(3.5, "gtfo") then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

