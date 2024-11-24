local mod	= DBM:NewMod("TirnaScitheTrash", "DBM-Party-Shadowlands", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2290)
mod:RegisterZoneCombat(2290)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 321968 324909 324923 324914 324776 340305 340304 340300 340160 340189 326046 460092 463256 463248 340208 340289 326021 463217",--325418 331718 331743
	"SPELL_CAST_SUCCESS 325418 340544 322938 325223 340279 321968 324923 322486 322557 324914 324776 326046 463248 463256 340160 340208 340189 326021 460092 324987 340300 463217 323043",--331718 331743
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 322557 324914 324776 325224 340288 326046 322486 325021 323043",
	"SPELL_AURA_APPLIED_DOSE 340288",
	"SPELL_AURA_REMOVED 325224",
	"UNIT_DIED"
)

--TODO, adjust triple bite stack warnings? More often, less often?
--TODO, target scan crushing leap? If it can be done, and if the two aoe abilities come from leap target destination, fine tune those warnings too
--TODO, see if Pool of Radiance is too early to warn, might need to warn at 340191/rejuvenating-radiance instead
--TODO, add https://www.wowhead.com/beta/spell=322569/hand-of-thros ? can you really do anything about it though? Guess tank can kite, timer too varaible to add
--TODO, track https://www.wowhead.com/beta/spell=340289/triple-bite cast itself for nameplate timer purposes?
--TODO, dispel warning for https://www.wowhead.com/beta/spell=340283/poisonous-discharge ?
--[[
(ability.id = 321968 or ability.id = 324909 or ability.id = 324923 or ability.id = 324914 or ability.id = 324776 or ability.id = 340305 or ability.id = 340304 or ability.id = 340300 or ability.id = 340160 or ability.id = 340189 or ability.id = 326046 or ability.id = 331718 or ability.id = 331743 or ability.id = 460092 or ability.id = 463256 or ability.id = 463248 or ability.id = 340208 or ability.id = 340289 or ability.id = 326021 or ability.id = 463217) and (type = "begincast" or type = "cast")
 or (ability.id = 325418 or ability.id = 340544 or ability.id = 322938 or ability.id = 325223 or ability.id = 331743 or ability.id = 340279 or ability.id = 321968 or ability.id = 324923 or ability.id = 331718 or ability.id = 322486 or ability.id = 322557 or ability.id = 324914 or ability.id = 324776 or ability.id = 326046) and type = "cast"
 or stoppedAbility.id = 322938 or stoppedAbility.id = 324914 or stoppedAbility.id = 324776 or stoppedAbility.id = 326046 or stoppedAbility.id = 340544
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 165111) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 165111)
--]]
local warnOvergrowth					= mod:NewTargetAnnounce(322486, 4)
local warnFuriousThrashing				= mod:NewSpellAnnounce(324909, 3)--No CD timer because no one has ever seen it cast twice in a row
local warnTripleBite					= mod:NewStackAnnounce(340288, 2, nil, "Tank|Healer|RemovePoison")
local warnCrushingLeap					= mod:NewSpellAnnounce(340305, 3)--Change to target warning if target scan debug checks out
local warnVolatileAcid					= mod:NewTargetAnnounce(325418, 3)
local warnHarvestEssence				= mod:NewCastAnnounce(322938, 4, 6)--High Prio off internet
local warnNourishtheForest				= mod:NewCastAnnounce(324914, 4)--High Prio off internet
--local warnBuckingRampage				= mod:NewSpellAnnounce(331743, 3, nil, "Melee")--Annoying spell that can do a lot of burst damage to melee that's not interruptable
local warnMistveilTear					= mod:NewTargetNoFilterAnnounce(325021, 3, nil, "Tank|Healer|RemoveBleed")
local warnExpel							= mod:NewTargetAnnounce(463248, 3)

