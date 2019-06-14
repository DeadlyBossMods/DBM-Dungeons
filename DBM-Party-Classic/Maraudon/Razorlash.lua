local mod	= DBM:NewMod(424, "DBM-Party-Classic", 6, 232)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(12258)
mod:SetEncounterID(423)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 15976"
)

--It doesn't do that much damage, but maybe useful if doing it under leveled
local warningPuncture				= mod:NewSpellAnnounce(15976, 2, nil, false)

local timerPunctureCD				= mod:NewAITimer(180, 15976, nil, false, nil, 5, nil, DBM_CORE_TANK_ICON)

function mod:OnCombatStart(delay)
	timerPunctureCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 15976 then
		warningPuncture:Show()
		timerPunctureCD:Start()
	end
end
