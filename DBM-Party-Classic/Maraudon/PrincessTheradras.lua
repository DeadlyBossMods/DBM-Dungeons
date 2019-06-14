local mod	= DBM:NewMod(431, "DBM-Party-Classic", 6, 232)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(12201)
mod:SetEncounterID(429)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 21832",
	"SPELL_CAST_SUCCESS 21869 21909"
--	"SPELL_AURA_APPLIED 12747"
)

--TODO, fear spread diff ID from initial target? if so, announce initial target
--TODO, target scan Boulder?
--local warningRepulsiveGaze		= mod:NewTargetNoFilterAnnounce(21869, 2)
local warningRepulsiveGaze			= mod:NewSpellAnnounce(21869, 2)
local warningBoulder				= mod:NewSpellAnnounce(21832, 2)
local warningDustField				= mod:NewSpellAnnounce(21909, 2)

--local specWarnWrath					= mod:NewSpecialWarningInterrupt(21807, "HasInterrupt", nil, nil, 1, 2)

local timerRespulsiveGazeCD			= mod:NewAITimer(180, 21869, nil, nil, nil, 3)
local timerBoulderCD				= mod:NewAITimer(180, 21832, nil, nil, nil, 3)
local timerDustFieldCD				= mod:NewAITimer(180, 21909, nil, nil, nil, 2)

function mod:OnCombatStart(delay)
	timerRespulsiveGazeCD:Start(1-delay)
	timerBoulderCD:Start(1-delay)
	timerDustFieldCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 21832 then
		warningBoulder:Show()
		timerBoulderCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 21869 then
		warningRepulsiveGaze:Show()
		timerRespulsiveGazeCD:Start()
	elseif args.spellId == 21909 then
		warningDustField:Show()
		timerDustFieldCD:Start()
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 21869 then
		warningRepulsiveGaze:Show(args.destName)
	end
end
--]]