--General
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)
local specWarnAcidNova					= mod:NewSpecialWarningSpell(460092, nil, nil, nil, 2, 2)
local specWarnBrambleBurst				= mod:NewSpecialWarningDodge(324923, nil, nil, nil, 2, 2)
--local specWarnSpearFlurry				= mod:NewSpecialWarningDodge(331718, nil, nil, nil, 2, 15)--Retired for now.
local specWarnPoisonousSecretions		= mod:NewSpecialWarningDodge(340304, nil, nil, nil, 2, 2)
local specWarnTongueLashing				= mod:NewSpecialWarningDodge(340300, nil, nil, nil, 2, 2)
local specWarnRadiantBreath				= mod:NewSpecialWarningDodge(340160, nil, nil, nil, 2, 2)
local specWarnPoisonousDischarge		= mod:NewSpecialWarningDodge(340279, nil, nil, nil, 2, 2)
local specWarnBewilderingPollen			= mod:NewSpecialWarningDodge(321968, nil, nil, nil, 1, 15)
local specWarnExpel						= mod:NewSpecialWarningYou(463248, nil, nil, nil, 2, 2)
local specWarnAcidGlobule				= mod:NewSpecialWarningDodge(326021, nil, nil, nil, 2, 2)
local specWarnOvergrowth				= mod:NewSpecialWarningMoveTo(322486, nil, nil, nil, 1, 11)
local specWarnShredArmor				= mod:NewSpecialWarningDefensive(340208, nil, nil, nil, 1, 2)
local specWarnAnimaSlash				= mod:NewSpecialWarningDefensive(463217, nil, nil, nil, 1, 2)
local specWarnSoulSplit					= mod:NewSpecialWarningDispel(322557, "RemoveMagic", nil, nil, 1, 2)
local specWarnNourishtheForestDispel	= mod:NewSpecialWarningDispel(324914, "MagicDispeller", nil, nil, 1, 2)
local specWarnBramblethornCoatDispel	= mod:NewSpecialWarningDispel(324776, "MagicDispeller", nil, nil, 1, 2)
local specWarnStimulateResistanceDispel	= mod:NewSpecialWarningDispel(326046, "MagicDispeller", nil, nil, 1, 2)
local specWarnBloodlettingDispel		= mod:NewSpecialWarningDispel(323043, "RemoveBleed", nil, nil, 1, 2)
local specWarnPoolOfRadiance			= mod:NewSpecialWarningMove(340189, nil, nil, nil, 1, 10)
local specWarnMistWard					= mod:NewSpecialWarningMove(463256, nil, nil, nil, 1, 10)
local specWarnVolatileAcid				= mod:NewSpecialWarningMoveAway(325418, nil, nil, nil, 1, 2)
local yellVolatileAcid					= mod:NewShortYell(325418)
local specWarnAnimaInjection			= mod:NewSpecialWarningMoveAway(325224, nil, nil, nil, 1, 2)
local yellAnimaInjection				= mod:NewShortYell(325224)
local yellAnimaInjectionFades			= mod:NewShortFadesYell(325224)
local specWarnHarvestEssence			= mod:NewSpecialWarningInterrupt(322938, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnNourishtheForest			= mod:NewSpecialWarningInterrupt(324914, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnBramblethornCoat			= mod:NewSpecialWarningInterrupt(324776, "HasInterrupt", nil, nil, 1, 2)
local specWarnStimulateResistance		= mod:NewSpecialWarningInterrupt(326046, "HasInterrupt", nil, nil, 1, 2)
local specWarnStimulateRegeneration		= mod:NewSpecialWarningInterrupt(340544, "HasInterrupt", nil, nil, 1, 2)

--Cooldowns only show Recast time after successful interrupt or cast finish
--This means stunned/CCed mobs will not show recast timers since abilities do not go on cooldown
local timerBloodLettingCD				= mod:NewCDNPTimer(13.1, 323043, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerBewilderingPollenCD			= mod:NewCDPNPTimer(12.2, 321968, nil, nil, nil, 3)--Valid Aug 8
local timerOvergrowthCD					= mod:NewCDNPTimer(15.3, 322486, nil, nil, nil, 3)--Valid Aug 8
local timerBrambleBurstCD				= mod:NewCDNPTimer(13.5, 324923, nil, nil, nil, 3)--Valid Aug 8
--local timerSpearFlurryCD				= mod:NewCDNPTimer(9.3, 331718, nil, false, nil, 3)--Disabled in current season
local timerAnimaInjectionCD				= mod:NewCDNPTimer(14.1, 325224, nil, nil, nil, 3)--Valid Aug 8
--local timerBuckingRampageCD			= mod:NewCDNPTimer(15.2, 331743, nil, nil, nil, 3)--Disabled in current season
local timerPoisonousDischargeCD			= mod:NewCDNPTimer(21.2, 340279, nil, nil, nil, 3)--??? not seen in logs, mob avoided?
local timerSoulSpiritCD					= mod:NewCDNPTimer(14.5, 322557, nil, nil, nil, 5)--Valid Aug 8
local timerVolatileAcidCD				= mod:NewCDNPTimer(12.1, 325418, nil, nil, nil, 3)--Valid Aug 8, HIGHLY variable though (like 12-19)
local timerNourishtheForestCD			= mod:NewCDPNPTimer(15.9, 324914, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Valid Aug 8
local timerBramblethornCoatCD			= mod:NewCDPNPTimer(21.6, 324776, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Valid Aug 8, 21.6-24.something
local timerStimulateResistanceCD		= mod:NewCDPNPTimer(15.8, 326046, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Valid Aug 8
local timerStimulateRegenerationCD		= mod:NewCDPNPTimer(21.9, 340544, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Valid Aug 8, but could be lower
local timerAcidNovaCD					= mod:NewCDNPTimer(18, 460092, nil, nil, nil, 3)--Valid Aug 8
local timerHarvestEssenceCD				= mod:NewCDPNPTimer(15, 322938, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)----Valid Aug 8. This one does go on CD if stunned because it's channeled not cast start
local timerExpelCD						= mod:NewCDNPTimer(15.1, 463248, nil, nil, nil, 3)--Valid Aug 8
local timerMistWardCD					= mod:NewCDNPTimer(22.9, 463256, nil, nil, nil, 5)--Valid Aug 8, One of two creatures has CD, the other does not.
local timerRadiantBreathCD				= mod:NewCDPNPTimer(10.4, 340160, nil, nil, nil, 3)--Valid Aug 8
local timerShredArmorCD					= mod:NewCDNPTimer(10.6, 340208, nil, nil, nil, 5)----Valid Aug 8, Possible same as breath
local timerAnimaSlashCD					= mod:NewCDNPTimer(13, 463217, nil, nil, nil, 5)--Valid Nov 4
local timerPoolofRadianceCD				= mod:NewCDNPTimer(28, 340189, nil, nil, nil, 5)--Valid Aug 8
local timerAcidGlobuleCD				= mod:NewCDNPTimer(15.4, 326021, nil, nil, nil, 3)--Valid Nov 3
local timerMistveilBiteCD				= mod:NewCDNPTimer(15, 324987, nil, nil, nil, 5)--Valid Nov 3
local timerTongueLashingCD				= mod:NewCDPNPTimer(7.7, 340300, nil, nil, nil, 3)--Valid Aug 8

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:CrushingLeap(targetname, _, unituid)
	--Now has death check cause it's possible for mob to die before cast finishes and we don't want scan to return target if it won't finish
	if not targetname or (unituid and UnitIsDead(unituid)) then return end
	DBM:Debug("Crushing Leap on "..targetname)
--	warnRicochetingThrow:Show(targetname)
--	if targetname == UnitName("player") then
--		yellRicochetingThrow:Yell()
--	end
end

function mod:ExpelTarget(targetname, _, unituid)
	--Now has death check cause it's possible for mob to die before cast finishes and we don't want scan to return target if it won't finish
	if not targetname or (unituid and UnitIsDead(unituid)) then return end
	DBM:Debug("Crushing Leap on "..targetname)
	if targetname == UnitName("player") then
		specWarnExpel:Show()
		specWarnExpel:Play("targetyou")
		specWarnExpel:ScheduleVoice(1.5, "carefly")
	else
		warnExpel:Show(targetname)
	end
end

--[[
--About 1 second faster than debuff
function mod:VolatileAcid(targetname, _, unituid)
	--Now has death check cause it's possible for mob to die before cast finishes and we don't want scan to return target if it won't finish
	if not targetname or (unituid and UnitIsDead(unituid)) then return end
	if self:AntiSpam(3, targetname) then
		if targetname == UnitName("player") then
			specWarnVolatileAcid:Show()
			specWarnVolatileAcid:Play("range5")
			yellVolatileAcid:Yell()
		else
			warnVolatileAcid:Show(targetname)
		end
	end
end
--]]

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end--Filter all casts done by mobs in combat with npcs/other mobs.
	local spellId = args.spellId
	if spellId == 321968 and self:AntiSpam(3, 2) then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnBewilderingPollen:Show()
			specWarnBewilderingPollen:Play("frontal")
		end
	elseif spellId == 324909 and self:AntiSpam(3, 4) then
		warnFuriousThrashing:Show()
	elseif spellId == 324923 and self:AntiSpam(3, 2) then
		specWarnBrambleBurst:Show()
		specWarnBrambleBurst:Play("watchfeet")
	elseif spellId == 324914 then
		if self.Options.SpecWarn324914interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnNourishtheForest:Show(args.sourceName)
			specWarnNourishtheForest:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnNourishtheForest:Show()
		end
	elseif spellId == 324776 and self:CheckInterruptFilter(args.sourceGUID, false, true) and self:AntiSpam(2, 5) then
		specWarnBramblethornCoat:Show(args.sourceName)
		specWarnBramblethornCoat:Play("kickcast")
	elseif spellId == 326046 and self:CheckInterruptFilter(args.sourceGUID, false, true) and self:AntiSpam(2, 5) then
		specWarnStimulateResistance:Show(args.sourceName)
		specWarnStimulateResistance:Play("kickcast")
	elseif spellId == 340305 then
		warnCrushingLeap:Show()
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CrushingLeap", 0.1, 4)
	elseif spellId == 340304 and self:AntiSpam(3, 2) then
		specWarnPoisonousSecretions:Show()
		specWarnPoisonousSecretions:Play("watchstep")
	elseif spellId == 340300 and self:AntiSpam(3, 2) then
		specWarnTongueLashing:Show()
		specWarnTongueLashing:Play("frontal")
	elseif spellId == 340160 and self:AntiSpam(3, 2) then
		specWarnRadiantBreath:Show()
		specWarnRadiantBreath:Play("breathsoon")

	elseif spellId == 340189 then--No Antispam, not to be throttled against other types
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnPoolOfRadiance:Show()
			specWarnPoolOfRadiance:Play("mobout")
		end
	elseif spellId == 463256 then--No Antispam, not to be throttled against other types
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnMistWard:Show()
			specWarnMistWard:Play("mobout")
		end
--	elseif spellId == 325418 then
--		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "VolatileAcid", 0.1, 4)
--	elseif spellId == 331718 and self:AntiSpam(3, 2) then
--		specWarnSpearFlurry:Show()
--		specWarnSpearFlurry:Play("frontal")
--	elseif spellId == 331743 then
--		warnBuckingRampage:Show()
	elseif spellId == 460092 then
		if self:AntiSpam(3, 4) then
			specWarnAcidNova:Show()
			specWarnAcidNova:Play("aesoon")
		end
	elseif spellId == 463248 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ExpelTarget", 0.1, 6)
	elseif spellId == 340208 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnShredArmor:Show()
			specWarnShredArmor:Play("defensive")
		end
	elseif spellId == 326021 then
		if self:AntiSpam(3, 2) then
			specWarnAcidGlobule:Show()
			specWarnAcidGlobule:Play("watchstep")
		end
	elseif spellId == 463217 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnAnimaSlash:Show()
			specWarnAnimaSlash:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end--Filter all casts done by mobs in combat with npcs/other mobs.
	local spellId = args.spellId
	if spellId == 325418 then
		timerVolatileAcidCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, args.destName) then--Backup, in case no one in party was targetting mob casting Volatile Acid (ie target scanning would fail)
			if args:IsPlayer() then
				specWarnVolatileAcid:Show()
				specWarnVolatileAcid:Play("range5")
				yellVolatileAcid:Yell()
			else
				warnVolatileAcid:Show(args.destName)
			end
		end
	elseif spellId == 340544 then
		timerStimulateRegenerationCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnStimulateRegeneration:Show(args.sourceName)
			specWarnStimulateRegeneration:Play("kickcast")
		end
	elseif spellId == 322938 then
		timerHarvestEssenceCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn322938interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHarvestEssence:Show(args.sourceName)
			specWarnHarvestEssence:Play("kickcast")
		else
			warnHarvestEssence:Show()
		end
	elseif spellId == 325223 then
		timerAnimaInjectionCD:Start(nil, args.sourceGUID)
--	elseif spellId == 331743 then
--		timerBuckingRampageCD:Start(nil, args.sourceGUID)
	elseif spellId == 340279 then
		timerPoisonousDischargeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnPoisonousDischarge:Show()
			specWarnPoisonousDischarge:Play("watchstep")
		end
	elseif spellId == 321968 then
		timerBewilderingPollenCD:Start(nil, args.sourceGUID)
	elseif spellId == 324923 then
		timerBrambleBurstCD:Start(nil, args.sourceGUID)
--	elseif spellId == 331718 then
--		timerSpearFlurryCD:Start(nil, args.sourceGUID)
	elseif spellId == 322486 then
		timerOvergrowthCD:Start(nil, args.sourceGUID)
	elseif spellId == 322557 then
		timerSoulSpiritCD:Start(nil, args.sourceGUID)
	elseif spellId == 324914 then
		timerNourishtheForestCD:Start(nil, args.sourceGUID)
	elseif spellId == 324776 then
		timerBramblethornCoatCD:Start(nil, args.sourceGUID)
	elseif spellId == 326046 then
		timerStimulateResistanceCD:Start(nil, args.sourceGUID)
	elseif spellId == 463248 then
		timerExpelCD:Start(nil, args.sourceGUID)
	elseif spellId == 463256 and args:GetSrcCreatureID() == 163058 then
		timerMistWardCD:Start(nil, args.sourceGUID)
	elseif spellId == 340160 then
		timerRadiantBreathCD:Start(nil, args.sourceGUID)
	elseif spellId == 340208 then
		timerShredArmorCD:Start(nil, args.sourceGUID)
	elseif spellId == 340189 then
		timerPoolofRadianceCD:Start(nil, args.sourceGUID)
	elseif spellId == 326021 then
		timerAcidGlobuleCD:Start(nil, args.sourceGUID)
	elseif spellId == 460092 then
		timerAcidNovaCD:Start(nil, args.sourceGUID)
	elseif spellId == 324987 then
		timerMistveilBiteCD:Start(nil, args.sourceGUID)
	elseif spellId == 340300 then
		timerTongueLashingCD:Start(nil, args.sourceGUID)
	elseif spellId == 463217 then
		timerAnimaSlashCD:Start(nil, args.sourceGUID)
	elseif spellId == 323043 then
		timerBloodLettingCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 324914 then
		timerNourishtheForestCD:Start(nil, args.destGUID)
	elseif args.extraSpellId == 324776 then
		timerBramblethornCoatCD:Start(nil, args.destGUID)
	elseif args.extraSpellId == 326046 then
		timerStimulateResistanceCD:Start(nil, args.destGUID)
	elseif args.extraSpellId == 460092 then
		timerAcidNovaCD:Start(nil, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 322557 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 5) then
		specWarnSoulSplit:Show(args.destName)
		specWarnSoulSplit:Play("helpdispel")
	elseif spellId == 325224 then
		if args:IsPlayer() then
			specWarnAnimaInjection:Show()
			specWarnAnimaInjection:Play("runout")
			yellAnimaInjection:Yell()
			yellAnimaInjectionFades:Countdown(spellId)
		end
	elseif spellId == 322486 then
		if args:IsPlayer() then
			specWarnOvergrowth:Show(DBM_COMMON_L.TANK)
			specWarnOvergrowth:Play("movemelee")
		else
			warnOvergrowth:Show(args.destName)
		end
	elseif spellId == 322557 and self:IsValidWarning(args.destGUID) and args:IsDestTypeHostile() and self:AntiSpam(3, 5) then
		specWarnNourishtheForestDispel:Show(args.destName)
		specWarnNourishtheForestDispel:Play("helpdispel")
	elseif spellId == 324776 and self:IsValidWarning(args.destGUID) and args:IsDestTypeHostile() and self:AntiSpam(3, 5) then
		specWarnBramblethornCoatDispel:Show(args.destName)
		specWarnBramblethornCoatDispel:Play("helpdispel")
	elseif spellId == 326046 and self:IsValidWarning(args.destGUID) and args:IsDestTypeHostile() and self:AntiSpam(3, 5) then
		specWarnStimulateResistanceDispel:Show(args.destName)
		specWarnStimulateResistanceDispel:Play("helpdispel")
	elseif spellId == 340288 and args:IsDestTypePlayer() then
		local amount = args.amount or 1
		if amount % 2 == 0 then
			warnTripleBite:Show(args.destName, args.amount or 1)
		end
	elseif spellId == 325021 then
		warnMistveilTear:Show(args.destName)
	elseif spellId == 323043 and args:IsDestTypePlayer() and self:CheckDispelFilter("bleed") then
		specWarnBloodlettingDispel:Show(args.destName)
		specWarnBloodlettingDispel:Play("helpdispel")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 325224 then
		if args:IsPlayer() then
			yellAnimaInjectionFades:Cancel()
		end
	end
end

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 166304 then--Mistveil Stinger
		timerAnimaInjectionCD:Stop(args.destGUID)
	elseif cid == 166276 then--Mistveil Guardian
		--timerBuckingRampageCD:Stop(args.destGUID)
		timerAnimaSlashCD:Stop(args.destGUID)
	elseif cid == 173714 then--Mistveil Nightblossom
		timerPoisonousDischargeCD:Stop(args.destGUID)
	elseif cid == 164929 then--Tirnenn Villager
		timerBewilderingPollenCD:Stop(args.destGUID)
		timerOvergrowthCD:Stop(args.destGUID)
	elseif cid == 164926 then--Drust Boughbreaker
		timerBrambleBurstCD:Stop(args.destGUID)
	elseif cid == 163058 or cid == 171772 then--Mistveil Defender
--		timerSpearFlurryCD:Stop(args.destGUID)--Removed ability?
		timerExpelCD:Stop(args.destGUID)
		timerMistWardCD:Stop(args.destGUID)
	elseif cid == 164920 or cid == 172991 then--Drust Soulcleaver
		timerSoulSpiritCD:Stop(args.destGUID)
	elseif cid == 166299 then--Mistveil Tender
		timerNourishtheForestCD:Stop(args.destGUID)
	elseif cid == 166275 then--Mistveil Shaper
		timerBramblethornCoatCD:Stop(args.destGUID)
	elseif cid == 167111 then--Spinemaw Staghorn
		timerStimulateResistanceCD:Stop(args.destGUID)
		timerStimulateRegenerationCD:Stop(args.destGUID)
		timerAcidNovaCD:Stop(args.destGUID)
	elseif cid == 167113 then --Spinemaw Acidgullet
		timerVolatileAcidCD:Stop(args.destGUID)
	elseif cid == 164921 then--Drust Harvester
		timerHarvestEssenceCD:Stop(args.destGUID)
	elseif cid == 173655 then--Mistveil Matriarch
		timerRadiantBreathCD:Stop(args.destGUID)
		timerShredArmorCD:Stop(args.destGUID)
		timerPoolofRadianceCD:Stop(args.destGUID)
	elseif cid == 172312 then--Spinemaw Gorger
		timerAcidGlobuleCD:Stop(args.destGUID)
	elseif cid == 166301 then--Mistveil Stalker
		timerMistveilBiteCD:Stop(args.destGUID)
	elseif cid == 173720 then--Mistveil Gorgegullet
		timerTongueLashingCD:Stop(args.destGUID)
	elseif cid == 165111 then--Drust Spiteclaw
		timerBloodLettingCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid)
	if cid == 166304 then--Mistveil Stinger
		timerAnimaInjectionCD:Start(4, guid)
	elseif cid == 166276 then--Mistveil Guardian
		--timerBuckingRampageCD:Start(1, guid)
		timerAnimaSlashCD:Start(6.4, guid)
	elseif cid == 173714 then--Mistveil Nightblossom
		timerPoisonousDischargeCD:Start(13.1, guid)--Small Sample, could be lower. 13.1-17 confirmed so far
	elseif cid == 164929 then--Tirnenn Villager
		timerBewilderingPollenCD:Start(7.6, guid)
		timerOvergrowthCD:Start(12.5, guid)
	elseif cid == 164926 then--Drust Boughbreaker
		timerBrambleBurstCD:Start(7.8, guid)
	elseif cid == 163058 or cid == 171772 then--Mistveil Defender (171772 is the variant players don't engage with most likely)
		--timerSpearFlurryCD:Start(1, guid)--Removed ability?
		timerExpelCD:Start(4, guid)
		timerMistWardCD:Start(11.1, guid)--11-12
	elseif cid == 164920 or cid == 172991 then--Drust Soulcleaver
		timerSoulSpiritCD:Start(4.7, guid)
	elseif cid == 166299 then--Mistveil Tender
		timerNourishtheForestCD:Start(10, guid)--10-20, might not activate if ally doesn't need healing yet
	elseif cid == 166275 then--Mistveil Shaper
		timerBramblethornCoatCD:Start(7.6, guid)
	elseif cid == 167111 then--Spinemaw Staghorn
		timerStimulateResistanceCD:Start(5.6, guid)
		timerStimulateRegenerationCD:Start(13.9, guid)--Initial cast might not be timer based but health based. Recasts have a CD though
		timerAcidNovaCD:Start(10.2, guid)--10.2-14.2
	elseif cid == 167113 then --Spinemaw Acidgullet
		timerVolatileAcidCD:Start(8.5, guid)
	elseif cid == 164921 then--Drust Harvester
		timerHarvestEssenceCD:Start(10.4, guid)--10-20
	elseif cid == 173655 then--Mistveil Matriarch
		timerShredArmorCD:Start(6.9, guid)--6.9-13
		timerRadiantBreathCD:Start(9, guid)--9-16
		timerPoolofRadianceCD:Start(20, guid)--20-27
	elseif cid == 172312 then--Spinemaw Gorger
		timerAcidGlobuleCD:Start(5.3, guid)--5.3-9
	elseif cid == 166301 then--Mistveil Stalker
		timerMistveilBiteCD:Start(6, guid)
	elseif cid == 173720 then--Mistveil Gorgegullet
		timerTongueLashingCD:Start(6, guid)
	elseif cid == 165111 then--Drust Spiteclaw
		timerBloodLettingCD:Start(5, guid)--Poor sample, enemy has problematic pull detection
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop()
end
