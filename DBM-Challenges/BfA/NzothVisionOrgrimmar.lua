local mod	= DBM:NewMod("d1995", "DBM-Challenges", 2)--1993 Stormwind 1995 Org
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")

mod:RegisterCombat("scenario", 2212, 2828)
mod:RegisterZoneCombat(2828)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 297822 297746 304976 297574 304251 306726 299110 307863 300351 300388 304101 304282 306001 306199 303589 305875 306828 306617 300388 296537 305378 298630 298033 305236 304169 298502 297315 307870 299055 304165 305369 296718",
	"SPELL_AURA_APPLIED 311390 315385 311641 304165",--316481
	"SPELL_AURA_APPLIED_DOSE 311390",
	"SPELL_CAST_SUCCESS 297237 298033 297746",
	"SPELL_PERIODIC_DAMAGE 303594 313303",
	"SPELL_PERIODIC_MISSED 303594 313303",
	"SPELL_INTERRUPT",
	"UNIT_DIED",
	"ENCOUNTER_START",
	"UNIT_SPELLCAST_SUCCEEDED_UNFILTERED",
	"UNIT_SPELLCAST_INTERRUPTED_UNFILTERED",
	"UNIT_AURA player",
	"GOSSIP_SHOW",
	"UNIT_POWER_UPDATE player"
)

--TODO, maybe add https://ptr.wowhead.com/spell=298510/aqiri-mind-toxin
--TODO, improve https://ptr.wowhead.com/spell=306001/explosive-leap warning if can get throw target
--TODO, can https://ptr.wowhead.com/spell=305875/visceral-fluid be dodged? If so upgrade the warning
--TODO, add gamons whirlwind? he uses every 7.3 seconds and it's not really most threatening thing, just a small amount of extra damage
--TODO, horrifying shout nampelate timer, gotta let mobs live longer
--TODO, add collagulated horror
local warnSanity					= mod:NewCountAnnounce(307831, 3)
local warnSanityOrb					= mod:NewCastAnnounce(307870, 1)
local warnGiftoftheTitans			= mod:NewSpellAnnounce(313698, 1)
local warnScorchedFeet				= mod:NewSpellAnnounce(315385, 4)
--Extra Abilities (used by main boss and the area LTs)
local warnCriesoftheVoid			= mod:NewCastAnnounce(304976, 4)
local warnVoidQuills				= mod:NewCastAnnounce(304251, 3)
--Other notable abilities by mini bosses/trash
local warnExplosiveLeap				= mod:NewCastAnnounce(306001, 3)
local warnHorrifyingShout			= mod:NewCastAnnounce(305378, 4)
local warnTouchoftheAbyss			= mod:NewCastAnnounce(298033, 4)
local warnToxicBreath				= mod:NewSpellAnnounce(298502, 2)
local warnCallGamon					= mod:NewSpellAnnounce(398139, 2, "236454")
local warnWarStomp					= mod:NewSpellAnnounce(314723, 4)
local warnBreakSpirit				= mod:NewCastAnnounce(305369, 3)

