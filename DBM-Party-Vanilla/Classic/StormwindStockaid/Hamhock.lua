local mod	= DBM:NewMod("Hamhock", "DBM-Party-Vanilla", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(1717)
mod:SetZone(34)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 6742"
)

--TODO, add timer for chain lightning if it's not spam cast
local warningBloodlust				= mod:NewTargetNoFilterAnnounce(6742, 2)


function mod:OnCombatStart(delay)
end


function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(6742) and args:IsDestTypeHostile() then
		warningBloodlust:Show(args.destName)
	end
end
