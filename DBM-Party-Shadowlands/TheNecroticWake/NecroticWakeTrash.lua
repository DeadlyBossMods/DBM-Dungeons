local mod	= DBM:NewMod("NecroticWakeTrash", "DBM-Party-Shadowlands", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2286)

mod:RegisterEvents(
	"SPELL_CAST_START 324293 327240 327399 334748 320462 338353 323496 333477 333479 338606 345623 322756 328667 335143 320822 324394 324387 338456 324323 321807",
	"SPELL_CAST_SUCCESS 334748 320571 321780 343470 324372 327130 323496 338606 322756 327393 335143 338353 338456 338357 333477 333479 327240 345623 324323 321807",--324293
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 327401 323347 335141 338353 338357 338606 327396 323471 321807",
	"SPELL_AURA_APPLIED_DOSE 338357",
	"SPELL_AURA_REMOVED 338606 327396",
	"UNIT_DIED"
)

--[[
 (ability.id = 324293 or ability.id = 327240 or ability.id = 327399 or ability.id = 334748 or ability.id = 338353 or ability.id = 323496 or ability.id = 333477 or ability.id = 333479 or ability.id = 338606 or ability.id = 345623 or ability.id = 322756 or ability.id = 328667 or ability.id = 335143 or ability.id = 320822 or ability.id = 324394 or ability.id = 324387 or ability.id = 338456 or ability.id = 324323) and type = "begincast"
 or (ability.id = 338357 or ability.id = 327393 or ability.id = 334748 or ability.id = 320571 or ability.id = 321780 or ability.id = 343470 or ability.id = 324372 or ability.id = 327130 or ability.id = 324293 or ability.id = 327240 or ability.id = 327399 or ability.id = 334748 or ability.id = 338353 or ability.id = 323496 or ability.id = 333477 or ability.id = 333479 or ability.id = 338606 or ability.id = 345623 or ability.id = 322756 or ability.id = 328667 or ability.id = 335143 or ability.id = 320822 or ability.id = 324394 or ability.id = 324387 or ability.id = 338456 or ability.id = 324323) and type = "cast"
 or stoppedAbility.id = 334748 or stoppedAbility.id = 324293 or stoppedAbility.id = 338353 or stoppedAbility.id = 328667 or stoppedAbility.id = 335143 or stoppedAbility.id = 327130
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --]]
--TODO targetscan shared agony during cast and get at least one of targets early? for fade/invis and feign death?
--TODO, actually, does shared agony even still exist? it's not in any recent logs
--TODO, add Rasping Scream CD timer https://www.wowhead.com/beta/spell=324293/rasping-scream when a log is found that has a recast
--TODO, add Boneshatter Shield CD timer https://www.wowhead.com/beta/spell=343470/boneshatter-shield when a log is found that has a recast
--TODO, add Frost Bolt Volley CD timer https://www.wowhead.com/beta/spell=328667/frost-bolt-volley if Brittlebone Mages even still use it (163126)
--https://www.wowhead.com/guides/necrotic-wake-shadowlands-dungeon-strategy-guide
local warnClingingDarkness					= mod:NewTargetNoFilterAnnounce(323347, 3, nil, "Healer|RemoveMagic")
local warnSharedAgony						= mod:NewCastAnnounce(327401, 3)
local warnShatter							= mod:NewCastAnnounce(324394, 4, nil, nil, "Tank|Healer")
local warnMutilate							= mod:NewCastAnnounce(338456, 3, nil, nil, "Tank|Healer")
local warnTenderize							= mod:NewStackAnnounce(338357, 2, nil, "Tank|Healer")
local warnThrowCleaver						= mod:NewTargetNoFilterAnnounce(323496, 2, nil, "Tank", nil, nil, nil, 2)
local warnBoneMend							= mod:NewCastAnnounce(335143, 4)--High Prio off interrupt
local warnRepairFlesh						= mod:NewCastAnnounce(327130, 4)--High Prio off interrupt
local warnFinalBargain						= mod:NewCastAnnounce(320822, 4, nil, nil, nil, nil, nil, 2)
local warnSharedAgonyTargets				= mod:NewTargetAnnounce(327401, 4)
local warnSpewDisease						= mod:NewTargetNoFilterAnnounce(333479, 2)
local warnMorbidFixation					= mod:NewTargetNoFilterAnnounce(338606, 2)
local warnGrimFate							= mod:NewTargetAnnounce(327396, 2)
local warnAnimateDead						= mod:NewSpellAnnounce(321780, 2)
local warnWrathOfZolramus					= mod:NewSpellAnnounce(322756, 2)

