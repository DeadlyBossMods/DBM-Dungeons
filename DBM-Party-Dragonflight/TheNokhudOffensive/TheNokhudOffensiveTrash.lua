local mod	= DBM:NewMod("TheNokhudOffensiveTrash", "DBM-Party-Dragonflight", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 387145 386024 387127 384336 387629 387614 387411 382233 373395 383823 384365 384476 386694 387125 387440",
	"SPELL_AURA_APPLIED 395035 334610 386223"
--	"SPELL_AURA_APPLIED_DOSE 339528",
--	"SPELL_AURA_REMOVED 339525"
)

--TODO, https://www.wowhead.com/beta/spell=381683/swift-stab ?
--TODO, target scan https://www.wowhead.com/beta/spell=387127/chain-lightning ?
--Lady's Trash, minus bottled anima, which will need a unit event to detect it looks like
--local warnConcentrateAnima					= mod:NewTargetNoFilterAnnounce(339525, 3)
local warnTotemicOverload					= mod:NewCastAnnounce(387145, 3)
local warnChantoftheDead					= mod:NewCastAnnounce(387614, 3)
local warnTempest							= mod:NewCastAnnounce(373395, 4)
local warnDeathBoltVolley					= mod:NewCastAnnounce(387411, 3)
local warnBloodcurdlingShout				= mod:NewCastAnnounce(373395, 3)
local warnRallytheClan						= mod:NewCastAnnounce(383823, 4)--Has to be stunned/disrupted
local warnDisruptiveShout					= mod:NewCastAnnounce(384365, 4)
local warnStormsurge						= mod:NewCastAnnounce(386694, 3)
local warnThunderstrike						= mod:NewCastAnnounce(387125, 3, nil, nil, "Tank")
local warnDesecratingRoar					= mod:NewCastAnnounce(387440, 4)--Has to be stunned/disrupted

local specWarnShatterSoul					= mod:NewSpecialWarningMoveTo(395035, nil, nil, nil, 1, 2)
local specWarnChainLightning				= mod:NewSpecialWarningMoveAway(387127, nil, nil, nil, 1, 2)
local yellChainLightning					= mod:NewYell(387127)
local specWarnHuntPrey						= mod:NewSpecialWarningYou(334610, nil, nil, nil, 1, 2)--This might throw duplicate spell alert in debug, that's cause it is in fact used in necrotic wake too
local specWarnWarStomp						= mod:NewSpecialWarningDodge(384336, nil, nil, nil, 2, 2)
local specWarnBroadStomp					= mod:NewSpecialWarningDodge(382233, nil, nil, nil, 2, 2)
local specWarnRottingWind					= mod:NewSpecialWarningDodge(387629, nil, nil, nil, 2, 2)
local specWarnRainofArrows					= mod:NewSpecialWarningDodge(384476, nil, nil, nil, 2, 2)
--local yellConcentrateAnimaFades				= mod:NewShortFadesYell(339525)
--local specWarnSharedSuffering				= mod:NewSpecialWarningYou(339607, nil, nil, nil, 1, 2)
local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
local specWarnTempest						= mod:NewSpecialWarningInterrupt(386024, "HasInterrupt", nil, nil, 1, 2)
local specWarnDeathBoltVolley				= mod:NewSpecialWarningInterrupt(387411, "HasInterrupt", nil, nil, 1, 2)
local specWarnBloodcurdlingShout			= mod:NewSpecialWarningInterrupt(373395, "HasInterrupt", nil, nil, 1, 2)
local specWarnDisruptiveShout				= mod:NewSpecialWarningInterrupt(384365, "HasInterrupt", nil, nil, 1, 2)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:CLTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnChainLightning:Show()
			specWarnChainLightning:Play("runout")
		end
		yellChainLightning:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 387145 and self:AntiSpam(5, 4) then
		warnTotemicOverload:Show()
	elseif spellId == 386024 then
		if self.Options.SpecWarn386024interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTempest:Show(args.sourceName)
			specWarnTempest:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnTempest:Show()
		end
	elseif spellId == 387411 then
		if self.Options.SpecWarn387411interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDeathBoltVolley:Show(args.sourceName)
			specWarnDeathBoltVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDeathBoltVolley:Show()
		end
	elseif spellId == 373395 then
		if self.Options.SpecWarn373395interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBloodcurdlingShout:Show(args.sourceName)
			specWarnBloodcurdlingShout:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBloodcurdlingShout:Show()
		end
	elseif spellId == 383823 and self:AntiSpam(3, 5) then
		warnRallytheClan:Show()
	elseif spellId == 387440 and self:AntiSpam(3, 5) then
		warnDesecratingRoar:Show()
	elseif spellId == 384365 then
		if self.Options.SpecWarn384365interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDisruptiveShout:Show(args.sourceName)
			specWarnDisruptiveShout:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDisruptiveShout:Show()
		end
	elseif spellId == 387127 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CLTarget", 0.1, 8)
	elseif spellId == 384336 and self:AntiSpam(3, 2) then
		specWarnWarStomp:Show()
		specWarnWarStomp:Play("watchstep")
	elseif spellId == 384476 and self:AntiSpam(3, 2) then
		specWarnRainofArrows:Show()
		specWarnRainofArrows:Play("watchstep")
	elseif spellId == 387629 and self:AntiSpam(3, 2) then
		specWarnRottingWind:Show()
		specWarnRottingWind:Play("shockwave")
	elseif spellId == 382233 and self:AntiSpam(3, 2) then
		specWarnBroadStomp:Show()
		specWarnBroadStomp:Play("shockwave")
	elseif spellId == 387614 and self:AntiSpam(5, 6) then
		warnChantoftheDead:Show()
	elseif spellId == 386694 and self:AntiSpam(3, 6) then
		warnStormsurge:Show()
	elseif spellId == 387125 and self:AntiSpam(3, 5) then
		warnThunderstrike:Show()
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 395035 and args:IsPlayer() then
		specWarnShatterSoul:Show(L.Soul)
		specWarnShatterSoul:Play("targetyou")
	elseif spellId == 334610 and args:IsPlayer() and not self:IsTank() and self:AntiSpam(3, 5) then
		specWarnHuntPrey:Show()
		specWarnHuntPrey:Play("targetyou")
	elseif spellId == 386223 and args:IsDestTypeHostile() and self:AntiSpam(3, 5) then
		specWarnStormshield:Show(args.destName)
		specWarnStormshield:Play("helpdispel")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
