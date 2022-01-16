local mod	= DBM:NewMod(455, "DBM-Party-Classic", 10, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10439)
mod:SetEncounterID(483)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 17307 5568"
)

local warningKnockout			= mod:NewSpellAnnounce(17307, 2)
local warningTrample			= mod:NewSpellAnnounce(5568, 2)

local timerKnockoutCD			= mod:NewAITimer(180, 17307, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerTrampleCD			= mod:NewAITimer(180, 5568, nil, nil, nil, 2)

function mod:OnCombatStart(delay)
	timerKnockoutCD:Start(1-delay)
	timerTrampleCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 17307 then
		warningKnockout:Show()
		timerKnockoutCD:Start()
	elseif args.spellId == 5568 then
		warningTrample:Show()
		timerTrampleCD:Start()
	end
end
