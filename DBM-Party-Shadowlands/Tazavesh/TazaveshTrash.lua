local mod	= DBM:NewMod("TazaveshTrash", "DBM-Party-Shadowlands", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2441)
mod:RegisterZoneCombat(2441)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 356548 352390 354297 355930 355934 356001 347775 355057 355225 355584 357226 357260 356407 356404 347903 357229 355048 355464 355429 355577 356133 356843 1244650 357238 357196 353836 352796 356537 355830 356967 1240821 1240912 347721 347716 355477 1244443 355473 355479",
	"SPELL_CAST_SUCCESS 355234 355048 355057 355132 356133 368661 357260 355888 355900 355915 355934 357029 357197 357229 347775 355637 355640 347716",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 355888 355915 355980 357229 357029 355581 356407 356133 355480",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 357029",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED_UNFILTERED"
)

--[[
(ability.id = 356967) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 356967
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 180348) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 180348)
--]]
--TODO improve or clarify proxy strike warning?
--TODO, Veteran Sparkcaster spells (people don't pull this mob in logs I've searched)
local warnHardLightBaton					= mod:NewTargetNoFilterAnnounce(355888, 3, nil, "Tank|MagicDispeller")--(S3 Valid)
local warnHyperlightBomb					= mod:NewTargetAnnounce(357029, 3)
local warnRadiantPulse						= mod:NewSpellAnnounce(356548, 2)--(S3 Valid)
local warnChronolightEnhancer				= mod:NewCastAnnounce(357229, 3, nil, nil, "Tank|Healer")
local warnSuperSaison						= mod:NewCastAnnounce(356133, 3, nil, nil, "Tank|RemoveEnrage")--(S3 Valid)
local warnProxyStrike						= mod:NewCastAnnounce(352796, 3, nil, nil, "Tank|Healer")--(S3 Valid)
local warnPierce							= mod:NewCastAnnounce(1240912, 3, nil, nil, "Tank|Healer")--(S3 Valid)
local warnLetterOpener						= mod:NewCastAnnounce(347716, 3, nil, nil, "Tank|Healer")--(S3 Valid)
local warnOpenCage							= mod:NewCastAnnounce(347721, 4, nil, nil, nil, nil, nil, 3)--( S3 Valid)
local warnPhalanxField						= mod:NewSpellAnnounce(355640, 3)--(S3 Valid)
local warnForceMultiplier					= mod:NewCastAnnounce(1244443, 4, nil, nil, nil, nil, nil, 3)--(S3 Valid)
local warnQuickblade						= mod:NewSpellAnnounce(355830, 3)--(S3 Valid)
local warnQuellingStrike					= mod:NewSpellAnnounce(355637, 3)--(S3 Valid)

