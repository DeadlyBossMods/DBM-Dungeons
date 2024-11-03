local mod	= DBM:NewMod(454, "DBM-Party-Vanilla", DBM:IsPostCata() and 10 or 16, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10435)
mod:SetEncounterID(482)
mod:SetZone(329)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 10887 14099"
)

local warningCrowdPummel		= mod:NewSpellAnnounce(10887, 2)
local warningMightyBlow			= mod:NewSpellAnnounce(14099, 2, nil, "Tank", 2)

local timerCrowdPummelCD		= mod:NewAITimer(180, 10887, nil, nil, nil, 2)
local timerMightyBlowCD			= mod:NewAITimer(180, 14099, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerCrowdPummelCD:Start(1-delay)
	timerMightyBlowCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(10887) then
		warningCrowdPummel:Show()
		timerCrowdPummelCD:Start()
	elseif args:IsSpell(14099) then
		warningMightyBlow:Show()
		timerMightyBlowCD:Start()
	end
end
