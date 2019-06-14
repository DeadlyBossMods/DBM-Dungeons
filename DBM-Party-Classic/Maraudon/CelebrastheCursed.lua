local mod	= DBM:NewMod(428, "DBM-Party-Classic", 6, 232)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(12225)
mod:SetEncounterID(425)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 21807",
	"SPELL_CAST_SUCCESS 21968",
	"SPELL_AURA_APPLIED 12747"
)

--TODO, Add https://www.wowhead.com/spell=21793/twisted-tranquility using right event?
local warningEntanglingRoots		= mod:NewTargetNoFilterAnnounce(12747, 2)
local warningCorruptForces			= mod:NewSpellAnnounce(21968, 2, nil, false)

local specWarnWrath					= mod:NewSpecialWarningInterrupt(21807, "HasInterrupt", nil, nil, 1, 2)

local timerWrathCD					= mod:NewAITimer(180, 21807, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)

function mod:OnCombatStart(delay)
	timerWrathCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 21807 then
		timerWrathCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWrath:Show(args.sourceName)
			specWarnWrath:Play("kickcast")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 21968 then
		warningCorruptForces:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 12747 then
		warningEntanglingRoots:Show(args.destName)
	end
end