local specWarnGTFO							= mod:NewSpecialWarningGTFO(355581, nil, nil, nil, 1, 8)
local specWarnTidalStomp					= mod:NewSpecialWarningSpell(355429, nil, nil, nil, 2, 2)
local yellQuickblade						= mod:NewShortYell(355830)
local specWarnDisruptionGrenade				= mod:NewSpecialWarningDodge(355900, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnRiftBlasts					= mod:NewSpecialWarningDodge(352390, nil, nil, nil, 2, 2)
local specWarnLightshardRetreat				= mod:NewSpecialWarningDodge(357197, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnDriftingStar					= mod:NewSpecialWarningDodge(357226, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnVolatilePufferfish			= mod:NewSpecialWarningDodge(355234, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnBoulderThrow					= mod:NewSpecialWarningDodge(355464, nil, nil, nil, 2, 2)
local specWarnCrackle						= mod:NewSpecialWarningDodge(355577, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnTidalBurst					= mod:NewSpecialWarningDodge(1244650, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnSwordToss						= mod:NewSpecialWarningDodge(368661, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnBeamSplicer					= mod:NewSpecialWarningDodge(356001, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnEnergizedSlam					= mod:NewSpecialWarningDodge(1240821, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnShockMines					= mod:NewSpecialWarningDodge(355473, nil, nil, nil, 2, 2)--(S3 Valid)
local specWarnChronolightEnhancer			= mod:NewSpecialWarningRun(357229, false, nil, nil, 4, 2)--(S3 Valid)
local specWarnChargedPulse					= mod:NewSpecialWarningRun(355584, nil, nil, nil, 4, 2)--(S3 Valid)
local specWarnHyperlightBomb				= mod:NewSpecialWarningMoveAway(357029, nil, nil, nil, 1, 2)--(S3 Valid)
local yellHyperlightBomb					= mod:NewYell(357029)
local yellHyperlightBombFades				= mod:NewShortFadesYell(357029)
local specWarnLethalForce					= mod:NewSpecialWarningYou(355480, nil, nil, nil, 1, 2)--(S3 Valid)
local specWarnInvigoratingFishStick			= mod:NewSpecialWarningSwitch(355132, "-Healer", nil, nil, 1, 2)--(S3 Valid)
local specWarnWanderingPulsar				= mod:NewSpecialWarningSwitch(357238, "-Healer", nil, nil, 1, 2)
local specWarnShellcrackerDefensive			= mod:NewSpecialWarningDefensive(355048, nil, nil, nil, 1, 2)--(S3 Valid)
local specWarnHyperlightBackhand			= mod:NewSpecialWarningDefensive(356967, nil, nil, nil, 1, 2)--(S3 Valid)
local specWarnPowerKick						= mod:NewSpecialWarningDefensive(355477, nil, nil, nil, 1, 2)
local specWarnSparkBurn						= mod:NewSpecialWarningInterrupt(355930, false, nil, nil, 1, 2)
local specWarnHardLightBarrier				= mod:NewSpecialWarningInterrupt(355934, "HasInterrupt", nil, nil, 1, 2)--(S3 Valid)
local specWarnHyperlightBolt				= mod:NewSpecialWarningInterrupt(354297, false, nil, 2, 1, 2)--Spammy if interrupt off CD (S3 Valid)
local specWarnSpamFilter					= mod:NewSpecialWarningInterrupt(347775, "HasInterrupt", nil, nil, 1, 2)
local specWarnJunkMail						= mod:NewSpecialWarningInterrupt(347903, false, nil, nil, 1, 2)--spammed, off just in case
local specWarnCryofMrrggllrrgg				= mod:NewSpecialWarningInterrupt(355057, "HasInterrupt", nil, nil, 1, 2)--(S3 Valid)
local specWarnWaterbolt						= mod:NewSpecialWarningInterrupt(355225, false, nil, nil, 1, 2)--(S3 Valid)
local specWarnUnstableRift					= mod:NewSpecialWarningInterrupt(357260, "HasInterrupt", nil, nil, 1, 2)
local specWarnAncientDread					= mod:NewSpecialWarningInterrupt(356407, "HasInterrupt", nil, nil, 1, 2)
local specWarnLavaBreath					= mod:NewSpecialWarningInterrupt(356404, "HasInterrupt", nil, nil, 1, 2)
local specWarnBrackishBolt					= mod:NewSpecialWarningInterrupt(356843, "HasInterrupt", nil, nil, 1, 2)--(S3 Valid)
local specWarnEmpGlyphofRestraint			= mod:NewSpecialWarningInterrupt(356537, "HasInterrupt", nil, nil, 1, 2)--(S3 Valid)
local specWarnGlyphofRestraint				= mod:NewSpecialWarningDispel(355915, "RemoveMagic", nil, nil, 1, 2)--(S3 Valid)
local specWarnRefractionShield				= mod:NewSpecialWarningDispel(355980, "MagicDispeller", nil, nil, 1, 2)--(S3 Valid)
local specWarnAncientDreadDispel			= mod:NewSpecialWarningDispel(356407, "RemoveCurse", nil, nil, 1, 2)

local timerVolatilePufferfishCD				= mod:NewCDNPTimer(17, 355234, nil, nil, nil, 3)
local timerShellcrackerCD					= mod:NewCDNPTimer(14.3, 355048, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--15.8 minus cast time
local timerCryofMrrggllrrggCD				= mod:NewCDPNPTimer(33.9, 355057, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerInvigoratingFishStickCD			= mod:NewCDPNPTimer(27.9, 355132, nil, nil, nil, 1)
local timerBoulderThrowCD					= mod:NewCDNPTimer(23, 355464, nil, nil, nil, 3)
local timerTidalStompCD						= mod:NewCDPNPTimer(20, 355429, nil, nil, nil, 2)
local timerChargedPulseCD					= mod:NewCDNPTimer(20.6, 355584, nil, nil, nil, 3)--20.6-26
local timerCrackleCD						= mod:NewCDNPTimer(8.5, 355577, nil, nil, nil, 3)--8.5-20.6
local timerSuperSaisonCD					= mod:NewCDNPTimer(30.3, 356133, nil, nil, nil, 5)--32.8 minus cast time
local timerTidalBurstCD						= mod:NewCDNPTimer(18.2, 1244650, nil, nil, nil, 2)
local timerSwordTossCD						= mod:NewCDNPTimer(14.5, 368661, nil, nil, nil, 3)
local timerDriftingStarCD					= mod:NewCDNPTimer(16.6, 357226, nil, nil, nil, 3)
local timerWanderingPulsarCD				= mod:NewCDNPTimer(26.7, 357238, nil, nil, nil, 1)
local timerUnstableRiftCD					= mod:NewCDPNPTimer(21.5, 357260, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerProxyStrikeCD					= mod:NewCDNPTimer(30.4, 352796, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Multiple enemies and CDs
local timerRadiantPulseCD					= mod:NewCDNPTimer(26.8, 356548, nil, nil, nil, 2)--Multiple enemies and CDs
local timerHardLightBatonCD					= mod:NewCDNPTimer(24.3, 355888, nil, nil, nil, 3)--Multiple enemies and CDs
local timerDisruptionGrenadeCD				= mod:NewCDNPTimer(18.2, 355900, nil, nil, nil, 3)
local timerGlyphofRestraintCD				= mod:NewCDNPTimer(17, 355915, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerHardLightBarrierCD				= mod:NewCDNPTimer(21.2, 355934, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBeamSplicerCD					= mod:NewCDNPTimer(23.1, 356001, nil, nil, nil, 3)
local timerEmpGlyphofRestraintCD			= mod:NewCDNPTimer(23.1, 356537, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRiftBlastsCD						= mod:NewCDNPTimer(23.1, 352390, nil, nil, nil, 3)
local timerQuickbladeCD						= mod:NewCDNPTimer(14.2, 355830, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerHyperlightBombCD					= mod:NewCDNPTimer(18.2, 357029, nil, nil, nil, 3)
local timerLightshardRetreatCD				= mod:NewCDNPTimer(15.8, 357197, nil, nil, nil, 3)
--local timerHyperlightBackhandCD			= mod:NewCDNPTimer(16.2, 356967, nil, "Tank|Healer", nil, 5)--Almost no groups see 1 cast, let alone 2
local timerChronolightEnhancerCD			= mod:NewCDNPTimer(28.2, 357229, nil, nil, nil, 5)
local timerEnergizedSlamCD					= mod:NewCDNPTimer(23.1, 1240821, nil, nil, nil, 5)
local timerPierceCD							= mod:NewCDNPTimer(21.8, 1240912, nil, "Tank|Healer", nil, 5)
local timerLetterOpenerCD					= mod:NewCDNPTimer(25.2, 347716, nil, "Tank|Healer", nil, 5)
local timerSpamFilterCD						= mod:NewCDNPTimer(21, 347775, nil, nil, nil, 4)
local timerQuellingStrikeCD					= mod:NewCDNPTimer(15.7, 355637, nil, nil, nil, 3)
local timerPhalanxFieldCD					= mod:NewCDNPTimer(30.3, 355640, nil, nil, nil, 5)
local timerPowerKickCD						= mod:NewCDNPTimer(9.4, 355477, nil, nil, nil, 5)--Only know Commanders
local timerForceMultiplierCD				= mod:NewCDNPTimer(29.1, 1244443, nil, nil, nil, 5)
local timerShockMinesCD						= mod:NewCDNPTimer(26.4, 355473, nil, nil, nil, 3)
local timerLethalForceCD					= mod:NewCDNPTimer(13.2, 355479, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 356548 then
		local timer = args:GetSrcCreatureID() == 179334 and 26.8 or 30.4 --Portalmancer Zo'honn <Cartel Zo>, Gatewarden Zo'mazz <Cartel Zo>
		if self:AntiSpam(3, 4) then
			warnRadiantPulse:Show()
		end
		timerRadiantPulseCD:Start(timer, args.sourceGUID)
	elseif spellId == 352390 then
		timerRiftBlastsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRiftBlasts:Show()
			specWarnRiftBlasts:Play("watchstep")
		end
	elseif spellId == 357226 then
		timerDriftingStarCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDriftingStar:Show()
			specWarnDriftingStar:Play("watchorb")
		end
	elseif (spellId == 353836 or spellId == 354297 or spellId == 357196) and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnHyperlightBolt:Show(args.sourceName)
		specWarnHyperlightBolt:Play("kickcast")
	elseif spellId == 355930 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSparkBurn:Show(args.sourceName)
		specWarnSparkBurn:Play("kickcast")
	elseif spellId == 355934 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnHardLightBarrier:Show(args.sourceName)
		specWarnHardLightBarrier:Play("kickcast")
	elseif spellId == 347775 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSpamFilter:Show(args.sourceName)
		specWarnSpamFilter:Play("kickcast")
	elseif spellId == 347903 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnJunkMail:Show(args.sourceName)
		specWarnJunkMail:Play("kickcast")
	elseif spellId == 355057 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCryofMrrggllrrgg:Show(args.sourceName)
			specWarnCryofMrrggllrrgg:Play("kickcast")
		end
	elseif spellId == 355225 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnWaterbolt:Show(args.sourceName)
		specWarnWaterbolt:Play("kickcast")
	elseif spellId == 357260 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnUnstableRift:Show(args.sourceName)
		specWarnUnstableRift:Play("kickcast")
	elseif spellId == 356407 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnAncientDread:Show(args.sourceName)
		specWarnAncientDread:Play("kickcast")
	elseif spellId == 356404 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnLavaBreath:Show(args.sourceName)
		specWarnLavaBreath:Play("kickcast")
	elseif spellId == 356843 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBrackishBolt:Show(args.sourceName)
		specWarnBrackishBolt:Play("kickcast")
	elseif spellId == 356001 then
		timerBeamSplicerCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBeamSplicer:Show()
			specWarnBeamSplicer:Play("watchstep")
		end
	elseif spellId == 357229 then
		warnChronolightEnhancer:Show()
	elseif spellId == 355584 then
		timerChargedPulseCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnChargedPulse:Show()
			specWarnChargedPulse:Play("justrun")
		end
	elseif spellId == 355048 and self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
		specWarnShellcrackerDefensive:Show()
		specWarnShellcrackerDefensive:Play("defensive")
	elseif spellId == 355464 then
		if self:AntiSpam(3, 2) then
			specWarnBoulderThrow:Show()
			specWarnBoulderThrow:Play("watchstep")
		end
		timerBoulderThrowCD:Start(nil, args.sourceGUID)
	elseif spellId == 355429 then
		if self:AntiSpam(3, 4) then
			specWarnTidalStomp:Show()
			specWarnTidalStomp:Play("watchstep")
		end
		timerTidalStompCD:Start(nil, args.sourceGUID)
	elseif spellId == 355577 then
		if self:AntiSpam(3, 2) then
			specWarnCrackle:Show()
			specWarnCrackle:Play("watchstep")
		end
		timerCrackleCD:Start(nil, args.sourceGUID)
	elseif spellId == 356133 then
		if self:AntiSpam(3, 5) then
			warnSuperSaison:Show()
		end
	elseif spellId == 357238 then
		timerWanderingPulsarCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnWanderingPulsar:Show()
			specWarnWanderingPulsar:Play("targetchange")
		end
	elseif spellId == 352796 then
		if self:AntiSpam(3, 5) then
			warnProxyStrike:Show()
		end
		--Gatewarden timer not known so purposely set high to find it quickly from debug prints
		local timer = args:GetSrcCreatureID() == 177808 and 30.4 or 50.4 --Armored Overseer <Cartel Zo>, Gatewarden Zo'mazz <Cartel Zo>
		timerProxyStrikeCD:Start(timer, args.sourceGUID)
	elseif spellId == 356537 then
		timerEmpGlyphofRestraintCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnEmpGlyphofRestraint:Show(args.sourceName)
			specWarnEmpGlyphofRestraint:Play("kickcast")
		end
	elseif spellId == 355830 then
		timerQuickbladeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnQuickblade:Show()
		end
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			yellQuickblade:Yell()
		end
	elseif spellId == 356967 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnHyperlightBackhand:Show()
			specWarnHyperlightBackhand:Play("carefly")
		end
	elseif spellId == 1240821 then
		timerEnergizedSlamCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnEnergizedSlam:Show()
			specWarnEnergizedSlam:Play("watchstep")
		end
	elseif spellId == 1240912 then
		timerPierceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnPierce:Show()
		end
	elseif spellId == 347721 and self:AntiSpam(3, 6) then
		warnOpenCage:Show()
		warnOpenCage:Play("crowdcontrol")
	elseif spellId == 347716 then
		if self:AntiSpam(3, 5) then
			warnLetterOpener:Show()
		end
	elseif spellId == 355477 then
		local timer = args:GetSrcCreatureID() == 179821 and 9.4 or nil--CD for other mob not known
		if timer then
			timerPowerKickCD:Start(timer, args.sourceGUID)
		end
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnPowerKick:Show()
			specWarnPowerKick:Play("carefly")
		end
	elseif spellId == 1244443 then
		timerForceMultiplierCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnForceMultiplier:Show()
			warnForceMultiplier:Play("crowdcontrol")
		end
	elseif spellId == 355473 then
		timerShockMinesCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnShockMines:Show()
			specWarnShockMines:Play("watchstep")
		end
	elseif spellId == 355479 then
		timerLethalForceCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 355234 then
		timerVolatilePufferfishCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnVolatilePufferfish:Show()
			specWarnVolatilePufferfish:Play("watchstep")
		end
	elseif spellId == 355048 then
		timerShellcrackerCD:Start(nil, args.sourceGUID)
	elseif spellId == 355057 then
		timerCryofMrrggllrrggCD:Start(30.9, args.sourceGUID)
	elseif spellId == 355132 then
		timerInvigoratingFishStickCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnInvigoratingFishStick:Show()
			specWarnInvigoratingFishStick:Play("attacktotem")
		end
	elseif spellId == 356133 then
		timerSuperSaisonCD:Start(nil, args.sourceGUID)
	elseif spellId == 368661 then
		timerSwordTossCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnSwordToss:Show()
			specWarnSwordToss:Play("watchstep")
		end
	elseif spellId == 357260 then
		timerUnstableRiftCD:Start(nil, args.sourceGUID)
	elseif spellId == 355888 then
		timerHardLightBatonCD:Start(nil, args.sourceGUID)
	elseif spellId == 355900 then
		timerDisruptionGrenadeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDisruptionGrenade:Show()
			specWarnDisruptionGrenade:Play("watchstep")
		end
	elseif spellId == 355915 then
		timerGlyphofRestraintCD:Start(nil, args.sourceGUID)
	elseif spellId == 355934 then
		timerHardLightBarrierCD:Start(nil, args.sourceGUID)
	elseif spellId == 357029 then
		timerHyperlightBombCD:Start(nil, args.sourceGUID)
	elseif spellId == 357197 then
		timerLightshardRetreatCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnLightshardRetreat:Show()
			specWarnLightshardRetreat:Play("watchstep")
		end
	elseif spellId == 357229 then
		timerChronolightEnhancerCD:Start(nil, args.sourceGUID)
	elseif spellId == 347775 then
		timerSpamFilterCD:Start(nil, args.sourceGUID)
	elseif spellId == 355637 then
		if self:AntiSpam(3, 6) then
			warnQuellingStrike:Show()
		end
		timerQuellingStrikeCD:Start(nil, args.sourceGUID)
	elseif spellId == 355640 then
		timerPhalanxFieldCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnPhalanxField:Show()
			warnPhalanxField:Play("crowdcontrol")
		end
	elseif spellId == 347716 then
		timerLetterOpenerCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 355057 then
		timerCryofMrrggllrrggCD:Start(30.9, args.sourceGUID)
	elseif args.extraSpellId == 357260 then
		timerUnstableRiftCD:Start(nil, args.sourceGUID)
	elseif args.extraSpellId == 355934 then
		timerHardLightBarrierCD:Start(nil, args.sourceGUID)
	elseif args.extraSpellId == 347775 then
		timerSpamFilterCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 355888 then
		warnHardLightBaton:Show(args.destName)
	elseif spellId == 355915 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 5) then
		specWarnGlyphofRestraint:Show(args.destName)
		specWarnGlyphofRestraint:Play("helpdispel")
	elseif spellId == 355980 and not args:IsDestTypePlayer() and self:AntiSpam(3, 5) then
		specWarnRefractionShield:Show(args.destName)
		specWarnRefractionShield:Play("helpdispel")
	elseif spellId == 356407 and args:IsDestTypePlayer() and self:CheckDispelFilter("curse") and self:AntiSpam(3, 5) then
		specWarnAncientDreadDispel:Show(args.destName)
		specWarnAncientDreadDispel:Play("helpdispel")
	elseif spellId == 357229 and self:AntiSpam(3, 1) then
		specWarnChronolightEnhancer:Show()
		specWarnChronolightEnhancer:Play("justrun")
	elseif spellId == 357029 then
		if args:IsPlayer() then
			specWarnHyperlightBomb:Show()
			specWarnHyperlightBomb:Play("runout")
			yellHyperlightBomb:Yell()
			yellHyperlightBombFades:Countdown(spellId)
		else
			warnHyperlightBomb:Show(args.destName)
		end
	elseif spellId == 355581 and args:IsPlayer() then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 355480 and args:IsPlayer() then
		specWarnLethalForce:Show()
		specWarnLethalForce:Play("lineyou")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 357029 and args:IsPlayer() then
		yellHyperlightBombFades:Cancel()
	end
end

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 178142 then--Murkbrine Fishmancer
		timerVolatilePufferfishCD:Stop(args.destGUID)
	elseif cid == 178139 then--Murkbrine Shellcrusher
		timerShellcrackerCD:Stop(args.destGUID)
		timerCryofMrrggllrrggCD:Stop(args.destGUID)
	elseif cid == 178141 then--Murkbrine Scalebinder
		timerInvigoratingFishStickCD:Stop(args.destGUID)
	elseif cid == 178165 then--Coastwalker Goliath
		timerBoulderThrowCD:Stop(args.destGUID)
		timerTidalStompCD:Stop(args.destGUID)
	elseif cid == 178171 then--Stormforged Guardian
		timerChargedPulseCD:Stop(args.destGUID)
		timerCrackleCD:Stop(args.destGUID)
	elseif cid == 180015 then--Burly Deckhand
		timerSuperSaisonCD:Stop(args.destGUID)
	elseif cid == 179388 then--Hourglass Tidesage
		timerTidalBurstCD:Stop(args.destGUID)
	elseif cid == 179386 then--Corsair Officer
		timerSwordTossCD:Stop(args.destGUID)
	elseif cid == 180429 then--AdornedStarseer
		timerDriftingStarCD:Stop(args.destGUID)
		timerWanderingPulsarCD:Stop(args.destGUID)
	elseif cid == 177808 then--Armored Overseer <Cartel Zo>
		timerProxyStrikeCD:Stop(args.destGUID)
		timerBeamSplicerCD:Stop(args.destGUID)
	elseif cid == 178392 then--Gatewarden Zo'mazz <Cartel Zo>
		timerProxyStrikeCD:Stop(args.destGUID)
		timerRadiantPulseCD:Stop(args.destGUID)
	elseif cid == 179334 then--Portalmancer Zo'honn <Cartel Zo>
		timerRadiantPulseCD:Stop(args.destGUID)
		timerEmpGlyphofRestraintCD:Stop(args.destGUID)
		timerRiftBlastsCD:Stop(args.destGUID)
	elseif cid == 177807 then--Customs Security
		timerHardLightBatonCD:Stop(args.destGUID)
		timerDisruptionGrenadeCD:Stop(args.destGUID)
	elseif cid == 177816 then--Interrogation Specialist
		timerGlyphofRestraintCD:Stop(args.destGUID)
	elseif cid == 177817 then--Support Officer
		timerHardLightBarrierCD:Stop(args.destGUID)
	elseif cid == 179893 then--Cartel Skulker
		timerQuickbladeCD:Stop(args.destGUID)
	elseif cid == 180335 then--Cartel Smuggler
		timerHyperlightBombCD:Stop(args.destGUID)
	elseif cid == 180336 then--Cartel Wiseguy
		timerLightshardRetreatCD:Stop(args.destGUID)
	elseif cid == 180348 then--Cartel Muscle
--		timerHyperlightBackhandCD:Stop(args.destGUID)
		timerChronolightEnhancerCD:Stop(args.destGUID)
	elseif cid == 246285 then--Bazaar Overseer
		timerEnergizedSlamCD:Stop(args.destGUID)
		timerPierceCD:Stop(args.destGUID)
	elseif cid == 176394 then--Post Worker
		timerLetterOpenerCD:Stop(args.destGUID)
	elseif cid == 176395 then--Mailemental
		timerSpamFilterCD:Stop(args.destGUID)
	elseif cid == 179840 then--Market Peacekeeper
		timerQuellingStrikeCD:Stop(args.destGUID)
		timerPhalanxFieldCD:Stop(args.destGUID)
	elseif cid == 179842 then--Commerce Enforcer
		timerPowerKickCD:Stop(args.destGUID)
		timerForceMultiplierCD:Stop(args.destGUID)
	elseif cid == 179821 then--Commander Zo'far
		timerShockMinesCD:Stop(args.destGUID)
		timerPowerKickCD:Stop(args.destGUID)
		timerLethalForceCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 178142 then--Murkbrine Fishmancer
		timerVolatilePufferfishCD:Start(17.2-delay, guid)--iffy
	elseif cid == 178139 then--Murkbrine Shellcrusher
		timerShellcrackerCD:Start(12.1-delay, guid)--iffy, seems to be possible to massively delay
--		timerCryofMrrggllrrggCD:Start(14-delay, guid)--extremeley variable, likley health based
	elseif cid == 178141 then--Murkbrine Scalebinder
		timerInvigoratingFishStickCD:Start(13.2-delay, guid)--iffy, seems to be possible to massively delay
	elseif cid == 178165 then--Coastwalker Goliath
		timerTidalStompCD:Start(11-delay, guid)--iffy, seems to be possible to massively delay
		timerBoulderThrowCD:Start(17-delay, guid)--iffy
	elseif cid == 178171 then--Stormforged Guardian
		timerCrackleCD:Start(4.8-delay, guid)
		timerChargedPulseCD:Start(11-delay, guid)
	elseif cid == 180015 then--Burly Deckhand
		timerSuperSaisonCD:Start(11-delay, guid)
	elseif cid == 179388 then--Hourglass Tidesage
		timerTidalBurstCD:Start(9.4-delay, guid)
	elseif cid == 179386 then--Corsair Officer
		timerSwordTossCD:Start(7.1-delay, guid)
	elseif cid == 180429 then--AdornedStarseer
		timerDriftingStarCD:Start(7.2-delay, guid)
		timerWanderingPulsarCD:Start(13.3-delay, guid)
	elseif cid == 177808 then--Armored Overseer <Cartel Zo>
		timerBeamSplicerCD:Start(7-delay, guid)
		timerProxyStrikeCD:Start(11-delay, guid)
	elseif cid == 178392 then--Gatewarden Zo'mazz <Cartel Zo>
		timerProxyStrikeCD:Start(6-delay, guid)
		timerRadiantPulseCD:Start(12.1-delay, guid)
	elseif cid == 179334 then--Portalmancer Zo'honn <Cartel Zo>
--		timerRadiantPulseCD:Start(14.5-delay, guid)--Used instantly on engage
		timerRiftBlastsCD:Start(7.2-delay, guid)
		timerEmpGlyphofRestraintCD:Start(11-delay, guid)
	elseif cid == 177807 then--Customs Security
		timerHardLightBatonCD:Start(2.3-delay, guid)
		timerDisruptionGrenadeCD:Start(10.5-delay, guid)
	elseif cid == 177816 then--Interrogation Specialist
		timerGlyphofRestraintCD:Start(7-delay, guid)
--	elseif cid == 177817 then--Support Officer
--		timerHardLightBarrierCD:Start(11-delay, guid)--Used Instantly on engage
	elseif cid == 179893 then--Cartel Skulker
		timerQuickbladeCD:Start(6-delay, guid)
	elseif cid == 180335 then--Cartel Smuggler
		timerHyperlightBombCD:Start(4-delay, guid)
	elseif cid == 180336 then--Cartel Wiseguy
		timerLightshardRetreatCD:Start(16.2-delay, guid)
--	elseif cid == 180348 then--Cartel Muscle
--		timerChronolightEnhancerCD:Start(12.2-delay, guid)--Most people skip this mobs so logs don't really exist
--		timerHyperlightBackhandCD:Start(16.2-delay, guid)
	elseif cid == 246285 then--Bazaar Overseer
		timerEnergizedSlamCD:Start(10-delay, guid)
		timerPierceCD:Start(16-delay, guid)
	elseif cid == 176394 then--Post Worker
		timerLetterOpenerCD:Start(6.8-delay, guid)
	elseif cid == 176395 then--Mailemental
		timerSpamFilterCD:Start(14.6-delay, guid)
	elseif cid == 179840 then--Market Peacekeeper
		timerQuellingStrikeCD:Start(2.9-delay, guid)
		timerPhalanxFieldCD:Start(8.3-delay, guid)
	elseif cid == 179842 then--Commerce Enforcer
		timerPowerKickCD:Start(8-delay, guid)--Iffy, bad data
		--timerForceMultiplierCD:Start(7.3-delay, guid)
	elseif cid == 179821 then--Commander Zo'far
		timerShockMinesCD:Start(3-delay, guid)--Iffy, bad data
		timerPowerKickCD:Start(8-delay, guid)--Iffy, bad data
		timerLethalForceCD:Start(6-delay, guid)--Iffy, bad data
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end

--Tidal burst is not in combat log
function mod:UNIT_SPELLCAST_SUCCEEDED_UNFILTERED(uId, castGUID, spellId)
	if not self.Options.Enabled then return end
	if spellId == 1244650 and self:AntiSpam(3, castGUID) then
		local guid = UnitGUID(uId)
		if self:AntiSpam(3, 2) then
			specWarnTidalBurst:Show()
			specWarnTidalBurst:Play("watchstep")
		end
		timerTidalBurstCD:Start(nil, guid)
	end
end
