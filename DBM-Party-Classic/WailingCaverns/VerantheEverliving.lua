local mod	= DBM:NewMod(480, "DBM-Party-Classic", 14, 240)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(5775)
mod:SetEncounterID(591)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 8142"
)

local warnVines			= mod:NewSpellAnnounce(8142, 2)

local timerVinesCD		= mod:NewAITimer(180, 8142, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)

function mod:OnCombatStart(delay)
	timerVinesCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 8142 then
		warnVines:Show(args.sourceName)
		timerVinesCD:Start()
	end
end
