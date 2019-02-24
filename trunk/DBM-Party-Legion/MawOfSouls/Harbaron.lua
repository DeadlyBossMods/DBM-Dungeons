local mod	= DBM:NewMod(1512, "DBM-Party-Legion", 8, 727)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(96754)
mod:SetEncounterID(1823)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 194327",
--	"SPELL_AURA_REMOVED 194327",
	"SPELL_CAST_START 194231 194266 194216",
	"SPELL_CAST_SUCCESS 194325"
)

local warnFragment				= mod:NewTargetAnnounce(194327, 3)

local specWarnFragment			= mod:NewSpecialWarningSwitch(194327, "Dps", nil, nil, 1, 2)
local specWarnServitor			= mod:NewSpecialWarningSwitch(194231, "-Healer", nil, nil, 1, 2)
local specWarnVoidSnap			= mod:NewSpecialWarningInterrupt(194266, "HasInterrupt", nil, nil, 1, 2)
local specWarnScythe			= mod:NewSpecialWarningDodge(194216, nil, nil, nil, 2, 2)

local timerFragmentCD			= mod:NewCDTimer(30, 194327, nil, nil, nil, 3)
local timerServitorCD			= mod:NewCDTimer(23, 194231, nil, nil, nil, 1)--23-30

function mod:OnCombatStart(delay)
	timerServitorCD:Start(7-delay)
	timerFragmentCD:Start(19-delay)
end

function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 194327 then
		warnFragment:Show(args.destName)
		specWarnFragment:Show()
		specWarnFragment:Play("mobkill")
	end
end

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 194327 then

	end
end
--]]

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 194231 then
		specWarnServitor:Show()
		specWarnServitor:Play("bigmob")
		timerServitorCD:Start()
	elseif spellId == 194266 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnVoidSnap:Show(args.sourceName)
		specWarnVoidSnap:Play("kickcast")
	elseif spellId == 194216 then
		specWarnScythe:Show()
		specWarnScythe:Play("shockwave")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 194325 then
		timerFragmentCD:Start()
	end
end