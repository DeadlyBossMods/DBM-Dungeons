local mod	= DBM:NewMod("TheBeast", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10430)
mod:SetZone(229)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 14100"
)

local warnRoar		= mod:NewSpellAnnounce(14100, 2)

local timerRoar		= mod:NewAITimer(180, 14100, nil, nil, nil, 3)

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(14100) then
		warnRoar:Show()
		timerRoar:Start()
    end
end