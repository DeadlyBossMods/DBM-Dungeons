local mod	= DBM:NewMod(426, "DBM-Party-Classic", 1, 227)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(74565)
mod:SetEncounterID(1669)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 151159",
	"SPELL_AURA_APPLIED 150634"
)

local warningGrip				= mod:NewTargetAnnounce(150634, 2)
local warningDarknessCalls		= mod:NewSpellAnnounce(151159, 3)

function mod:SPELL_CAST_START(args)
	if args.spellId == 151159 then
		warningDarknessCalls:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 150634 then
		warningGrip:Show(args.destName)
	end
end