--General (GTFOs and Affixes)
local specwarnSanity				= mod:NewSpecialWarningCount(307831, nil, nil, nil, 1, 10)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(303594, nil, nil, nil, 1, 8)
local specWarnEntomophobia			= mod:NewSpecialWarningJump(311389, nil, nil, nil, 1, 6)
--local specWarnHauntingShadows		= mod:NewSpecialWarningDodge(306545, false, nil, 4, 1, 2)
local specWarnScorchedFeet			= mod:NewSpecialWarningYou(315385, false, nil, 2, 1, 2)
local yellScorchedFeet				= mod:NewYell(315385)
--local specWarnSplitPersonality		= mod:NewSpecialWarningYou(316481, nil, nil, nil, 1, 2)
local specWarnWaveringWill			= mod:NewSpecialWarningReflect(311641, "false", nil, nil, 1, 2)--Off by default, it's only 5%, but that might matter to some classes
--Thrall
local specWarnSurgingDarkness		= mod:NewSpecialWarningDodge(297822, nil, nil, nil, 2, 2)
local specWarnSeismicSlam			= mod:NewSpecialWarningDodge(297746, nil, nil, nil, 2, 15)
local yellSeismicSlam				= mod:NewYell(297746)
local yellDefiledGround				= mod:NewYell(306726)
--Extra Abilities (used by Thrall and the area LTs)
local specWarnHopelessness			= mod:NewSpecialWarningMoveTo(297574, nil, nil, nil, 1, 2)
local specWarnDefiledGround			= mod:NewSpecialWarningDodge(306726, nil, nil, nil, 2, 15)
--Other notable abilities by mini bosses/trash
local specWarnOrbofAnnihilation		= mod:NewSpecialWarningDodge(299110, nil, nil, nil, 2, 2)
local specWarnDarkForce				= mod:NewSpecialWarningDodge(299055, nil, nil, nil, 1, 15)
local specWarnVoidTorrent			= mod:NewSpecialWarningYou(307863, nil, nil, nil, 4, 2)
local yellVoidTorrent				= mod:NewYell(307863)
local specWarnSurgingFist			= mod:NewSpecialWarningDodge(300351, nil, nil, nil, 2, 2)
local specWarnDecimator				= mod:NewSpecialWarningDodge(300412, nil, nil, nil, 2, 2)
local specWarnDesperateRetching		= mod:NewSpecialWarningYou(304165, nil, nil, nil, 1, 2)
local yellDesperateRetching			= mod:NewYell(304165)
local specWarnDesperateRetchingD	= mod:NewSpecialWarningDispel(304165, "RemoveDisease", nil, nil, 1, 2)
local specWarnMaddeningRoar			= mod:NewSpecialWarningRun(304101, nil, nil, nil, 4, 2)
local specWarnStampedingCorruption	= mod:NewSpecialWarningDodge(304282, nil, nil, nil, 2, 2)
local specWarnHowlinginPain			= mod:NewSpecialWarningCast(306199, "SpellCaster", nil, nil, 1, 2)
local specWarnSanguineResidue		= mod:NewSpecialWarningDodge(303589, nil, nil, nil, 2, 2)
local specWarnRingofChaos			= mod:NewSpecialWarningDodge(306617, nil, nil, nil, 2, 2)
local specWarnHorrifyingShout		= mod:NewSpecialWarningInterrupt(305378, "HasInterrupt", nil, nil, 1, 2)
local specWarnMentalAssault			= mod:NewSpecialWarningInterrupt(296537, "HasInterrupt", nil, nil, 1, 2)
local specWarnTouchoftheAbyss		= mod:NewSpecialWarningInterrupt(298033, "HasInterrupt", nil, nil, 1, 2)
local specWarnVenomBolt				= mod:NewSpecialWarningInterrupt(305236, "HasInterrupt", nil, nil, 1, 2)
local specWarnVoidBuffet			= mod:NewSpecialWarningInterrupt(297315, "HasInterrupt", nil, nil, 1, 2)
local specWarnShockwave				= mod:NewSpecialWarningDodge(298630, nil, nil, nil, 2, 15)
local specWarnVisceralFluid			= mod:NewSpecialWarningDodge(305875, nil, nil, nil, 2, 2)
local specWarnToxicVolley			= mod:NewSpecialWarningDodge(304169, nil, nil, nil, 2, 2)
local specWarnRupture				= mod:NewSpecialWarningDodge(305155, nil, nil, nil, 2, 2)
local specWarnEndlessHungerTotem	= mod:NewSpecialWarningSwitch(297237, nil, nil, nil, 1, 2)
local specWarnDarkSmash				= mod:NewSpecialWarningDodge(296718, nil, nil, nil, 2, 2)

