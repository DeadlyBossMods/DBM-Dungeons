local mod	= DBM:NewMod(578, "DBM-Party-BC", 5, 262)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17826)
mod:SetEncounterID(1947)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 31429 34971"
)

local warnRoar		= mod:NewSpellAnnounce(31429, 2)
local warnFrenzy	= mod:NewSpellAnnounce(34971, 4)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 31429 then
		warnRoar:Show()
	elseif args.spellId == 34971 then
		warnFrenzy:Show()
	end
end
