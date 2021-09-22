local mod	= DBM:NewMod(536, "DBM-Party-BC", 8, 250)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(22930)
mod:SetEncounterID(250)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 36405"
)

local warnStomp	= mod:NewSpellAnnounce(36405, 2)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 36405 then
		warnStomp:Show()
	end
end
