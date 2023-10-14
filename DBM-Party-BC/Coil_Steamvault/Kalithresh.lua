local mod	= DBM:NewMod(575, "DBM-Party-BC", 6, 261)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17798)
mod:SetEncounterID(1944)

local channelId
if not mod:IsRetail() then
	mod:SetModelID(20235)
	mod:SetModelScale(0.95)
	channelId = 31543
else
	channelId = -6001
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 31543",
	"SPELL_AURA_APPLIED 31534"
)

local WarnChannel		= mod:NewSpellAnnounce(channelId, 2, 31543)

local specWarnReflect	= mod:NewSpecialWarningReflect(31534, "-Melee", nil, nil, 1, 2)--CasterDps after new core

local timerReflect		= mod:NewBuffActiveTimer(8, 31534, nil, nil, nil, 5)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 31543 then
		WarnChannel:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 31534 then
		timerReflect:Start(args.destName)
		specWarnReflect:Show(args.destName)
		specWarnReflect:Play("stopattack")
	end
end