--General
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)
local specWarnBoneflay						= mod:NewSpecialWarningDefensive(321807, nil, nil, nil, 1, 2)
local specWarnSpineCrush					= mod:NewSpecialWarningRun(327240, nil, nil, nil, 4, 2)
local specWarnGutSlice						= mod:NewSpecialWarningDodge(333477, nil, nil, nil, 2, 15)
local specWarnDeathBurst					= mod:NewSpecialWarningDodge(345623, nil, nil, nil, 2, 2)
local specWarnShadowWell					= mod:NewSpecialWarningDodge(320571, nil, nil, nil, 2, 2)
local specWarnFrigidSpikes					= mod:NewSpecialWarningDodge(324387, nil, nil, nil, 2, 2)
local specWarnGruesomeCleave				= mod:NewSpecialWarningDodge(324323, nil, nil, nil, 2, 15)
local specWarnSharedAgony					= mod:NewSpecialWarningMoveAway(327401, nil, nil, nil, 1, 11)
local yellSharedAgony						= mod:NewYell(327401)
local specWarnReapingWinds					= mod:NewSpecialWarningRun(324372, nil, nil, nil, 4, 2)
local yellThrowCleaver						= mod:NewYell(323496)
local specWarnSpewDisease					= mod:NewSpecialWarningYou(333479, nil, nil, nil, 1, 2)
local yellSpewDisease						= mod:NewYell(333479)
local specWarnMorbidFixation				= mod:NewSpecialWarningRun(338606, nil, nil, nil, 4, 2)
local specWarnGrimFate						= mod:NewSpecialWarningMoveAway(327396, nil, nil, nil, 1, 2)
local yellGrimFate							= mod:NewYell(327396)
local yellGrimFateFades						= mod:NewShortFadesYell(327396)
local specWarnGoresplatterDispel			= mod:NewSpecialWarningDispel(338353, "RemoveDisease", nil, nil, 1, 2)
local specWarnClingingDarkness				= mod:NewSpecialWarningDispel(323347, false, nil, nil, 1, 2)--Opt it for now, since dispel timing is less black and white
local specWarnDarkShroud					= mod:NewSpecialWarningDispel(335141, "MagicDispeller", nil, nil, 1, 2)
local specWarnBoneFlayDispel				= mod:NewSpecialWarningDispel(321807, "RemoveBleed", nil, nil, 1, 2)
local specWarnDrainFluids					= mod:NewSpecialWarningInterrupt(334748, nil, nil, nil, 1, 2)--Feedback be damned, it's too important not to kick, if it's spammy, maybe you shouldn't sit on your interrupt CD.
local specWarnNecroticBolt					= mod:NewSpecialWarningInterrupt(320462, false, nil, nil, 1, 2)--Pretty much spam cast, so lower priority over other spells. Also excluded frome expression, it has no cooldown
local specWarnRaspingScream					= mod:NewSpecialWarningInterrupt(324293, "HasInterrupt", nil, nil, 1, 2)
local specWarnGoresplatter					= mod:NewSpecialWarningInterrupt(338353, false, nil, nil, 1, 2)--Off by default since enemy has two casts and this is lower priority one
local specWarnFrostBoltVolley				= mod:NewSpecialWarningInterrupt(328667, "HasInterrupt", nil, nil, 1, 2)
local specWarnBoneMend						= mod:NewSpecialWarningInterrupt(335143, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnRepairFlesh					= mod:NewSpecialWarningInterrupt(327130, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnBoneshatterShield				= mod:NewSpecialWarningSwitchCustom(343470, "Dps", nil, nil, 1, 2)

local timerBoneflayCD						= mod:NewCDNPTimer(15, 321807, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerMorbidFixation					= mod:NewTargetTimer(8, 338606, nil, nil, nil, 5)
local timerDrainFluidsCD					= mod:NewCDPNPTimer(15, 334748, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Harvester 15-17.5, Collector 14.1-18.3, Stitching Assistant 16.6-17.9
local timerThrowCleaverCD					= mod:NewCDNPTimer(13, 323496, nil, nil, nil, 3)--13-14.2 for Flesh Carver, 15.4 for Stitching Assistant, 14.1 for Separation Assistant
local timerMorbidFixationCD					= mod:NewCDNPTimer(26.7, 338606, nil, nil, nil, 3)
local timerWrathOfZolramusCD				= mod:NewCDNPTimer(16.9, 322756, nil, nil, nil, 2)--16.9-17.8 (at least from gatekeeper mob)
local timerShadowWellCD						= mod:NewCDNPTimer(13, 320571, nil, nil, nil, 3)--13.5-19.4
local timerGrimFateCD						= mod:NewCDNPTimer(18.2, 327396, nil, nil, nil, 3)
local timerDeathBurstCD						= mod:NewCDNPTimer(16.2, 345623, nil, nil, nil, 3)
local timerAnimatedDeadCD					= mod:NewCDNPTimer(29.1, 321780, nil, nil, nil, 1)--29.1-33, not greatest sample size
local timerBoneMendCD						= mod:NewCDPNPTimer(7, 335143, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--7 second recast, but can be delayed a lot by Final bargain
--local timerRaspingScreamCD				= mod:NewCDPNPTimer(15, 324293, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Not known, couldn't find a single log mob lived more than one cast
local timerGruesomeCleaveCD					= mod:NewCDPNPTimer(11.1, 324323, nil, nil, nil, 3)
--local timerBoneshatterShieldCD			= mod:NewCDNPTimer(15, 343470, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--Not known, couldn't find a single log mob lived more than one cast
--local timerFrostBoltVolleyCD				= mod:NewCDNPTimer(15.4, 328667, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--CD unknown
local timerGoresplatterCD					= mod:NewCDPNPTimer(20, 338353, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--20-22
local timerMutlilateCD						= mod:NewCDNPTimer(13, 338456, nil, nil, nil, 5)--13 sec trash, 10.6 both minibosses
local timerTenderizeCD						= mod:NewCDNPTimer(14.5, 338357, nil, nil, nil, 5)--14.5 sec trash, 12.1 Goregrind
local timerGutSliceCD						= mod:NewCDPNPTimer(12.5, 333477, nil, nil, nil, 3)
local timerSpewDiseaseCD					= mod:NewCDNPTimer(10.6, 333479, nil, nil, nil, 3)
local timerSpineCrushCD						= mod:NewCDNPTimer(14.0, 327240, nil, nil, nil, 3)
local timerSpineCrush						= mod:NewCastNPTimer(3, 327240, nil, nil, nil, 5)
local timerRepairFleshCD					= mod:NewCDPNPTimer(14.3, 327130, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--14-17

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
--Deprecated, it has a debuff in combat log now, but keeping for now in case that changes
function mod:ThrowCleaver(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellThrowCleaver:Yell()
	end
end
--]]
local memoryWastingTable = {}

function mod:FixateTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 1) then
			specWarnMorbidFixation:Show()
			specWarnMorbidFixation:Play("justrun")
		end
	else
		warnMorbidFixation:Show(targetname)
	end
end

function mod:SpewTarget(targetname, uId)
	if not targetname then return end
	if self:AntiSpam(3, targetname) then
		if targetname == UnitName("player") then
			specWarnSpewDisease:Show()
			specWarnSpewDisease:Play("targetyou")
			yellSpewDisease:Yell()
		else
			warnSpewDisease:Show(targetname)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 324293 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnRaspingScream:Show(args.sourceName)
		specWarnRaspingScream:Play("kickcast")
	elseif spellId == 334748 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDrainFluids:Show(args.sourceName)
		specWarnDrainFluids:Play("kickcast")
	elseif spellId == 320462 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnNecroticBolt:Show(args.sourceName)
		specWarnNecroticBolt:Play("kickcast")
	elseif spellId == 338353 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnGoresplatter:Show(args.sourceName)
		specWarnGoresplatter:Play("kickcast")
	elseif spellId == 328667 and args:GetSrcCreatureID() ~= 164414 then
		--timerFrostBoltVolleyCD:Start(15.4, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then--Filter boss version, to avoid double alerts
			specWarnFrostBoltVolley:Show(args.sourceName)
			specWarnFrostBoltVolley:Play("kickcast")
		end
	elseif spellId == 327240 then
		timerSpineCrush:Stop(args.sourceGUID)
		timerSpineCrush:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnSpineCrush:Show()
			specWarnSpineCrush:Play("justrun")
		end
	elseif spellId == 333477 and self:AntiSpam(3, 2) then
		specWarnGutSlice:Show()
		specWarnGutSlice:Play("frontal")
	elseif spellId == 327399 and self:AntiSpam(3, 6) then
		warnSharedAgony:Show()
	elseif spellId == 323496 and self:AntiSpam(3, 6) then
		--self:ScheduleMethod(0.25, "BossTargetScanner", args.sourceGUID, "ThrowCleaver", 0.25, 12)
	elseif spellId == 333479 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "SpewTarget", 0.1, 6)
	elseif spellId == 338606 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "FixateTarget", 0.1, 6)
	elseif spellId == 345623 then
		if self:AntiSpam(3, 2) then
			specWarnDeathBurst:Show()
			specWarnDeathBurst:Play("watchstep")
		end
	elseif spellId == 322756 and self:AntiSpam(3, 6) then
		warnWrathOfZolramus:Show()
	elseif spellId == 335143 then

		if self.Options.SpecWarn335143interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBoneMend:Show(args.sourceName)
			specWarnBoneMend:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBoneMend:Show()
		end
	elseif spellId == 320822 and self:AntiSpam(3, 5) then
		warnFinalBargain:Show()
		warnFinalBargain:Play("crowdcontrol")
	elseif spellId == 324394 then
		if self:AntiSpam(3, 5) then
			warnShatter:Show()
		end
	elseif spellId == 338456 then
		if self:AntiSpam(3, 5) then
			warnMutilate:Show()
		end
	elseif spellId == 324387 then
		if self:AntiSpam(3, 2) then
			specWarnFrigidSpikes:Show()
			specWarnFrigidSpikes:Play("watchstep")
		end
	elseif spellId == 324323 then
		if self:AntiSpam(3, 2) then
			specWarnGruesomeCleave:Show()
			specWarnGruesomeCleave:Play("frontal")
		end
	elseif spellId == 321807 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnBoneflay:Show()
			specWarnBoneflay:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 334748 then
		--Harvester (166302) 15-17.5, Collector (173016) 14.1-18.3, Stitching Assistant (173044) 16.6-17.9
		local cooldown = args:GetSrcCreatureID() == 173044 and 16.6 or args:GetSrcCreatureID() == 166302 and 15 or 14.1
		timerDrainFluidsCD:Start(cooldown, args.sourceGUID)
		if not memoryWastingTable[args.sourceGUID] then
			memoryWastingTable[args.sourceGUID] = true
		end
	elseif spellId == 320571 then
		timerShadowWellCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnShadowWell:Show()
			specWarnShadowWell:Play("watchstep")
		end
	elseif spellId == 324323 then
		timerGruesomeCleaveCD:Start(11.1, args.sourceGUID)
	elseif spellId == 321780 then
		warnAnimateDead:Show()
		timerAnimatedDeadCD:Start(29.1, args.sourceGUID)
	elseif spellId == 343470 then
		specWarnBoneshatterShield:Show(args.sourceName)
		specWarnBoneshatterShield:Play("attackshield")
--		timerBoneshatterShieldCD:Start(nil, args.sourceGUID)
	elseif spellId == 324372 then
		specWarnReapingWinds:Show()
		specWarnReapingWinds:Play("justrun")
	elseif spellId == 327130 then
		timerRepairFleshCD:Start(14.3, args.sourceGUID)
		if self.Options.SpecWarn327130interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRepairFlesh:Show(args.sourceName)
			specWarnRepairFlesh:Play("kickcast")
		else
			warnRepairFlesh:Show()
		end
	elseif spellId == 323496 then
		--13-14.2 for Flesh Carver (165872), 15.4 for Stitching Assistant (173044), 14.1 for Separation Assistant (167731)
		local timer = args:GetSrcCreatureID() == 173044 and 15.4 or args:GetSrcCreatureID() == 167731 and 14.1 or 13--All cast adjusted by 4 seconds
		timerThrowCleaverCD:Start(timer, args.sourceGUID)
	elseif spellId == 338606 then
		timerMorbidFixationCD:Start(24.7, args.sourceGUID)
	elseif spellId == 322756 then
		timerWrathOfZolramusCD:Start(15.4, args.sourceGUID)
	elseif spellId == 327393 then
		--Nar'zudah (165824), Zolramus Necromancer (163618)
		local timer = args:GetSrcCreatureID() == 165824 and 20.6 or 18.2
		timerGrimFateCD:Start(timer, args.sourceGUID)
	elseif spellId == 335143 then
		timerBoneMendCD:Start(7, args.sourceGUID)
--	elseif spellId == 324293 then
		--timerRaspingScreamCD:Start(15.4, args.sourceGUID)
	elseif spellId == 338353 then
		timerGoresplatterCD:Start(20, args.sourceGUID)
	elseif spellId == 338456 then
		--Kyrian Stickwork (172981), Goregrind (163621), Rotspew (163620)
		local timer = args:GetSrcCreatureID() == 172981 and 13 or 10.6
		timerMutlilateCD:Start(timer, args.sourceGUID)
	elseif spellId == 338357 then
		--Kyrian Stickwork (172981), Goregrind (163621)
		local timer = args:GetSrcCreatureID() == 172981 and 14.5 or 12.1
		timerTenderizeCD:Start(timer, args.sourceGUID)
	elseif spellId == 333477 then
		timerGutSliceCD:Start(12.5, args.sourceGUID)
	elseif spellId == 333479 then
		timerSpewDiseaseCD:Start(10.6, args.sourceGUID)
	elseif spellId == 327240 then
		timerSpineCrushCD:Start(14.0, args.sourceGUID)
	elseif spellId == 345623 then
		timerDeathBurstCD:Start(16.2, args.sourceGUID)
	elseif spellId == 321807 then
		timerBoneflayCD:Start(15, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 334748 then
		--Harvester (166302) 15-17.5, Collector (173016) 14.1-18.3, Stitching Assistant (173044) 16.6-17.9
		local cooldown = args:GetSrcCreatureID() == 173044 and 16.6 or args:GetSrcCreatureID() == 166302 and 15 or 14.1
		if not memoryWastingTable[args.sourceGUID] then
			timerDrainFluidsCD:Start(cooldown, args.destGUID)
		end
	elseif args.extraSpellId == 335143 then
		timerBoneMendCD:Start(7, args.destGUID)
--	elseif args.extraSpellId == 324293 then
		--timerRaspingScreamCD:Start(15.4, args.destGUID)
	elseif args.extraSpellId == 338353 then
		timerGoresplatterCD:Start(20, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 327401 then
		warnSharedAgonyTargets:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnSharedAgony:Show()
			specWarnSharedAgony:Play("lineapart")
			yellSharedAgony:Yell()
		end
	elseif spellId == 323347 and args:IsDestTypePlayer() and self:AntiSpam(3, 5) then
		if self.Options.SpecWarn323347dispel and  self:CheckDispelFilter("magic") then
			specWarnClingingDarkness:Show(args.destName)
			specWarnClingingDarkness:Play("helpdispel")
		else
			warnClingingDarkness:Show(args.destName)
		end
	elseif spellId == 335141 and args:IsDestTypeHostile() then--Not filtered with self:AntiSpam(3, 5) for now
		specWarnDarkShroud:Show(args.destName)
		specWarnDarkShroud:Play("dispelboss")
	elseif spellId == 338353 and args:IsDestTypePlayer() and self:CheckDispelFilter("disease") and self:AntiSpam(3, 5) then
		specWarnGoresplatterDispel:Show(args.destName)
		specWarnGoresplatterDispel:Play("helpdispel")
	elseif spellId == 338357 and args:IsDestTypePlayer() then
		local amount = args.amount or 1
		if amount >= 2 then
			warnTenderize:Show(args.destName, args.amount or 1)
		end
	elseif spellId == 338606 then
		timerMorbidFixation:Start(args.destName)
		if args:IsPlayer() and self:AntiSpam(4, 1) then
			specWarnMorbidFixation:Show()
			specWarnMorbidFixation:Play("justrun")
		end
	elseif spellId == 327396 then
		warnGrimFate:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnGrimFate:Show()
			specWarnGrimFate:Play("runout")
			yellGrimFate:Yell()
			yellGrimFateFades:Countdown(spellId)
		end
	elseif spellId == 323471 then
		if args:IsPlayer() then
			yellThrowCleaver:Yell()
		else
			warnThrowCleaver:Show(args.destName)
			warnThrowCleaver:Play("helpsoak")
		end
	elseif spellId == 321807 and args:IsDestTypePlayer() and self:CheckDispelFilter("bleed") then
		specWarnBoneFlayDispel:Show(args.destName)
		specWarnBoneFlayDispel:Play("helpdispel")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 338606 then
		timerMorbidFixation:Stop(args.destName)
	elseif spellId == 327396 then
		if args:IsPlayer() then
			yellGrimFateFades:Cancel()
		end
	end
end

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 173016 then--Corpse Collector
		memoryWastingTable[args.destGUID] = nil
		timerDrainFluidsCD:Stop(args.destGUID)
		timerGoresplatterCD:Stop(args.destGUID)
	elseif cid == 166302 then--Corpse Harvester
		timerDrainFluidsCD:Stop(args.destGUID)
	elseif cid == 165872 then--Flesh Crafter
		timerThrowCleaverCD:Stop(args.destGUID)
		timerRepairFleshCD:Stop(args.destGUID)
	elseif cid == 173044 then--Stitching Assistant
		timerThrowCleaverCD:Stop(args.destGUID)
		timerDrainFluidsCD:Stop(args.destGUID)
	elseif cid == 167731 then--Separation Assistant
		timerThrowCleaverCD:Stop(args.destGUID)
		timerMorbidFixationCD:Stop(args.destGUID)
	elseif cid == 165137 then--Zolramus Gatekeeper
		timerWrathOfZolramusCD:Stop(args.destGUID)
	elseif cid == 163128 then--Zolramus Sorcerer
		timerShadowWellCD:Stop(args.destGUID)
	elseif cid == 163618 then--Zolramus Necromancer
		timerGrimFateCD:Stop(args.destGUID)
		timerAnimatedDeadCD:Stop(args.destGUID)
	elseif cid == 165222 then--Zolramus Bonemender
		timerBoneMendCD:Stop(args.destGUID)
	elseif cid == 165824 then--Nar'zudah
		timerGrimFateCD:Stop(args.destGUID)
		timerDeathBurstCD:Stop(args.destGUID)
	elseif cid == 165919 then--Skeletal Marauder
		--timerRaspingScreamCD:Stop(args.destGUID)
		--timerBoneshatterShieldCD:Stop(args.destGUID)
		timerGruesomeCleaveCD:Stop(args.destGUID)
	elseif cid == 172981 then--Kyrian Stickwork
		timerMutlilateCD:Stop(args.destGUID)
		timerTenderizeCD:Stop(args.destGUID)
	elseif cid == 163621 then--Goregrind
		timerMutlilateCD:Stop(args.destGUID)
		timerTenderizeCD:Stop(args.destGUID)
		timerGutSliceCD:Stop(args.destGUID)
	elseif cid == 163620 then--Rotspew
		timerMutlilateCD:Stop(args.destGUID)
		timerSpewDiseaseCD:Stop(args.destGUID)
	elseif cid == 165911 then--Loyal Creation
		timerSpineCrushCD:Stop(args.destGUID)
		timerSpineCrush:Stop(args.destGUID)
	elseif cid == 163619 then--Zolramus Bonecarver

	end
end
