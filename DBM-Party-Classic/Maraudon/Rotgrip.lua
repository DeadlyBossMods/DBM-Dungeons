local mod	= DBM:NewMod(430, "DBM-Party-Classic", 6, 232)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(13596)
mod:SetEncounterID(428)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 15976 16495"
)

--Puncture doesn't do that much damage, but maybe useful if doing it under leveled
local warningPuncture				= mod:NewSpellAnnounce(15976, 2, nil, false)
local warningFatalBite				= mod:NewSpellAnnounce(16495, 3)

local timerPunctureCD				= mod:NewAITimer(180, 15976, nil, false, nil, 5, nil, DBM_CORE_TANK_ICON)
local timerFatalBiteCD				= mod:NewAITimer(180, 16495, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)

function mod:OnCombatStart(delay)
	timerPunctureCD:Start(1-delay)
	timerFatalBiteCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 15976 then
		warningPuncture:Show()
		timerPunctureCD:Start()
	elseif args.spellId == 16495 then
		warningFatalBite:Show()
		timerFatalBiteCD:Start()
	end
end
