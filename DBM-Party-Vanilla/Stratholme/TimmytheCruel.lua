local mod	= DBM:NewMod(445, "DBM-Party-Classic", 10, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10808)
mod:SetEncounterID(474)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 8599"
)

local warningEnrage		= mod:NewTargetNoFilterAnnounce(8599, 2)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 8599 then
		warningEnrage:Show(args.destName)
	end
end
