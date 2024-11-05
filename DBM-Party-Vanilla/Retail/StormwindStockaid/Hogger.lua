local mod	= DBM:NewMod(464, "DBM-Party-Vanilla", 11, 238)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(46254)
mod:SetEncounterID(1144)
mod:SetZone(34)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 86620"
)

--local warningSoul	= mod:NewTargetAnnounce(32346, 2)

local specWarnMaddeningCall			= mod:NewSpecialWarningInterrupt(86620, "HasInterrupt", nil, nil, 1, 2)

local timerMaddeningCallCD			= mod:NewAITimer(180, 86620, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

function mod:OnCombatStart(delay)
	timerMaddeningCallCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 86620 then
		timerMaddeningCallCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMaddeningCall:Show(args.sourceName)
			specWarnMaddeningCall:Play("kickcast")
		end
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32346 then
		warningSoul:Show(args.destName)
	end
end--]]
