local mod	= DBM:NewMod(1144, "DBM-Party-Classic", 1, 227)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(74988)
mod:SetEncounterID(1670)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 149955"
)

local specWarnDevouringBlackness			= mod:NewSpecialWarningInterrupt(149955, "HasInterrupt", nil, nil, 1, 2)

local timerDevouringBlacknessCD			= mod:NewAITimer(180, 149955, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)

function mod:OnCombatStart(delay)
	timerDevouringBlacknessCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	timerDevouringBlacknessCD:Start()
	if args.spellId == 149955 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDevouringBlackness:Show(args.sourceName)
		specWarnDevouringBlackness:Play("kickcast")
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32346 then
		warningSoul:Show(args.destName)
	end
end--]]