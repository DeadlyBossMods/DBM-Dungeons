local mod	= DBM:NewMod(427, "DBM-Party-Vanilla", DBM:IsPostCata() and 6 or 8, 232)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(12236)
mod:SetEncounterID(424)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 7964"
)

local warningSmokeBomb				= mod:NewSpellAnnounce(7964, 2)

local timerSmokeBombCD				= mod:NewCDTimer(14.6, 7964, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
--	timerSmokeBombCD:Start(1-delay)--Used near instant on pull
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(7964) and args:IsSrcTypeHostile() then
		warningSmokeBomb:Show()
		timerSmokeBombCD:Start()
	end
end
