local mod	= DBM:NewMod("TheBeast", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10430)
mod:SetZone(229)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 14100"
)

local warnTerrifyingRoar		= mod:NewSpellAnnounce(14100, 2)

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(14100) then
		warnTerrifyingRoar:Show()
    end
end