--General
local timerGiftoftheTitan			= mod:NewBuffFadesTimer(20, 313698, nil, nil, nil, 5)
--Affixes/Masks
local timerDarkImaginationCD		= mod:NewCDTimer(60, 315976, nil, nil, nil, 1, 296733)
--Thrall
local timerSurgingDarknessCD		= mod:NewCDTimer(20.6, 297822, nil, nil, nil, 3)
local timerSeismicSlamCD			= mod:NewCDTimer(12.1, 297746, nil, nil, nil, 3)
--Extra Abilities (used by Thrall and the area LTs)
local timerDefiledGroundCD			= mod:NewCDTimer(12.1, 306726, nil, nil, nil, 3)
--Other notable elite timers (mini bosses use hybrid timers, trash only use nameplate only)
local timerSurgingFistCD			= mod:NewCDTimer(9.7, 300351, nil, nil, nil, 3)
local timerDecimatorCD				= mod:NewCDTimer(9.7, 300412, nil, nil, nil, 3)
local timerToxicBreathCD			= mod:NewCDTimer(7.3, 298502, nil, nil, nil, 3)
local timerToxicVolleyCD			= mod:NewCDTimer(7.3, 304169, nil, nil, nil, 3)
local timerHorrifyingShout			= mod:NewCastNPTimer(2.5, 305378, nil, nil, nil, 4)
local timerTouchoftheAbyss			= mod:NewCastNPTimer(2, 298033, nil, nil, nil, 4)
local timerTouchoftheAbyssCD		= mod:NewCDPNPTimer(18.6, 298033, nil, nil, nil, 4)--Needs bigger sample
local timerDarkForceCD				= mod:NewCDTimer(12.1, 299055, nil, nil, nil, 3)
local timerOrbofAnnihilationCD		= mod:NewVarTimer("v4.8-7.3", 299110, nil, nil, nil, 3)
local timerExplosiveLeapCD			= mod:NewCDTimer(12.1, 306001, nil, nil, nil, 3, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)--Priority CD
local timerDesperateRetchingCD		= mod:NewCDTimer(16.9, 304165, nil, nil, nil, 3, nil, DBM_COMMON_L.DISEASE_ICON)
local timerMaddeningRoarCD			= mod:NewCDTimer(20, 304101, nil, nil, nil, 3)--not fully vetted, need more than single cast
local timerWarStompCD				= mod:NewCDPNPTimer(15.7, 314723, nil, nil, nil, 2)
local timerBreakSpiritCD			= mod:NewCDNPTimer(9.7, 305369, nil, nil, nil, 5)
local timerShockwaveCD				= mod:NewCDNPTimer(9.7, 298630, nil, nil, nil, 3)
local timerDarkSmashCD				= mod:NewCDNPTimer(7.3, 296718, nil, nil, nil, 3)

mod:AddInfoFrameOption(307831, true)
mod:AddGossipOption(true, "Action")

--AntiSpam Throttles: 1-Unique ability, 2-watch steps, 3-shockwaves, 4-GTFOs, 5--Role/Defensive
local playerName = UnitName("player")
mod.vb.GnshalCleared = false
mod.vb.VezokkCleared = false
local warnedGUIDs = {}
local lastSanity = 500

function mod:DefiledGroundTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellDefiledGround:Yell()
	end
end

function mod:SeismicSlamTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellSeismicSlam:Yell()
	end
end

function mod:VoidTorrentTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnVoidTorrent:Show()
		specWarnVoidTorrent:Play("justrun")
		yellVoidTorrent:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.GnshalCleared = false
	self.vb.VezokkCleared = false
	table.wipe(warnedGUIDs)
	lastSanity = 1000
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM:GetSpellName(307831))
		DBM.InfoFrame:Show(5, "playerpower", 1, ALTERNATE_POWER_INDEX, nil, nil, 2)--Sorting lowest to highest
	end
end

