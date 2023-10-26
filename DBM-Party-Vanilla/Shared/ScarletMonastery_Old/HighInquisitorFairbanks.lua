local mod	= DBM:NewMod("Fairbanks", "DBM-Party-Vanilla", DBM:IsRetail() and 17 or 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(4542)
mod:SetEncounterID(449)
mod:SetZone(189)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 8282"
)

local warningCurseofBlood			= mod:NewTargetNoFilterAnnounce(8282, 2, nil, "RemoveCurse")

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(8282) then
		warningCurseofBlood:Show(args.destName)
	end
end
