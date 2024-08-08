local mod	= DBM:NewMod("TheNokhudOffensiveTrash", "DBM-Party-Dragonflight", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 387145 386024 387127 384336 387629 387614 387411 382233 373395 383823 384365 386694 387125 387440 436841 387596 384134 381683 388801",
	"SPELL_CAST_SUCCESS 384476 382267",
	"SPELL_AURA_APPLIED 395035 334610 386223 345561",
--	"SPELL_AURA_APPLIED_DOSE 339528",
--	"SPELL_AURA_REMOVED 339525",
	"UNIT_DIED"
)

--TODO, target scan https://www.wowhead.com/beta/spell=387127/chain-lightning ?
--Lady's Trash, minus bottled anima, which will need a unit event to detect it looks like
--TODO, uncomment/update rain of arrows timer for season 4
--[[
(ability.id = 373395 or ability.id = 387411 or ability.id = 388801 or ability.id = 373395 or ability.id = 383823 or ability.id = 384365 or ability.id = 387440 or ability.id = 384336 or ability.id = 386024) and type = "begincast"
 or (ability.id = 382267 or ability.id = 384476) and type = "cast"
--]]
local warnTotemicOverload					= mod:NewCastAnnounce(387145, 3)
local warnChantoftheDead					= mod:NewCastAnnounce(387614, 3)
local warnTempest							= mod:NewCastAnnounce(386024, 4)
local warnDeathBoltVolley					= mod:NewCastAnnounce(387411, 3)
local warnBloodcurdlingShout				= mod:NewCastAnnounce(373395, 3)
local warnRallytheClan						= mod:NewCastAnnounce(383823, 4, nil, nil, nil, nil, nil, 3)--Has to be stunned/disrupted
local warnDisruptiveShout					= mod:NewCastAnnounce(384365, 3)
local warnStormsurge						= mod:NewCastAnnounce(386694, 3)
local warnThunderstrike						= mod:NewCastAnnounce(387125, 3, nil, nil, "Tank")
local warnSwiftStab							= mod:NewCastAnnounce(381683, 3)
local warnDesecratingRoar					= mod:NewCastAnnounce(387440, 4, nil, nil, nil, nil, nil, 3)--Has to be stunned/disrupted
local warnRottingWind						= mod:NewCastAnnounce(436841, 3)
local warnSwiftWind							= mod:NewCastAnnounce(387596, 3)

local specWarnShatterSoul					= mod:NewSpecialWarningMoveTo(395035, nil, nil, nil, 1, 2)
local specWarnChainLightning				= mod:NewSpecialWarningMoveAway(387127, nil, nil, nil, 1, 2)
local yellChainLightning					= mod:NewYell(387127)
local specWarnVehementCharge				= mod:NewSpecialWarningMoveAway(382277, nil, nil, nil, 1, 2)
local yellVehementCharge					= mod:NewYell(382277)
local specWarnHuntPrey						= mod:NewSpecialWarningYou(334610, nil, nil, nil, 1, 2)--This might throw duplicate spell alert in debug, that's cause it is in fact used in necrotic wake too
local specWarnWarStomp						= mod:NewSpecialWarningDodge(384336, nil, nil, nil, 2, 2)
local specWarnBroadStomp					= mod:NewSpecialWarningDodge(382233, nil, nil, nil, 2, 2)
local specWarnRainofArrows					= mod:NewSpecialWarningDodge(384476, nil, nil, nil, 2, 2)
local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
local specWarnTempest						= mod:NewSpecialWarningInterrupt(386024, "HasInterrupt", nil, nil, 1, 2)
local specWarnDeathBoltVolley				= mod:NewSpecialWarningInterrupt(387411, "HasInterrupt", nil, nil, 1, 2)
local specWarnBloodcurdlingShout			= mod:NewSpecialWarningInterrupt(373395, "HasInterrupt", nil, nil, 1, 2)
local specWarnDisruptiveShout				= mod:NewSpecialWarningInterrupt(384365, "HasInterrupt", nil, nil, 1, 2)