function mod:OnCombatEnd()
	table.wipe(warnedGUIDs)
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 297822 then
		if self:AntiSpam(2, 2) then
			specWarnSurgingDarkness:Show()
			specWarnSurgingDarkness:Play("watchstep")
		end
		timerSurgingDarknessCD:Start()
	elseif spellId == 297746 then
		if self:AntiSpam(3, 3) then
			specWarnSeismicSlam:Show()
			specWarnSeismicSlam:Play("frontal")
		end
		if GetNumGroupMembers() > 1 then
			self:BossTargetScanner(args.sourceGUID, "SeismicSlamTarget", 0.1, 7)
		end
	elseif spellId == 304976 then
		warnCriesoftheVoid:Show()
		--timerCriesoftheVoidCD:Start()
	elseif spellId == 297574 then
		specWarnHopelessness:Show(DBM_COMMON_L.ORB)
		specWarnHopelessness:Play("movetoyelloworb")
	elseif spellId == 304251 and self:AntiSpam(3.5, 1) then--1-4 boars, 3.5 second throttle
		warnVoidQuills:Show()
	elseif spellId == 306726 or spellId == 306828 then--306726 is Vez'okk the Lightless, 306828 is Thrall
		if self:AntiSpam(3, 3) then
			specWarnDefiledGround:Show()
			specWarnDefiledGround:Play("frontal")
		end
		timerDefiledGroundCD:Start()
		if GetNumGroupMembers() > 1 then
			self:BossTargetScanner(args.sourceGUID, "DefiledGroundTarget", 0.1, 7)
		end
	elseif spellId == 299110 then
		timerOrbofAnnihilationCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(2, 2) then
			specWarnOrbofAnnihilation:Show()
			specWarnOrbofAnnihilation:Play("watchstep")
		end
	elseif spellId == 307863 then
		if GetNumGroupMembers() > 1 then
			self:BossTargetScanner(args.sourceGUID, "VoidTorrentTarget", 0.1, 7)
		else
			specWarnVoidTorrent:Show()
			specWarnVoidTorrent:Play("justrun")
		end
	elseif spellId == 300351 then
		specWarnSurgingFist:Show()
		specWarnSurgingFist:Play("chargemove")
		timerSurgingFistCD:Start(nil, args.sourceGUID)
	elseif spellId == 300388 then
		specWarnDecimator:Show()
		specWarnDecimator:Play("watchorb")
		timerDecimatorCD:Start(nil, args.sourceGUID)
	elseif spellId == 304101 then
		specWarnMaddeningRoar:Show()
		specWarnMaddeningRoar:Play("justrun")
		timerMaddeningRoarCD:Start(nil, args.sourceGUID)
	elseif spellId == 304282 and self:AntiSpam(2, 2) then
		specWarnStampedingCorruption:Show()
		specWarnStampedingCorruption:Play("watchstep")
	elseif spellId == 306001 then
		warnExplosiveLeap:Show()
		timerExplosiveLeapCD:Start(nil, args.sourceGUID)
	elseif spellId == 306199 then
		specWarnHowlinginPain:Show()
		specWarnHowlinginPain:Play("stopcast")
	elseif spellId == 303589 and self:AntiSpam(2, 2) then
		specWarnSanguineResidue:Show()
		specWarnSanguineResidue:Play("watchstep")
	elseif spellId == 305875 and self:AntiSpam(2, 2) then
		specWarnVisceralFluid:Show()
		specWarnVisceralFluid:Play("watchstep")
	elseif spellId == 306617 then
		specWarnRingofChaos:Show()
		specWarnRingofChaos:Play("watchorb")
	elseif spellId == 296537 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnMentalAssault:Show(args.sourceName)
		specWarnMentalAssault:Play("kickcast")
	elseif spellId == 305378 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHorrifyingShout:Show(args.sourceName)
			specWarnHorrifyingShout:Play("kickcast")
		else
			warnHorrifyingShout:Show()
		end
		timerHorrifyingShout:Start(nil, args.sourceGUID)
	elseif spellId == 305236 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnVenomBolt:Show(args.sourceName)
		specWarnVenomBolt:Play("kickcast")
	elseif spellId == 298033 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTouchoftheAbyss:Show(args.sourceName)
			specWarnTouchoftheAbyss:Play("kickcast")
		else
			warnTouchoftheAbyss:Show()
		end
		timerTouchoftheAbyss:Start(nil, args.sourceGUID)
	elseif spellId == 298630 then
		timerShockwaveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 3) then
			specWarnShockwave:Show()
			specWarnShockwave:Play("frontal")
		end
	elseif spellId == 304169 then
		if self:AntiSpam(2, 2) then
			specWarnToxicVolley:Show()
			specWarnToxicVolley:Play("watchstep")
		end
		timerToxicVolleyCD:Start(nil, args.sourceGUID)
	elseif spellId == 298502 then
		if self:AntiSpam(3, 3) then
			warnToxicBreath:Show()
		end
		local cid = self:GetCIDFromGUID(args.sourceGUID)
		if cid == 153532 then
			timerToxicBreathCD:Start(nil, args.sourceGUID)
		end
	elseif spellId == 297315 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnVoidBuffet:Show(args.sourceName)
		specWarnVoidBuffet:Play("kickcast")
	elseif spellId == 307870 then
		warnSanityOrb:Show()
	elseif spellId == 299055 then
		specWarnDarkForce:Show()
		specWarnDarkForce:Play("frontal")
		timerDarkForceCD:Start(nil, args.sourceGUID)
	elseif spellId == 304165 then
		timerDesperateRetchingCD:Start(nil, args.sourceGUID)
	elseif spellId == 305369 then
		timerBreakSpiritCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnBreakSpirit:Show()
		end
	elseif spellId == 296718 then
		timerDarkSmashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDarkSmash:Show()
			specWarnDarkSmash:Play("watchstep")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 297237 then
		specWarnEndlessHungerTotem:Show()
		specWarnEndlessHungerTotem:Play("attacktotem")
	elseif spellId == 298033 then
		timerTouchoftheAbyssCD:Start(nil, args.sourceGUID)
	elseif spellId == 297746 then
		timerSeismicSlamCD:Start(10.1)--12.1-2 seconds after cast ends
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 311390 and args:IsPlayer() then
		local amount = args.amount or 1
		if amount >= 4 then
			specWarnEntomophobia:Show()
			specWarnEntomophobia:Play("keepjump")
		end
	elseif spellId == 315385 and args:IsPlayer() then
		if self.Options.SpecWarn315385you then
			specWarnScorchedFeet:Show()
			specWarnScorchedFeet:Play("targetyou")
		else
			warnScorchedFeet:Show()
		end
		if GetNumGroupMembers() > 1 then--Warn allies if in scenario with others
			yellScorchedFeet:Yell()
		end
