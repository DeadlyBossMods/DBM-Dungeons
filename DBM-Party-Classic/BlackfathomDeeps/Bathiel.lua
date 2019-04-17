local mod	= DBM:NewMod(437, "DBM-Party-Classic", 1, 227)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(74728)
mod:SetEncounterID(1671)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 150020"
)

local warningWaters			= mod:NewSpellAnnounce(150020, 3)

function mod:SPELL_CAST_START(args)
	if args.spellId == 150020 then
		warningWaters:Show()
	end
end
