local mod	= DBM:NewMod(748, "DBM-Party-Classic", 12, 239)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7023)
mod:SetEncounterID(1887)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 10072",
	"SPELL_AURA_APPLIED 9941"
)

local warningReflection				= mod:NewTargetNoFilterAnnounce(9941, 2)
local warningSplinteredObsidian		= mod:NewSpellAnnounce(10072, 2)

local timerSplinteredObsidianCD		= mod:NewAITimer(180, 10072, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)

function mod:OnCombatStart(delay)
	timerSplinteredObsidianCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 10072 and self:AntiSpam(3, 1) then
		warningSplinteredObsidian:Show()
		timerSplinteredObsidianCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 9941 and self:AntiSpam(3, args.destName) then
		warningReflection:Show(args.destName)
	end
end