--	elseif spellId == 316481 and args:IsPlayer() then
--		specWarnSplitPersonality:Show()
--		specWarnSplitPersonality:Play("stopmove")
	elseif spellId == 311641 and args:IsPlayer() then
		specWarnWaveringWill:Show(playerName)
		specWarnWaveringWill:Play("stopattack")
	elseif spellId == 304165 then
		if args:IsPlayer() then
			specWarnDesperateRetching:Show()
			specWarnDesperateRetching:Play("keepmove")
			if GetNumGroupMembers() > 1 then
				yellDesperateRetching:Yell()
			end
		elseif self:CheckDispelFilter("disease") then
			specWarnDesperateRetchingD:Show(args.destName)
			specWarnDesperateRetchingD:Play("helpdispel")
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if (spellId == 303594 or spellId == 313303) and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and args.extraSpellId == 298033 then
		timerTouchoftheAbyss:Stop(args.destGUID)
		timerTouchoftheAbyssCD:Start(18.6, args.destGUID)
	elseif type(args.extraSpellId) == "number" and args.extraSpellId == 305378 then
		timerHorrifyingShout:Stop(args.destGUID)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 152089 or cid == 234034 then--Thrall
		timerSurgingDarknessCD:Stop()
		timerSeismicSlamCD:Stop()
		--timerCriesoftheVoidCD:Stop()
		timerDefiledGroundCD:Stop()
		DBM:EndCombat(self)
	elseif cid == 156161 or cid == 234035 then--Inquisitor Gnshal
		--timerCriesoftheVoidCD:Stop()
		self.vb.GnshalCleared = true
	elseif cid == 152874 or cid == 234037 then--Vez'okk the Lightless
		timerDefiledGroundCD:Stop()
		self.vb.VezokkCleared = true
	elseif cid == 153943 then--Decimator Shiq'voth
		timerSurgingFistCD:Stop(args.destGUID)
		timerDecimatorCD:Stop(args.destGUID)
	elseif cid == 153401 or cid == 244186 or cid == 157610 then--K'thir Dominator
		timerTouchoftheAbyss:Stop(args.destGUID)
		timerTouchoftheAbyssCD:Stop(args.destGUID)
	elseif cid == 153532 then--Aqir Mindhunter
		timerToxicVolleyCD:Stop(args.destGUID)
		timerToxicBreathCD:Stop(args.destGUID)
	elseif cid == 153942 then--Annihilator Lak'hal
		timerDarkForceCD:Stop(args.destGUID)
		timerOrbofAnnihilationCD:Stop(args.destGUID)
	elseif cid == 156143 then--Voidcrazed Hulk
		timerExplosiveLeapCD:Stop(args.destGUID)
	elseif cid == 155656 then--Misha
		timerDesperateRetchingCD:Stop(args.destGUID)
		timerMaddeningRoarCD:Stop(args.destGUID)
	elseif cid == 240672 then--Gamon
		timerWarStompCD:Stop(args.destGUID)
	elseif cid == 156406 then--Voidbound Honor Guard
		timerBreakSpiritCD:Stop(args.destGUID)
	elseif cid == 156146 then--Voidbound Shieldbearer
		timerShockwaveCD:Stop(args.destGUID)
	elseif cid == 152987 then
		timerDarkSmashCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 152874 or cid == 234037 then--Vez'okk the Lightless
		timerDefiledGroundCD:Start(3.3-delay, guid)
	elseif cid == 153943 then--Decimator Shiq'voth
		timerSurgingFistCD:Start(3.5-delay, guid)
		timerDecimatorCD:Start(5.9-delay, guid)
	elseif cid == 153401 or cid == 244186 or cid == 157610 then--K'thir Dominator
		timerTouchoftheAbyssCD:Start(3.5-delay, guid)
	elseif cid == 153532 then--Aqir Mindhunter
		timerToxicBreathCD:Start(1.7-delay, guid)
		timerToxicVolleyCD:Start(5.4-delay, guid)
	elseif cid == 153942 then--Annihilator Lak'hal
		--Orb used instantly on pull
		timerDarkForceCD:Start(4-delay, guid)
	elseif cid == 156143 then--Voidcrazed Hulk
		timerExplosiveLeapCD:Start(5.5-delay, guid)
	elseif cid == 155656 then--Misha
		timerDesperateRetchingCD:Start(3.4-delay, guid)
		timerMaddeningRoarCD:Start(7.8-delay, guid)
	elseif cid == 240672 then--Gamon
		warnCallGamon:Show()
		timerWarStompCD:Start(5.3-delay, guid)
	elseif (cid == 164189 or cid == 164188) and self:AntiSpam(5, 8) then--Horrific Fragment
		timerDarkImaginationCD:Start()
	elseif cid == 156406 then--Voidbound Honor Guard
		timerBreakSpiritCD:Start(4.4-delay, guid)
	elseif cid == 156146 then--Voidbound Shieldbearer
		timerShockwaveCD:Start(4.7-delay, guid)
