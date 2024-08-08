local mod	= DBM:NewMod("SMBGTrash", "DBM-Party-WoD", 6)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 152818 152964 153395 398150 153268 398206 156718 394512 164907",
	"SPELL_CAST_SUCCESS 394512",
	"SPELL_AURA_APPLIED 152819",
--	"SPELL_AURA_APPLIED_DOSE 339528",
--	"SPELL_AURA_REMOVED 339525",
	"UNIT_DIED"
)

--[[
(ability.id = 152818 or ability.id = 152964 or ability.id = 153395 or ability.id = 398150 or ability.id = 153268 or ability.id = 398206 or ability.id = 156718 or ability.id = 394512 or ability.id = 164907) and type = "begincast"
--]]
local warnVoidSlash							= mod:NewCastAnnounce(164907, 4, nil, nil, "Tank|Healer")
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

local timerShadowMendCD						= mod:NewCDNPTimer(8.5, 152818, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerVoidSlashCD						= mod:NewCDNPTimer(10.9, 164907, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerVoidEruptionsCD					= mod:NewCDNPTimer(19.4, 394512, nil, nil, nil, 3, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerNecroticBurstCD					= mod:NewCDNPTimer(19.4, 156718, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBodySlamCD						= mod:NewCDNPTimer(14.5, 153395, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 152818 then
		timerShadowMendCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnShadowMend:Show(args.sourceName)
			specWarnShadowMend:Play("kickcast")
		end
	elseif spellId == 398206 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDeathblast:Show(args.sourceName)
		specWarnDeathblast:Play("kickcast")
	elseif spellId == 156718 then
		timerNecroticBurstCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnNecroticBurst:Show(args.sourceName)
			specWarnNecroticBurst:Play("kickcast")
		end
	elseif spellId == 152964 and self:AntiSpam(3, 4) then
		warnVoidPulse:Show()
	elseif spellId == 153395 then
		timerBodySlamCD:Start(nil, args.sourceGUID)--NO clean cancel, cause mob doesn't die, it leaves
		if self:AntiSpam(5, 4) then
			if self.Options.SpecWarn153395dodge then
				specWarnBodySlam:Show()
				specWarnBodySlam:Play("shockwave")
			else
				warnBodySlam:Show()
			end
		end
	elseif spellId == 398150 and self:AntiSpam(5, 5) then
		warnDomination:Show()
	elseif spellId == 153268 and self:AntiSpam(5, 6) then
		warnExhume:Show()
	elseif spellId == 394512 then
		timerVoidEruptionsCD:Start(nil, args.sourceGUID)
	elseif spellId == 164907 then
		timerVoidSlashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnVoidSlash:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 394512 and self:AntiSpam(3, 2) then
		specWarnVoidEruptions:Show()
		specWarnVoidEruptions:Play("watchstep")
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

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 75713 then--Shadowmoon Bone-Mender
		timerShadowMendCD:Stop(args.destGUID)
	elseif cid == 75652 then--Void Spawn
		timerVoidEruptionsCD:Stop(args.destGUID)
	elseif cid == 76104 then--Corpse Spider
		timerNecroticBurstCD:Stop(args.destGUID)
	elseif cid == 76518 then--Ritual Bones
		timerVoidSlashCD:Stop(args.destGUID)
	end
end
