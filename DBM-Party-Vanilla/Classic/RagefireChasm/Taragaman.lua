local mod	= DBM:NewMod("Taragaman", "DBM-Party-Vanilla", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(11520)
--mod:SetEncounterID(1446)
mod:SetZone(389)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 18072 11970"
)

local warningUppercut			= mod:NewSpellAnnounce(18072, 3, nil, "Tank", 2)
local warningFireNova			= mod:NewSpellAnnounce(11970, 3)

local timerUppercutCD			= mod:NewAITimer(180, 18072, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFireNovaCD			= mod:NewAITimer(180, 11970, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

function mod:OnCombatStart(delay)
	timerUppercutCD:Start(1-delay)
	timerFireNovaCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(18072) then
		warningUppercut:Show()
		timerUppercutCD:Start()
	elseif args:IsSpell(11970) then
		warningFireNova:Show()
		timerFireNovaCD:Start()
	end
end
