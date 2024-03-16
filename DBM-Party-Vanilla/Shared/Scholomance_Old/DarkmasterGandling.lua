local mod	= DBM:NewMod("DarkmasterGandling", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(1853)
mod:SetEncounterID(mod:IsClassic() and 2801 or 463)
mod:SetZone(289)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 17950"
)

local warningShadowPortal		= mod:NewSpellAnnounce(17950, 2) -- Target seems unreliable

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(17950) then
		warningShadowPortal:Show()
	end
end
