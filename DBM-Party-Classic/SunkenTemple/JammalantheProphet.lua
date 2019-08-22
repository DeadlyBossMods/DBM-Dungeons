local mod	= DBM:NewMod(458, "DBM-Party-Classic", 11, 237)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(5710)--5711 Ogom the Wretched
mod:SetEncounterID(488)

mod:RegisterCombat("combat")

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START"
)

--local warningSoul					= mod:NewTargetAnnounce(32346, 2)

--local specWarnMaddeningCall			= mod:NewSpecialWarningInterrupt(86620, "HasInterrupt", nil, nil, 1, 2)

--local timerMaddeningCallCD			= mod:NewAITimer(180, 86620, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)

function mod:OnCombatStart(delay)
	--timerMaddeningCallCD:Start(1-delay)
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

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32346 then
		warningSoul:Show(args.destName)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 5711 then--Ogom the Wretched

	end
end

--]]
