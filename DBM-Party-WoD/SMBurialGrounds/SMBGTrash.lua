local mod	= DBM:NewMod("SMBGTrash", "DBM-Party-WoD", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 152818 152964 153395 398150 153268 398206 156718",
	"SPELL_CAST_SUCCESS 394512",
	"SPELL_AURA_APPLIED 152819"
--	"SPELL_AURA_APPLIED_DOSE 339528",
--	"SPELL_AURA_REMOVED 339525"
)

local warnDomination						= mod:NewCastAnnounce(398150, 4)
local warnExhume							= mod:NewCastAnnounce(153268, 2)
local warnVoidPulse							= mod:NewSpellAnnounce(152964, 3)
local warnBodySlam							= mod:NewCastAnnounce(153395, 4)

--local yellConcentrateAnima				= mod:NewYell(339525)
--local yellConcentrateAnimaFades			= mod:NewShortFadesYell(339525)
local specWarnShadowWordFrailty				= mod:NewSpecialWarningYou(152819, nil, nil, nil, 1, 2)
local specWarnShadowWordFrailtyDispel		= mod:NewSpecialWarningDispel(152819, "RemoveMagic", nil, nil, 1, 2)
local specWarnShadowMend					= mod:NewSpecialWarningInterrupt(152818, "HasInterrupt", nil, nil, 1, 2)
local specWarnDeathblast					= mod:NewSpecialWarningInterrupt(398206, "HasInterrupt", nil, nil, 1, 2)
local specWarnNecroticBurst					= mod:NewSpecialWarningInterrupt(156718, "HasInterrupt", nil, nil, 1, 2)
local specWarnVoidEruptions					= mod:NewSpecialWarningDodge(394512, nil, nil, nil, 2, 2)
local specWarnBodySlam						= mod:NewSpecialWarningDodge(153395, "Tank", nil, nil, 2, 2)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 152818 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnShadowMend:Show(args.sourceName)
		specWarnShadowMend:Play("kickcast")
	elseif spellId == 398206 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDeathblast:Show(args.sourceName)
		specWarnDeathblast:Play("kickcast")
	elseif spellId == 156718 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnNecroticBurst:Show(args.sourceName)
		specWarnNecroticBurst:Play("kickcast")
	elseif spellId == 152964 and self:AntiSpam(3, 4) then
		warnVoidPulse:Show()
	elseif spellId == 153395 and self:AntiSpam(5, 4) then
		if self.Options.SpecWarn153395dodge then
			specWarnBodySlam:Show()
			specWarnBodySlam:Play("shockwave")
		else
			warnBodySlam:Show()
		end
	elseif spellId == 398150 and self:AntiSpam(5, 5) then
		warnDomination:Show()
	elseif spellId == 153268 and self:AntiSpam(5, 6) then
		warnExhume:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 394512 and self:AntiSpam(3, 2) then
		specWarnShadowMend:Show()
		specWarnShadowMend:Play("watchstep")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 152819 then
		if args:IsPlayer() then
			specWarnShadowWordFrailty:Show()
			specWarnShadowWordFrailty:Play("targetyou")
		elseif self:CheckDispelFilter("magic") then
			specWarnShadowWordFrailtyDispel:Show(args.destName)
			specWarnShadowWordFrailtyDispel:Play("helpdispel")
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 339525 and args:IsPlayer() then

	end
end
--]]