--	elseif cid == 152987 then
--		timerDarkSmashCD:Start(10.8-delay, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end


function mod:ENCOUNTER_START(encounterID)
	if not self:IsInCombat() then return end
	if encounterID == 2332 or encounterID == 3086 then--Thrall
		timerSurgingDarknessCD:Start(11.1)
		if self.vb.VezokkCleared then
			timerDefiledGroundCD:Start(1)
		else
			timerSeismicSlamCD:Start(4.6)
		end
	elseif encounterID == 2373 or encounterID == 3089 then--Vezokk
		timerDefiledGroundCD:Start(3.4)
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED_UNFILTERED(uId, _, spellId)
	if spellId == 314723 and self:AntiSpam(3, 7) then--War Stomp (not in combat log)
		warnWarStomp:Show()
		local guid = UnitGUID(uId)
		timerWarStompCD:Start(nil, guid)
	elseif spellId == 298074 and self:AntiSpam(3, 3) then--Rupture (not in combatlog)
		specWarnRupture:Show()
		specWarnRupture:Play("watchstep")
	--elseif spellId == 18950 and self:AntiSpam(2, 6) then
	--	local cid = self:GetUnitCreatureId(uId)
	--	if cid == 164189 or cid == 164188 then
	--		self:SendSync("DarkImagination")
	--	end
	end
end

function mod:UNIT_SPELLCAST_INTERRUPTED_UNFILTERED(uId, _, spellId)
	if spellId == 298033 then
		local guid = UnitGUID(uId)
		timerTouchoftheAbyss:Stop(guid)
	elseif spellId == 305378 then
		local guid = UnitGUID(uId)
		timerHorrifyingShout:Stop(guid)
	end
end

do
	--In blizzards infinite wisdom, Gift of the Titans isn't in combat log
	local titanWarned = false
	function mod:UNIT_AURA(uId)
		local hasTitan = DBM:UnitBuff("player", 313698)
		if hasTitan and not titanWarned then
			warnGiftoftheTitans:Show()
			timerGiftoftheTitan:Start()
			titanWarned = true
		elseif not hasTitan and titanWarned then
			titanWarned = false
		end
	end
end

function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		--Garona
		if self.Options.AutoGossipAction and gossipOptionID == 49742 then
			self:SelectGossip(gossipOptionID)
		end
	end
end

function mod:UNIT_POWER_UPDATE(uId)
	local currentSanity = UnitPower(uId, ALTERNATE_POWER_INDEX)
	if currentSanity > lastSanity then
		lastSanity = currentSanity
		return
	end
	if self:AntiSpam(5, 8) then--Additional throttle in case you lose sanity VERY rapidly with increased ICD for special warning
		if currentSanity < 40 and lastSanity > 40 then
			lastSanity = currentSanity
			specwarnSanity:Show(lastSanity)
			specwarnSanity:Play("lowsanity")
		elseif currentSanity < 80 and lastSanity > 80 then
			lastSanity = currentSanity
			specwarnSanity:Show(lastSanity)
			specwarnSanity:Play("lowsanity")
		end
	elseif self:AntiSpam(3, 9) then--Additional throttle in case you lose sanity VERY rapidly
		if currentSanity < 120 and lastSanity > 120 then
			lastSanity = currentSanity
			warnSanity:Show(lastSanity)
		elseif currentSanity < 160 and lastSanity > 160 then
			lastSanity = currentSanity
			warnSanity:Show(lastSanity)
		end
	end
end

--[[
function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "DarkImagination" then
		timerDarkImaginationCD:Start()
	end
end
--]]
