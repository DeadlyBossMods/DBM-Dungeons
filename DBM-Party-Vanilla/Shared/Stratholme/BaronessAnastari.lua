local mod	= DBM:NewMod(451, "DBM-Party-Vanilla", DBM:IsRetail() and 10 or 16, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10436)
mod:SetEncounterID(479)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_SUCCESS 17244",
	"SPELL_AURA_APPLIED 17244 16867 18327"
)

local warningBansheeCurse		= mod:NewTargetNoFilterAnnounce(16867, 2, nil, "RemoveCurse")
local warningSilence			= mod:NewTargetNoFilterAnnounce(18327, 2, nil, "RemoveMagic")

local specWarnPossess			= mod:NewSpecialWarningTargetChange(17244, nil, nil, nil, 1, 2)

--local timerPossessCD			= mod:NewAITimer(180, 17244, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)

--function mod:OnCombatStart(delay)
--	timerPossessCD:Start(1-delay)
--end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 17244 then
--		timerPossessCD:Start()
	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(17244) then
		specWarnPossess:Show(args.destName)
		specWarnPossess:Play("targetchange")
	elseif args:IsSpell(16867) then
		warningBansheeCurse:CombinedShow(0.5, args.destName)
	elseif args:IsSpell(18327) then
		warningSilence:CombinedShow(0.5, args.destName)
	end
end
