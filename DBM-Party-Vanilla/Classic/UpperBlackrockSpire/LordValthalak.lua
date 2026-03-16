local mod	= DBM:NewMod("LordValthalak", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(16042)
mod:SetZone(229)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 27249"
)

local warnSummonAssassin		= mod:NewSpellAnnounce(27249, 2)

local timerSummonAssassin		= mod:NewAITimer(180, 27249, nil, nil, nil, 3)

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(27249) then
		warnSummonAssassin:Show()
		timerSummonAssassin:Start()
    end
end