local timerRallytheClanCD					= mod:NewCDNPTimer(20.6, 383823, nil, nil, nil, 5)--20-23
local timerWarStompCD						= mod:NewCDNPTimer(15.7, 384336, nil, nil, nil, 3)
local timerRainofArrowsCD					= mod:NewCDNPTimer(18.2, 384476, nil, nil, nil, 3)
local timerRottingWindCD					= mod:NewCDNPTimer(23, 436841, nil, nil, nil, 2)
local timerSwiftWindCD						= mod:NewCDNPTimer(20.6, 387596, nil, nil, nil, 5)
local timerSwiftStabCD						= mod:NewCDNPTimer(12, 381683, nil, nil, nil, 5)--12-26.9 (basically casts can be skipped via stuns
local timerThunderstrikeCD					= mod:NewCDNPTimer(4.9, 387125, nil, nil, nil, 5)
local timerVehementChargeCD					= mod:NewCDNPTimer(16.3, 382277, nil, nil, nil, 3)--16.3-17.1
local timerMortalStrikeCD					= mod:NewCDNPTimer(15.1, 388801, nil, nil, nil, 5)
local timerDisruptingShoutCD				= mod:NewCDNPTimer(21.8, 384365, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--20-30ish
local timerTempestCD						= mod:NewCDNPTimer(18.2, 386024, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--20-25
local timerDesecratingRoarCD				= mod:NewCDNPTimer(15.8, 387440, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDeathBoltVolleyCD				= mod:NewCDNPTimer(10.9, 387411, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBloodcurdlingShoutCD				= mod:NewCDNPTimer(19.1, 373395, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--local playerName = UnitName("player")

local teeramod = DBM:GetModByName("2478")

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
		timerTempestCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn386024interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTempest:Show(args.sourceName)
			specWarnTempest:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnTempest:Show()
		end
	elseif spellId == 387411 then
		timerDeathBoltVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn387411interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDeathBoltVolley:Show(args.sourceName)
			specWarnDeathBoltVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDeathBoltVolley:Show()
		end
	elseif spellId == 373395 then
		timerBloodcurdlingShoutCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn373395interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBloodcurdlingShout:Show(args.sourceName)
			specWarnBloodcurdlingShout:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBloodcurdlingShout:Show()
		end
	elseif spellId == 383823 then
		timerRallytheClanCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnRallytheClan:Show()
			warnRallytheClan:Play("crowdcontrol")
		end
	elseif spellId == 387440 then
		timerDesecratingRoarCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnDesecratingRoar:Show()
			warnDesecratingRoar:Play("crowdcontrol")
		end
	elseif spellId == 384365 then
		timerDisruptingShoutCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn384365interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDisruptiveShout:Show(args.sourceName)
			specWarnDisruptiveShout:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDisruptiveShout:Show()
		end
	elseif spellId == 387127 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CLTarget", 0.1, 8)
	elseif spellId == 384336 then
		timerWarStompCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnWarStomp:Show()
			specWarnWarStomp:Play("watchstep")
		end
	elseif (spellId == 436841 or spellId == 387629) then--387629 is season 1 version, 436841 season 4
		timerRottingWindCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			warnRottingWind:Show()
		end
	elseif spellId == 387596 then
		timerSwiftWindCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			warnSwiftWind:Show()
		end
	elseif spellId == 382233 and self:AntiSpam(3, 2) then
		specWarnBroadStomp:Show()
		specWarnBroadStomp:Play("shockwave")
	elseif spellId == 387614 and self:AntiSpam(5, 6) then
		warnChantoftheDead:Show()
	elseif spellId == 386694 and self:AntiSpam(3, 6) then
		warnStormsurge:Show()
	elseif spellId == 387125 then
		timerThunderstrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnThunderstrike:Show()
		end
	elseif spellId == 381683 then
		timerSwiftStabCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnSwiftStab:Show()
		end
	elseif spellId == 388801 then
		timerMortalStrikeCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 384476 then
		timerRainofArrowsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRainofArrows:Show()
			specWarnRainofArrows:Play("watchstep")
		end
	elseif spellId == 382267 then
		timerVehementChargeCD:Start(nil, args.sourceGUID)
		if args:IsPlayer() then
			specWarnVehementCharge:Show()
			specWarnVehementCharge:Play("chargemove")
			yellVehementCharge:Yell()
		end
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
	elseif spellId == 386223 and args:IsDestTypeHostile() and self:AntiSpam(3, 3) then
		specWarnStormshield:Show(args.destName)
		specWarnStormshield:Play("helpdispel")
	elseif spellId == 345561 and self:AntiSpam(5, 8) then--Life Link
		---@diagnostic disable-next-line: dbm-sync-checker
		teeramod:SendSync("TeeraRP")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 192796 then--Nokhud Hornsounder
		timerRallytheClanCD:Stop(args.destGUID)
	elseif cid == 191847 then--Nokhud Plainstomper
		timerWarStompCD:Stop(args.destGUID)
		timerDisruptingShoutCD:Stop(args.destGUID)
	elseif cid == 194894 then--Primalist Stormspeaker
		timerTempestCD:Stop(args.destGUID)
	elseif cid == 195878 then--Uthel Beastcaller
		timerDesecratingRoarCD:Stop(args.destGUID)
	elseif cid == 195928 or cid == 195927 or cid == 195930 or cid == 195929 then--All 4 Soulharvesters
		timerDeathBoltVolleyCD:Stop(args.destGUID)
	elseif cid == 193462 then--Batak
		timerBloodcurdlingShoutCD:Stop(args.destGUID)
	elseif cid == 192789 then--Nokhud Longbow
		timerRainofArrowsCD:Stop(args.destGUID)
	elseif cid == 195876 then--Desecrated Ohuna
		timerRottingWindCD:Stop(args.destGUID)
	elseif cid == 195877 then--Risen Mystic
		timerSwiftWindCD:Stop(args.destGUID)
	elseif cid == 192791 then--Nokhud Warspear
		timerSwiftStabCD:Stop(args.destGUID)
	elseif cid == 195696 then--Primalist Thunderbeast
		timerThunderstrikeCD:Stop(args.destGUID)
	elseif cid == 193457 then--Balara
		timerVehementChargeCD:Stop(args.destGUID)
	elseif cid == 195855 then--Risen Warrior
		timerMortalStrikeCD:Stop(args.destGUID)
	end
end
