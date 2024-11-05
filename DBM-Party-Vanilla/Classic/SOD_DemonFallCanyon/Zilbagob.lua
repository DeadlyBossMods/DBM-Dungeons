local mod	= DBM:NewMod("Zilbagob", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3029)
mod:SetCreatureID(226922)
mod:SetZone(2784)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 462272"
)

local specWarnGTFO = mod:NewSpecialWarningGTFO(462272, nil, nil, nil, 1, 8)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(462272) and args:IsPlayer() and self:AntiSpam(2.5, 1) then
		specWarnGTFO:Play("watchfeet")
		specWarnGTFO:Show(args.spellName)
	end
end
