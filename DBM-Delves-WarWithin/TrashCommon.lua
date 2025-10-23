local mod	= DBM:NewMod("DelveTrashCommon", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)--Stays active in all zones for zone change handlers, but registers events based on dungeon ids
local validZones = {[2664] = true, [2679] = true, [2680] = true, [2681] = true, [2683] = true, [2684] = true, [2685] = true, [2686] = true, [2687] = true, [2688] = true, [2689] = true, [2690] = true, [2767] = true, [2768] = true, [2815] = true, [2826] = true, [2803] = true, [2951] = true}
for v, _ in pairs(validZones) do
	mod:RegisterZoneCombat(v)
end

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"PLAYER_MAP_CHANGED"
)

--TODO, add firecharge timer
--NOTE: Jagged Slash (450176) has precisely 9.7 CD, but is it worth tracking?
--NOTE: Stab (443510) is a 14.6 CD, but is it worth tracking?
--TODO: add "Gatling Wand-461757-npc:228044-00004977F7 = pull:1392.7, 17.0, 17.0", (used by Reno Jackson)
--TODO: timer for Armored Core from WCL
--TODO, is https://www.wowhead.com/spell=453149/gossamer-webbing worth adding, Brann seems to think so
--TODO, detect and alert https://www.wowhead.com/npc=217208/zekvir spawning in your delve with a large warning
--TODO, add https://www.wowhead.com/spell=455380/sprocket-punch ? it doesn't seem consiquential and that mob already has 3 abilities added
--TODO, add/confirm timers for random spawn version of zekvir for nameplate timers
--TODO, add https://www.wowhead.com/spell=1231893/crushing-stomp ?
local warnDebilitatingVenom					= mod:NewTargetNoFilterAnnounce(424614, 3)--Brann will dispel this if healer role
local warnCastigate							= mod:NewTargetNoFilterAnnounce(418297, 4)
local warnSpearFish							= mod:NewTargetNoFilterAnnounce(430036, 2)
local warnBloodthirsty						= mod:NewTargetNoFilterAnnounce(445406, 2)
local warnRelocate							= mod:NewSpellAnnounce(427812, 2)
local warnLeechingSwarm						= mod:NewSpellAnnounce(450637, 2)
local warnShadowsofStrife					= mod:NewCastAnnounce(449318, 3)--High Prio Interrupt
local warnWebbedAegis						= mod:NewCastAnnounce(450546, 3)
local warnBloatedEruption					= mod:NewCastAnnounce(424798, 4)
local warnBattleRoar						= mod:NewCastAnnounce(414944, 3)
local warnVineSpear							= mod:NewCastAnnounce(424891, 3, nil, nil, nil, nil, nil, 15)--Move to NewSpecialWarningDodge?
local warnSkitterCharge						= mod:NewCastAnnounce(450197, 3, nil, nil, nil, nil, nil, 2)
local warnShadowBarrier						= mod:NewCastAnnounce(434740, 3, nil, nil, nil, nil, nil, 2)
local warnWicklighterVolley					= mod:NewCastAnnounce(445191, 3)
local warnSkullCracker						= mod:NewCastAnnounce(462686, 3)
local warnThrashingFrenzy					= mod:NewCastAnnounce(445774, 3)
local warnEnfeeblingSpittle					= mod:NewCastAnnounce(450505, 2)
local warnWideSwipe							= mod:NewCastAnnounce(450509, 3)
local warnMagmaHammer						= mod:NewCastAnnounce(445718, 3)
local warnShadowSmash						= mod:NewCastAnnounce(474511, 3)
local warnLureoftheVoid						= mod:NewCastAnnounce(474482, 3, nil, nil, nil, nil, nil, 12)
local warnConcussiveSmash					= mod:NewCastAnnounce(474223, 3)
local warnCrankshaftAssault					= mod:NewCastAnnounce(455613, 4)--Annoying but not deadly. Overcharged Delve ability
local warnKyvezzaSpawn						= mod:NewCastAnnounce(1245156, 4)
local warnEnrage							= mod:NewSpellAnnounce(448161, 3)
local warnThrowDyno							= mod:NewSpellAnnounce(448600, 3)
local warnIllusionStep						= mod:NewSpellAnnounce(444915, 3)

local specWarnSpearFish						= mod:NewSpecialWarningYou(430036, nil, nil, nil, 2, 12)
local specWarnFungalBloom					= mod:NewSpecialWarningSpell(415250, nil, nil, nil, 2, 2)
local specWarnDarkMassacre					= mod:NewSpecialWarningSpell(1245203, nil, nil, nil, 2, 2)
local specWarnBurnAway						= mod:NewSpecialWarningSpell(450142, nil, nil, nil, 2, 2)
local specWarnNexusDaggers					= mod:NewSpecialWarningDodge(1245240, nil, nil, nil, 2, 2)
local specWarnFearfulShriek					= mod:NewSpecialWarningDodge(433410, nil, nil, nil, 2, 2)
local specWarnHidousLaughter				= mod:NewSpecialWarningDodge(372529, nil, nil, nil, 2, 2)
local specWarnJaggedBarbs					= mod:NewSpecialWarningDodge(450714, nil, nil, nil, 2, 15)--8.5-26
local specWarnLavablast	    				= mod:NewSpecialWarningDodge(445781, nil, nil, nil, 2, 15)
local specWarnFungalBreath    				= mod:NewSpecialWarningDodge(415253, nil, nil, nil, 2, 15)
local specWarnViciousStabs    				= mod:NewSpecialWarningDodge(424704, nil, nil, nil, 2, 15)
local specWarnBlazingWick    				= mod:NewSpecialWarningDodge(449071, nil, nil, nil, 2, 15)
local specWarnBladeToss						= mod:NewSpecialWarningDodge(418791, nil, nil, nil, 2, 2)
local specWarnDefilingBreath				= mod:NewSpecialWarningDodge(455932, nil, nil, nil, 2, 15)
local specWarnSerratedCleave				= mod:NewSpecialWarningDodge(445492, nil, nil, nil, 2, 15)--32.7
local specWarnSpotted						= mod:NewSpecialWarningDodge(441129, nil, nil, nil, 2, 2)
local specWarnFireCharge					= mod:NewSpecialWarningDodge(445210, nil, nil, nil, 2, 2)
local specWarnUmbralSlam					= mod:NewSpecialWarningDodge(443292, nil, nil, nil, 2, 15)--30.0?
local specWarnUmbralSlash					= mod:NewSpecialWarningDodge(418295, nil, nil, nil, 2, 15)
local specWarnAnglersWeb					= mod:NewSpecialWarningDodge(450519, nil, nil, nil, 2, 15)
local specWarnShockwaveTremors				= mod:NewSpecialWarningDodge(448155, nil, nil, nil, 2, 15)--9.7-15.8
local specWarnGrimweaveOrb					= mod:NewSpecialWarningDodge(451913, nil, nil, nil, 2, 2)
local specWarnBubbleSurge					= mod:NewSpecialWarningDodge(445771, nil, nil, nil, 2, 2)
local specWarnDrillQuake					= mod:NewSpecialWarningDodge(474004, nil, nil, nil, 2, 2)
local specWarnFlurryOfPunches				= mod:NewSpecialWarningDodge(473541, nil, nil, nil, 2, 2)
local specWarnAbyssalGrasp					= mod:NewSpecialWarningDodge(474325, nil, nil, nil, 2, 2)
local specWarnShadowStomp					= mod:NewSpecialWarningDodge(474206, nil, nil, nil, 2, 2)
local specWarnWorthlessAdorations			= mod:NewSpecialWarningDodge(1217361, nil, nil, nil, 2, 2)
local specWarnTakeASelfie					= mod:NewSpecialWarningDodge(1217326, nil, nil, nil, 2, 2)
local specWarnTheresTheDoor					= mod:NewSpecialWarningDodge(1216806, nil, nil, nil, 2, 15)
local specWarnHeedlessCharge				= mod:NewSpecialWarningDodge(1217301, nil, nil, nil, 2, 2)
local specWarnRecklessCharge				= mod:NewSpecialWarningDodge(473972, nil, nil, nil, 2, 2)--Insufficent data for timers
local specWarnRocketBarrage					= mod:NewSpecialWarningDodge(473550, nil, nil, nil, 2, 2)
local specWarnGolemSmash					= mod:NewSpecialWarningDodge(1239731, nil, nil, nil, 2, 15)--Overcharged Delve ability
local specWarnOverchargedSlam				= mod:NewSpecialWarningDodge(1220665, nil, nil, nil, 2, 15)--Overcharged Delve ability
local specWarnSandCrash						= mod:NewSpecialWarningDodge(1243017, nil, nil, nil, 2, 2)--S3
local specWarnVorpalCleave					= mod:NewSpecialWarningDodge(1236256, nil, nil, nil, 2, 15)--S3
local specWarnNullBreath					= mod:NewSpecialWarningDodge(1231144, nil, nil, nil, 2, 15)--S3
local specWarnArcaneGeyser					= mod:NewSpecialWarningDodge(1236770, nil, nil, nil, 2, 2)--S3
local specWarnEssenceCleave					= mod:NewSpecialWarningDodge(1238737, nil, nil, nil, 2, 15)
local specWarnGravityShatter				= mod:NewSpecialWarningDodge(1238713, nil, nil, nil, 2, 2)
local specWarnChargeThrough					= mod:NewSpecialWarningDodge(1244249, nil, nil, nil, 2, 2)
local specWarnForwardCharge					= mod:NewSpecialWarningDodge(1216790, nil, nil, nil, 2, 2)
local specWarnBloodbath						= mod:NewSpecialWarningRun(473995, nil, nil, nil, 4, 2)
local specWarnEchoofRenilash				= mod:NewSpecialWarningRun(434281, nil, nil, nil, 4, 2)
local specWarnNecroticEnd					= mod:NewSpecialWarningRun(445252, nil, nil, nil, 4, 2)
local specWarnHorrendousRoar				= mod:NewSpecialWarningRun(450492, nil, nil, nil, 4, 2)
local specWarnCurseoftheDepths				= mod:NewSpecialWarningDispel(440622, "RemoveCurse", nil, nil, 1, 2)
local specWarnEnrageDispel					= mod:NewSpecialWarningDispel(448161, "RemoveEnrage", nil, nil, 1, 2)
local specWarnOverchargedDispel				= mod:NewSpecialWarningDispel(1220472, "RemoveEnrage", nil, nil, 1, 2)--Overcharged Delve ability
local specWarnBlessingofDuskDispel			= mod:NewSpecialWarningDispel(470592, "MagicDispeller", nil, nil, 1, 2)--Used by most speakers, boss and trash alike
local specWarnShadowsofStrife				= mod:NewSpecialWarningInterrupt(449318, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnWebbedAegis					= mod:NewSpecialWarningInterrupt(450546, "HasInterrupt", nil, nil, 1, 2)
local specWarnRotWaveVolley					= mod:NewSpecialWarningInterrupt(425040, "HasInterrupt", nil, nil, 1, 2)
local specWarnCastigate						= mod:NewSpecialWarningInterrupt(418297, "HasInterrupt", nil, nil, 1, 2)
local specWarnBattleCry						= mod:NewSpecialWarningInterrupt(448399, "HasInterrupt", nil, nil, 1, 2)
local specWarnHolyLight						= mod:NewSpecialWarningInterrupt(459421, "HasInterrupt", nil, nil, 1, 2)
local specWarnArmoredShell					= mod:NewSpecialWarningInterrupt(448179, "HasInterrupt", nil, nil, 1, 2)
local specWarnBlessingofDusk				= mod:NewSpecialWarningInterrupt(470592, "HasInterrupt", nil, nil, 1, 2)--Speaker Davenruth
local specWarnZap							= mod:NewSpecialWarningInterrupt(1216805, "HasInterrupt", nil, nil, 1, 2)
local specWarnSandsOfKaresh					= mod:NewSpecialWarningInterrupt(1242469, "HasInterrupt", nil, nil, 1, 2)--S3
local specWarnEnfeeblingSpittleInterrupt	= mod:NewSpecialWarningInterrupt(450505, nil, nil, nil, 1, 2)
local specWarnHardenShell					= mod:NewSpecialWarningInterrupt(1214238, nil, nil, nil, 1, 2)
local specWarnOverchargeKick				= mod:NewSpecialWarningInterrupt(1220472, nil, nil, nil, 1, 2)--Overcharged Delve ability
local specWarnTerrifyingScreech				= mod:NewSpecialWarningInterrupt(1244108, nil, nil, nil, 1, 2)
local specWarnAlphaCannon					= mod:NewSpecialWarningInterrupt(1216794, nil, nil, nil, 1, 2)--S2 (no timer, insufficient data and inconsiquential)

local timerFearfulShriekCD					= mod:NewCDPNPTimer(13.4, 433410, nil, nil, nil, 3)
local timerHidousLaughterCD					= mod:NewCDPNPTimer(25.4, 372529, nil, nil, nil, 3)--25.4-29.8
local timerShadowsofStrifeCD				= mod:NewCDNPTimer(15.6, 449318, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRotWaveVolleyCD					= mod:NewCDNPTimer(15.2, 425040, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--15.2-17
local timerWebbedAegisCD					= mod:NewCDNPTimer(15.8, 450546, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--14.6 BUT enemies can skip casts sometimes and make it 29.1
local timerMagmaHammerCD					= mod:NewCDNPTimer(8.5, 445718, nil, nil, nil, 5)
local timerLavablastCD					    = mod:NewCDNPTimer(12.2, 445781, nil, nil, nil, 3)
local timerLavablast						= mod:NewCastNPTimer(3, 445781, DBM_COMMON_L.FRONTAL, nil, nil, 5)
local timerBlazingWickCD					= mod:NewCDPNPTimer(14.2, 449071, nil, nil, nil, 3)
local timerBlazingWick						= mod:NewCastNPTimer(2.25, 449071, DBM_COMMON_L.FRONTAL, nil, nil, 5)
local timerBattleRoarCD						= mod:NewCDPNPTimer(15.4, 414944, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerDebilitatingVenomCD				= mod:NewCDNPTimer(13.4, 424614, nil, nil, nil, 5, nil, DBM_COMMON_L.POISON_ICON)
local timerBladeTossCD						= mod:NewCDNPTimer(15.4, 418791, nil, nil, nil, 3)
local timerVineSpearCD						= mod:NewCDNPTimer(14.9, 424891, nil, nil, nil, 3)
local timerRelocateCD						= mod:NewCDNPTimer(70, 427812, nil, nil, nil, 3)
local timerSkitterChargeCD					= mod:NewCDNPTimer(12.2, 450197, nil, nil, nil, 3)
local timerFungalBreathCD					= mod:NewCDNPTimer(15.4, 415253, nil, nil, nil, 3)--28 now?
local timerUmbralSlamCD						= mod:NewCDNPTimer(24.8, 443292, nil, nil, nil, 3)
local timerUmbrelSlashCD					= mod:NewCDNPTimer(17.4, 418295, nil, nil, nil, 3)
local timerCastigateCD						= mod:NewCDPNPTimer(17.4, 418297, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBattleCryCD						= mod:NewCDNPTimer(30.3, 448399, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerWicklighterVolleyCD				= mod:NewCDNPTimer(20.1, 445191, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Needs more Data
local timerSpearFishCD						= mod:NewCDNPTimer(12.1, 430036, nil, nil, nil, 3)
local timerViciousStabsCD					= mod:NewCDNPTimer(20.6, 424704, nil, nil, nil, 3)
local timerThrowDynoCD						= mod:NewCDNPTimer(7.2, 448600, nil, nil, nil, 3)
local timerSerratedCleaveCD					= mod:NewCDNPTimer(32.7, 445492, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Not technically tanks only, just whoever has aggro in it
local timerSkullCrackerCD					= mod:NewCDNPTimer(15.8, 462686, nil, nil, nil, 3)
local timerHolyLightCD						= mod:NewCDPNPTimer(17, 459421, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--17-18.2
local timerJaggedBarbs						= mod:NewCastNPTimer(3, 450714, DBM_COMMON_L.FRONTAL, nil, nil, 3)
local timerEnrageCD							= mod:NewCDNPTimer(23, 448161, nil, nil, nil, 5)
local timerArmorShellCD						= mod:NewCDNPTimer(24, 448179, nil, nil, nil, 4)
local timerWideSwipeCD						= mod:NewCDNPTimer(8, 450509, nil, nil, nil, 3)
local timerFungalBloomCD					= mod:NewCDNPTimer(25.1, 415250, nil, nil, nil, 2)
local timerShadowStrikeCD					= mod:NewCDNPTimer(15.8, 443162, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerGrimweaveOrbCD					= mod:NewCDNPTimer(20.6, 451913, nil, nil, nil, 3)--23.1 but 2.5 second cast
local timerIllusionStepCD					= mod:NewCDNPTimer(31, 444915, nil, nil, nil, 3)
local timerBubbleSurgeCD					= mod:NewCDNPTimer(18.1, 445771, nil, nil, nil, 3)
local timerBloodthirstyCD					= mod:NewCDNPTimer(15.7, 445406, nil, nil, nil, 3)--15.7-23
local timerDrillQuakeCD						= mod:NewCDNPTimer(15.7, 474004, nil, nil, nil, 3)--15.7-18.3
local timerFlurryOfPunchesCD				= mod:NewCDNPTimer(10.9, 473541, nil, nil, nil, 3)--10.9-13.4
local timerShadowSmashCD					= mod:NewCDNPTimer(14.5, 474511, nil, nil, nil, 2)--14.5-23.1
local timerLureoftheVoidCD					= mod:NewCDNPTimer(22.1, 474482, nil, nil, nil, 2)--22.1-28.3
--local timerAbysmalGraspCD					= mod:NewCDNPTimer(100, 474325, nil, nil, nil, 3)--Never recast, might just be health based
local timerConcussiveSmashCD				= mod:NewCDNPTimer(14.5, 474223, nil, nil, nil, 5)--14.5-21.5
local timerShadowStompCD					= mod:NewCDNPTimer(29.9, 474206, nil, nil, nil, 3)--Recast if CCed
local timerWorthlessAdorationsCD			= mod:NewCDNPTimer(15, 1217361, nil, nil, nil, 3)--15-30, recasts if CCed
local timerTakeASelfieCD					= mod:NewCDNPTimer(13.3, 1217326, nil, nil, nil, 3)--13.3-18.9
local timerTheresTheDoorCD					= mod:NewCDNPTimer(14.6, 1216806, nil, nil, nil, 3)--14.6-18.1
local timerZapCD							= mod:NewCDNPTimer(19.4, 1216805, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--19.4-25
local timerHeedlessChargeCD					= mod:NewCDNPTimer(15.8, 1217301, nil, nil, nil, 3)--15.8-26.7
--local timerRecklessChargeCD				= mod:NewCDNPTimer(15.8, 473972, nil, nil, nil, 3)--Need more data
local timerBloodBathCD						= mod:NewCDNPTimer(15.8, 473995, nil, nil, nil, 3)--40-43
local timerRocketBarrageCD					= mod:NewCDNPTimer(19.4, 473550, nil, nil, nil, 3)--19.4-21.8
local timerHardenShellCD					= mod:NewCDNPTimer(30.4, 1214238, nil, nil, nil, 3)
local timerCrushingPinchCD					= mod:NewCDNPTimer(8.1, 1214246, nil, nil, nil, 3)
local timerGolemSmashCD						= mod:NewCDNPTimer(13.3, 1239731, nil, nil, nil, 3)--13.3-15
local timerOverchargedSlamCD				= mod:NewCDNPTimer(21.8, 1220665, nil, nil, nil, 3)--21.8-23.1
local timerCrankshaftAssaultCD				= mod:NewCDNPTimer(21.8, 455613, nil, nil, nil, 3)--21.8-23.1
local timerOverchargeCD						= mod:NewCDNPTimer(21.8, 1220472, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--21.8-23.1
--local timerTerrifyingScreechCD			= mod:NewCDNPTimer(15.8, 1244108, nil, nil, nil, 3)--Unknown
local timerSandCrashCD						= mod:NewCDNPTimer(19.9, 1243017, nil, nil, nil, 3)
--local timerVorpalCleaveCD					= mod:NewCDNPTimer(15.8, 1236256, nil, nil, nil, 3)--Unknown
--local timerNullBreathCD					= mod:NewCDNPTimer(15.8, 1231144, nil, nil, nil, 3)--Unknown
--local timerSandsOfKareshCD				= mod:NewCDNPTimer(15.8, 1242469, nil, nil, nil, 4)--Unknown
--local timerArcaneGeyserCD					= mod:NewCDNPTimer(15.8, 1236770, nil, nil, nil, 3)--Unknown
local timerEssenceCleaveCD					= mod:NewCDNPTimer(11.4, 1238737, nil, nil, nil, 3)
--local timerGravityShatterCD				= mod:NewCDNPTimer(15.8, 1238713, nil, nil, nil, 3)--Unknown
local timerKyvezzaSpawnCast					= mod:NewCastTimer(6, 1245156, nil, nil, nil, 1)
local timerDarkMassacreCD					= mod:NewCDNPTimer(30.3, 1245203, nil, nil, nil, 5)
local timerNexusDaggersCD					= mod:NewCDNPTimer(30.3, 1245240, nil, nil, nil, 3)
local timerBurnAwayCD						= mod:NewCDPNPTimer(24.2, 450142, nil, nil, nil, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

do
	local eventsRegistered = false
	function mod:DelayedZoneCheck(force)
		local currentZone = DBM:GetCurrentArea() or 0
		if not force and validZones[currentZone] and not eventsRegistered then
			eventsRegistered = true
			self:RegisterShortTermEvents(
                "SPELL_CAST_START 449318 450546 433410 450714 445781 415253 425040 424704 424798 414944 418791 424891 450197 448399 445191 455932 445492 434281 450637 445210 448528 449071 462686 459421 448179 445774 443292 450492 450519 450505 450509 448155 448161 418295 415250 434740 470592 443482 458879 445718 451913 445771 372529 474004 473541 474511 474482 474325 474223 474206 1217361 1217326 1216806 1216805 1217301 473550 1214238 1239731 455613 1220472 1243017 1236256 1231144 1242469 1242469 1236770 1238737 1238713 1245203 1245156 1245240 1244249 450142 1216794 1216790",
                "SPELL_CAST_SUCCESS 414944 424614 418791 424891 427812 450546 450197 415253 449318 445191 430036 445252 425040 424704 448399 448528 433410 445492 462686 447392 459421 448179 450509 415250 443162 443292 451913 444915 445406 372529 473541 1216806 1216805 1217361 1217326 474206 474004 473995 473550 474482 418295 1214238 1214246 1243017 1238737 474223",--474325
				"SPELL_INTERRUPT",
                "SPELL_AURA_APPLIED 424614 449071 418297 430036 440622 441129 448161 470592 443482 458879 445407 1220472",
                --"SPELL_AURA_REMOVED",
                --"SPELL_PERIODIC_DAMAGE",
                "UNIT_DIED"
			)
			DBM:Debug("Registering Delve events")
		elseif force or (not validZones[currentZone] and eventsRegistered) then
			eventsRegistered = false
			self:UnregisterShortTermEvents()
			self:Stop()
			DBM:Debug("Unregistering Delve events")
		end
	end
	function mod:LOADING_SCREEN_DISABLED()
		self:UnscheduleMethod("DelayedZoneCheck")
		--Checks Delayed 1 second after core checks to prevent race condition of checking before core did and updated cached ID
		self:ScheduleMethod(6, "DelayedZoneCheck")
	end
	function mod:PLAYER_MAP_CHANGED(firstZone)
		if firstZone == -1 then return end--Will be handled by LOADING_SCREEN_DISABLED
		self:ScheduleMethod(6, "DelayedZoneCheck")
	end
	mod.OnInitialize = mod.LOADING_SCREEN_DISABLED
end

---@param self DBMMod
local function workAroundLuaLimitation(self, spellId, sourceName, sourceGUID, args)
	if spellId == 474223 and self:IsValidWarning(sourceGUID) then
		if self:AntiSpam(3, 5) then
			warnConcussiveSmash:Show()
		end
	elseif spellId == 474206 then
		if self:AntiSpam(3, 2) then
			specWarnShadowStomp:Show()
			specWarnShadowStomp:Play("watchstep")
		end
	elseif spellId == 1217361 then
		if self:AntiSpam(3, 2) then
			specWarnWorthlessAdorations:Show()
			specWarnWorthlessAdorations:Play("watchstep")
		end
	elseif spellId == 1217326 then
		if self:AntiSpam(3, 2) then
			specWarnTakeASelfie:Show()
			specWarnTakeASelfie:Play("watchstep")
		end
	elseif spellId == 1216806 then
		if self:AntiSpam(2, 2) then--Shorter limit due to quickness of cast and needing to alert for multiple
			specWarnTheresTheDoor:Show()
			specWarnTheresTheDoor:Play("watchstep")
		end
	elseif spellId == 1216805 then
		if self:AntiSpam(3, 2) then
			specWarnZap:Show(sourceName)
			specWarnZap:Play("kickcast")
		end
	elseif spellId == 1217301 then
		timerHeedlessChargeCD:Start(nil, sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnHeedlessCharge:Show()
			specWarnHeedlessCharge:Play("chargemove")
		end
	elseif spellId == 473972 then
		--timerRecklessChargeCD:Start(nil, sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRecklessCharge:Show()
			specWarnRecklessCharge:Play("chargemove")
		end
	elseif spellId == 473995 then
		if self:AntiSpam(3, 2) then
			specWarnBloodbath:Show()
			specWarnBloodbath:Play("justrun")
		end
	elseif spellId == 473550 then
		if self:AntiSpam(3, 2) then
			specWarnRocketBarrage:Show()
			specWarnRocketBarrage:Play("watchstep")
		end
	elseif spellId == 1214238 then
		if self:CheckInterruptFilter(sourceGUID, false, true) then
			specWarnHardenShell:Show(sourceName)
			specWarnHardenShell:Play("kickcast")
		end
	elseif spellId == 1239731 then
		timerGolemSmashCD:Start(nil, sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnGolemSmash:Show()
			specWarnGolemSmash:Play("frontal")
		end
	elseif spellId == 1220665 then
		timerOverchargedSlamCD:Start(nil, sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnOverchargedSlam:Show()
			specWarnOverchargedSlam:Play("watchstep")
		end
	elseif spellId == 455613 then
		timerCrankshaftAssaultCD:Start(nil, sourceGUID)
		if self:AntiSpam(3, 6) then
			warnCrankshaftAssault:Show()
		end
	elseif spellId == 1220472 then
		timerOverchargeCD:Start(nil, sourceGUID)--Seems to go on CD whether it's kicked or not
		if self:CheckInterruptFilter(sourceGUID, false, true) then
			specWarnOverchargeKick:Show(sourceName)
			specWarnOverchargeKick:Play("kickcast")
		end
	elseif spellId == 1244108 then
		if self:CheckInterruptFilter(sourceGUID, false, true) then
			specWarnTerrifyingScreech:Show(sourceName)
			specWarnTerrifyingScreech:Play("kickcast")
		end
	elseif spellId == 1243017 then
		if self:AntiSpam(3, 2) then
			specWarnSandCrash:Show()
			specWarnSandCrash:Play("watchstep")
		end
	elseif spellId == 1236256 then
		if self:AntiSpam(3, 2) then
			specWarnVorpalCleave:Show()
			specWarnVorpalCleave:Play("frontal")
		end
	elseif spellId == 1231144 then
		if self:AntiSpam(3, 2) then
			specWarnNullBreath:Show()
			specWarnNullBreath:Play("frontal")
		end
	elseif spellId == 1242469 then
		if self:CheckInterruptFilter(sourceGUID, false, true) then
			specWarnSandsOfKaresh:Show(sourceName)
			specWarnSandsOfKaresh:Play("kickcast")
		end
	elseif spellId == 1236770 then
		if self:AntiSpam(3, 2) then
			specWarnArcaneGeyser:Show()
			specWarnArcaneGeyser:Play("watchstep")
		end
	elseif spellId == 1238737 then
		if self:AntiSpam(3, 2) then
			specWarnEssenceCleave:Show()
			specWarnEssenceCleave:Play("frontal")
		end
	elseif spellId == 1238713 then
		if self:AntiSpam(3, 2) then
			specWarnGravityShatter:Show()
			specWarnGravityShatter:Play("watchstep")
		end
	elseif spellId == 1245203 then
		timerDarkMassacreCD:Start(nil, sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnDarkMassacre:Show()
			specWarnDarkMassacre:Play("ghostsoon")
		end
	elseif spellId == 1245156 then
		warnKyvezzaSpawn:Show()
		timerKyvezzaSpawnCast:Start()
	elseif spellId == 1245240 and args:GetSrcCreatureID() == 244755 then
		timerNexusDaggersCD:Start(nil, sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnNexusDaggers:Show()
			specWarnNexusDaggers:Play("farfromline")
		end
	elseif spellId == 1244249 then
		if self:AntiSpam(3, 2) then
			specWarnChargeThrough:Show()
			specWarnChargeThrough:Play("farfromline")
		end
	elseif spellId == 450142 then
		if self:AntiSpam(3, 4) then
			specWarnBurnAway:Show()
			specWarnBurnAway:Play("aesoon")
		end
		timerBurnAwayCD:Start(nil, args.sourceGUID)
	elseif spellId == 1216794 then
		if self:CheckInterruptFilter(sourceGUID, false, true) then
			specWarnAlphaCannon:Show(sourceName)
			specWarnAlphaCannon:Play("kickcast")
		end
	elseif spellId == 1216790 then
		if self:AntiSpam(3, 2) then
			specWarnForwardCharge:Show()
			specWarnForwardCharge:Play("chargemove")
		end
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if args.spellId == 449318 then
--		timerShadowsofStrifeCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn449318interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnShadowsofStrife:Show(args.sourceName)
			specWarnShadowsofStrife:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnShadowsofStrife:Show()
		end
	elseif args.spellId == 425040 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRotWaveVolley:Show(args.sourceName)
			specWarnRotWaveVolley:Play("kickcast")
		end
	elseif args.spellId == 450546 then
	--	timerWebbedAegisCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn450546interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWebbedAegis:Show(args.sourceName)
			specWarnWebbedAegis:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnWebbedAegis:Show()
		end
	elseif args.spellId == 433410 then
		if self:AntiSpam(3, 2) then
			specWarnFearfulShriek:Show()
			specWarnFearfulShriek:Play("watchstep")
		end
	elseif args.spellId == 372529 then
		if self:AntiSpam(3, 2) then
			specWarnHidousLaughter:Show()
			specWarnHidousLaughter:Play("watchstep")
		end
	elseif args.spellId == 443292 then
		if self:AntiSpam(3, 2) then
			specWarnUmbralSlam:Show()
			specWarnUmbralSlam:Play("frontal")
		end
	elseif args.spellId == 418295 then
		if self:AntiSpam(3, 2) then
			specWarnUmbralSlash:Show()
			specWarnUmbralSlash:Play("frontal")
		end
	elseif args.spellId == 450714 then
		timerJaggedBarbs:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnJaggedBarbs:Show()
			specWarnJaggedBarbs:Play("frontal")
		end
	elseif args.spellId == 445781 then
		timerLavablast:Start(nil, args.sourceGUID)
        timerLavablastCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnLavablast:Show()
			specWarnLavablast:Play("frontal")
		end
	elseif args.spellId == 415253 then
		if self:AntiSpam(3, 2) then
			specWarnFungalBreath:Show()
			specWarnFungalBreath:Play("frontal")
		end
	elseif args.spellId == 424704 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 2) then
			specWarnViciousStabs:Show()
			specWarnViciousStabs:Play("frontal")
		end
	elseif args.spellId == 424798 then
		if self:AntiSpam(3, 6) then
			warnBloatedEruption:Show()
		end
	elseif args.spellId == 414944 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 5) then
			warnBattleRoar:Show()
		end
	elseif args.spellId == 418791 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 2) then
			specWarnBladeToss:Show()
			specWarnBladeToss:Play("chargemove")
		end
	elseif args.spellId == 424891 then
		if self:AntiSpam(3, 6) then
			warnVineSpear:Show()
			warnVineSpear:Play("frontal")
		end
	elseif args.spellId == 450197 then
		if self:AntiSpam(3, 2) then
			warnSkitterCharge:Show()
			warnSkitterCharge:Play("chargemove")
		end
	elseif args.spellId == 445210 then
		if self:AntiSpam(3, 2) then
			specWarnFireCharge:Show()
			specWarnFireCharge:Play("chargemove")
		end
	elseif args.spellId == 448399 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBattleCry:Show(args.sourceName)
			specWarnBattleCry:Play("kickcast")
		end
	elseif args.spellId == 445191 then
		if self:AntiSpam(3, 7) then
			warnWicklighterVolley:Show()
		end
	elseif args.spellId == 455932 then
		if self:AntiSpam(3, 2) then
			specWarnDefilingBreath:Show()
			specWarnDefilingBreath:Play("frontal")
		end
	elseif args.spellId == 445492 then
		if self:AntiSpam(3, 2) then
			specWarnSerratedCleave:Show()
			specWarnSerratedCleave:Play("frontal")
		end
	elseif args.spellId == 434281 then
		if self:AntiSpam(3, 1) then
			specWarnEchoofRenilash:Show()
			specWarnEchoofRenilash:Play("justrun")
		end
	elseif args.spellId == 450637 then
		if self:AntiSpam(3, 6) then
			warnLeechingSwarm:Show()
		end
	elseif args.spellId == 448528 then
		if self:AntiSpam(3, 6) then
			warnThrowDyno:Show()
		end
	elseif args.spellId == 449071 then
		timerBlazingWick:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBlazingWick:Show()
			specWarnBlazingWick:Play("frontal")
		end
	elseif args.spellId == 462686 then
		if self:AntiSpam(3, 6) then
			warnSkullCracker:Show()
		end
	elseif args.spellId == 459421 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHolyLight:Show(args.sourceName)
			specWarnHolyLight:Play("kickcast")
		end
	elseif args.spellId == 448179 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnArmoredShell:Show(args.sourceName)
			specWarnArmoredShell:Play("kickcast")
		end
	elseif args.spellId == 445774 then
		if self:AntiSpam(3, 6) then
			warnThrashingFrenzy:Show()
		end
	elseif args.spellId == 450492 then
		if self:AntiSpam(3, 1) then
			specWarnHorrendousRoar:Show()
			specWarnHorrendousRoar:Play("fearsoon")
		end
	elseif args.spellId == 450519 then
		if self:AntiSpam(3, 2) then
			specWarnAnglersWeb:Show()
			specWarnAnglersWeb:Play("frontal")
		end
	elseif args.spellId == 450505 then
		if self.Options.SpecWarn450505interrupt and self:CheckInterruptFilter(args.sourceGUID, nil, true) then
			specWarnEnfeeblingSpittleInterrupt:Show(args.sourceName)
			specWarnEnfeeblingSpittleInterrupt:Play("kickcast")
		else
			warnEnfeeblingSpittle:Show()
		end
	elseif args.spellId == 450509 then
		if self:AntiSpam(3, 6) then
			warnWideSwipe:Show()
		end
	elseif args.spellId == 448155 then
		if self:AntiSpam(3, 2) then
			specWarnShockwaveTremors:Show()
			specWarnShockwaveTremors:Play("frontal")
		end
	elseif args.spellId == 448161 then
		timerEnrageCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 415250 then
		if self:AntiSpam(3, 4) then
			specWarnFungalBloom:Show()
			specWarnFungalBloom:Play("aesoon")
		end
	elseif args.spellId == 434740 then
		if self:AntiSpam(3, 2) then
			warnShadowBarrier:Show()
			warnShadowBarrier:Play("crowdcontrol")
		end
	elseif args.spellId == 470592 or args.spellId == 443482 or args.spellId == 458879 then--Varous versions of this spell
		specWarnBlessingofDusk:Show(args.sourceName)
		specWarnBlessingofDusk:Play("kickcast")
	elseif args.spellId == 445718 then
		timerMagmaHammerCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, nil, args.sourceGUID) and self:AntiSpam(3, 5) then
			warnMagmaHammer:Show()
		end
	elseif args.spellId == 451913 then
		if self:AntiSpam(3, 2) then
			specWarnGrimweaveOrb:Show()
			specWarnGrimweaveOrb:Play("watchstep")
		end
	elseif args.spellId == 445771 then
		timerBubbleSurgeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBubbleSurge:Show()
			specWarnBubbleSurge:Play("watchstep")
		end
	elseif args.spellId == 474004 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 2) then
			specWarnDrillQuake:Show()
			specWarnDrillQuake:Play("watchstep")
		end
	elseif args.spellId == 473541 then
		if self:AntiSpam(2, 2) then
			specWarnFlurryOfPunches:Show()
			specWarnFlurryOfPunches:Play("watchstep")
		end
	elseif args.spellId == 474511 then
		timerShadowSmashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnShadowSmash:Show()
		end
	elseif args.spellId == 474482 then
		if self:AntiSpam(3, 5) then
			warnLureoftheVoid:Show()
			warnLureoftheVoid:Play("pullin")
		end
	elseif args.spellId == 474325 then
		if self:AntiSpam(3, 2) then
			specWarnAbyssalGrasp:Show()
			specWarnAbyssalGrasp:Play("watchstep")
		end
	else
		workAroundLuaLimitation(self, args.spellId, args.sourceName, args.sourceGUID, args)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	if args.spellId == 414944 and self:IsValidWarning(args.sourceGUID) then
		if args:GetSrcCreatureID() == 207454 then--Fungal Gutter
			timerBattleRoarCD:Start(19.9, args.sourceGUID)--19.9-24.7 (may have a inimum of 22.5 now, or it may have a variable minimum based on group size)
		else--207456 Fungal Speartender
			timerBattleRoarCD:Start(9.9, args.sourceGUID)--9.9-12
		end
	elseif args.spellId == 424614 and self:IsValidWarning(args.sourceGUID) then
		timerDebilitatingVenomCD:Start(12.3, args.sourceGUID)--13.3 - 1
	elseif args.spellId == 418791 and self:IsValidWarning(args.sourceGUID) then
		timerBladeTossCD:Start(11.1, args.sourceGUID)--12.1 - 1
	elseif args.spellId == 424891 then
		timerVineSpearCD:Start(10.9, args.sourceGUID)--14.9 - 4
	elseif args.spellId == 427812 then
		timerRelocateCD:Start(70, args.sourceGUID)--Spores teleport every 70 seconds
		if self:AntiSpam(3, 6) then
			warnRelocate:Show()
		end
	elseif args.spellId == 450546 then
		timerWebbedAegisCD:Start(12.8, args.sourceGUID)--15.8 - 3
	elseif args.spellId == 450197 then
		timerSkitterChargeCD:Start(12.5, args.sourceGUID)-- 14.6 - 2.1
	elseif args.spellId == 415253 then
		timerFungalBreathCD:Start(15.2, args.sourceGUID)-- 18.2 - 3
	elseif args.spellId == 449318 then
		timerShadowsofStrifeCD:Start(12.6, args.sourceGUID)--15.6 - 3
	elseif args.spellId == 445191 then
		timerWicklighterVolleyCD:Start(18.3, args.sourceGUID)--21.8 - 3.5
	elseif args.spellId == 430036 then
		timerSpearFishCD:Start(12.1, args.sourceGUID)
	elseif args.spellId == 445252 then
		if self:AntiSpam(3, 1) then
			specWarnNecroticEnd:Show()
			specWarnNecroticEnd:Play("justrun")
		end
	elseif args.spellId == 425040 then
		timerRotWaveVolleyCD:Start(9.4, args.sourceGUID)--12.4 - 3
	elseif args.spellId == 424704 and self:IsValidWarning(args.sourceGUID) then
		timerViciousStabsCD:Start(14, args.sourceGUID)
	elseif args.spellId == 448399 then
		timerBattleCryCD:Start(28.3, args.sourceGUID)--30.3 - 2
	elseif args.spellId == 448528 then
		timerThrowDynoCD:Start(5.7, args.sourceGUID)-- 7.2 - 1.5
	elseif args.spellId == 433410 then
		timerFearfulShriekCD:Start(10.4, args.sourceGUID)--13.4 - 3
	elseif args.spellId == 372529 then
		timerHidousLaughterCD:Start(23.4, args.sourceGUID)--25.4-2
	elseif args.spellId == 445492 then
		timerSerratedCleaveCD:Start(29.1, args.sourceGUID)--32.1 - 3
	elseif args.spellId == 462686 then
		timerSkullCrackerCD:Start(13.3, args.sourceGUID)--15.8 - 2.5
	elseif args.spellId == 447392 then--Supply Bag (Cast when Reno Jackson Defeated)
		timerSkullCrackerCD:Stop(args.sourceGUID)
	elseif args.spellId == 459421 then
		timerHolyLightCD:Start(14.5, args.sourceGUID)--17-2.5
	elseif args.spellId == 448179 then
		timerArmorShellCD:Start(24, args.sourceGUID)
	elseif args.spellId == 450509 then
		timerWideSwipeCD:Start(7.7, args.sourceGUID)--7.7-8.5
	elseif args.spellId == 415250 then
		timerFungalBloomCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 443162 then
		timerShadowStrikeCD:Start(8.2, args.sourceGUID)--8.2-8.7
	elseif args.spellId == 443292 then
		timerUmbralSlamCD:Start(24.8, args.sourceGUID)
	elseif args.spellId == 451913 then
		timerGrimweaveOrbCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 444915 then
		timerIllusionStepCD:Start(31, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnIllusionStep:Show()
		end
	elseif args.spellId == 445406 then
		timerBloodthirstyCD:Start(nil, args.sourceGUID)--15.7-23
	elseif args.spellId == 473541 then
		timerFlurryOfPunchesCD:Start(8.4, args.sourceGUID)--10.9-2.5
	--elseif args.spellId == 474325 then
	--	timerAbysmalGraspCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 1216806 then
		timerTheresTheDoorCD:Start(10.6, args.sourceGUID)
	elseif args.spellId == 1216805 then
		timerZapCD:Start(18.5, args.sourceGUID)--20.5-2
	elseif args.spellId == 1217361 then
		timerWorthlessAdorationsCD:Start(12.1, args.sourceGUID)--13.6-1.5
	elseif args.spellId == 1217326 then
		timerTakeASelfieCD:Start(9.8, args.sourceGUID)--13.3-3.5
	elseif args.spellId == 474206 and self:IsValidWarning(args.sourceGUID) then
		timerShadowStompCD:Start(25.9, args.sourceGUID)--29.9-4
	elseif args.spellId == 474004 and self:IsValidWarning(args.sourceGUID) then
		timerDrillQuakeCD:Start(9, args.sourceGUID)--12.5-3.5
	elseif args.spellId == 473995 then
		timerBloodBathCD:Start(35, args.sourceGUID)--40-5
	elseif args.spellId == 473550 then
		timerRocketBarrageCD:Start(17.4, args.sourceGUID)--19.4-2
	elseif args.spellId == 474482 then
		timerLureoftheVoidCD:Start(20.1, args.sourceGUID)--22.1 - 2
	elseif args.spellId == 418295 then
		timerUmbrelSlashCD:Start(15.9, args.sourceGUID)--17.4-1.5
	elseif args.spellId == 1214238 then
		timerHardenShellCD:Start(30.4, args.sourceGUID)
	elseif args.spellId == 1214246 then
		timerCrushingPinchCD:Start(8.1, args.sourceGUID)
	elseif args.spellId == 1243017 then
		timerSandCrashCD:Start(19.9, args.sourceGUID)
	elseif args.spellId == 1238737 then
		timerEssenceCleaveCD:Start(11.4, args.sourceGUID)
	elseif args.spellId == 474223 and self:IsValidWarning(args.sourceGUID) then
		timerConcussiveSmashCD:Start(12, args.sourceGUID)
	end
end

--Likely some of these aren't even interruptable, but i can't remember sometimes so they get added anyways
function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 414944 and self:IsValidWarning(args.destGUID) then
		if args:GetSrcCreatureID() == 207454 then--Fungal Gutter
			timerBattleRoarCD:Start(19.9, args.destGUID)--19.9-24.7
		else--207456 Fungal Speartender
			timerBattleRoarCD:Start(9.9, args.destGUID)--9.9-12
		end
	elseif args.extraSpellId == 450546 then
		timerWebbedAegisCD:Start(12.8, args.destGUID)
	elseif args.extraSpellId == 449318 then
		timerShadowsofStrifeCD:Start(12.6, args.destGUID)--15.6 - 3
	elseif args.extraSpellId == 445191 then
		timerWicklighterVolleyCD:Start(18.3, args.destGUID)--21.8 - 3.5
	elseif args.extraSpellId == 425040 then
		timerRotWaveVolleyCD:Start(9.4, args.destGUID)--12.4 - 3
	elseif args.extraSpellId == 424704 and self:IsValidWarning(args.destGUID) then
		timerViciousStabsCD:Start(14, args.destGUID)--20.6 - 2
	elseif args.extraSpellId == 448399 then
		timerBattleCryCD:Start(28.3, args.destGUID)--30.3 - 2
	elseif args.extraSpellId == 448528 then
		timerThrowDynoCD:Start(5.7, args.destGUID)-- 7.2 - 1.5
	elseif args.extraSpellId == 433410 then
		timerFearfulShriekCD:Start(10.4, args.destGUID)--13.4 - 3
	elseif args.extraSpellId == 459421 then
		timerHolyLightCD:Start(14.5, args.destGUID)--17-2.5
	elseif args.extraSpellId == 448179 then
		timerArmorShellCD:Start(24, args.destGUID)
	elseif args.extraSpellId == 443162 then
		timerShadowStrikeCD:Start(8.2, args.destGUID)--8.2-8.7
	elseif args.extraSpellId == 1216805 then
		timerZapCD:Start(18.5, args.destGUID)--20.5-2
	elseif args.extraSpellId == 1214238 then
		timerHardenShellCD:Start(30.4, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	if args.spellId == 424614 and args:IsDestTypePlayer() then
		if args:IsPlayer() or self:CheckDispelFilter("poison") then
			warnDebilitatingVenom:Show(args.destName)
		end
	elseif args.spellId == 449071 then
		timerBlazingWickCD:Start(nil, args.destGUID)
	elseif args.spellId == 418297 then
		warnCastigate:Show(args.destName)
		timerCastigateCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCastigate:Show(args.sourceName)
			specWarnCastigate:Play("kickcast")
		end
	elseif args.spellId == 430036 then
		if args:IsPlayer() then
			specWarnSpearFish:Show()
			specWarnSpearFish:Play("pullin")
		else
			warnSpearFish:Show(args.destName)
		end
	elseif args.spellId == 440622 and args:IsDestTypePlayer() then
		if self:CheckDispelFilter("curse") then
			specWarnCurseoftheDepths:Show(args.destName)
			specWarnCurseoftheDepths:Play("helpdispel")
		end
	elseif args.spellId == 441129 and args:IsPlayer() and self:AntiSpam(3, 6) then
		specWarnSpotted:Show()
		specWarnSpotted:Play("watchstep")
		specWarnSpotted:ScheduleVoice(1, "keepmove")
	elseif args.spellId == 448161 then
		if self.Options.SpecWarn448161dispel then
			specWarnEnrageDispel:Show(args.destName)
			specWarnEnrageDispel:Play("enrage")
		else
			warnEnrage:Show()
		end
	elseif args.spellId == 1220472 then
		specWarnOverchargedDispel:Show(args.destName)
		specWarnOverchargedDispel:Play("enrage")
	elseif (args.spellId == 470592 or args.spellId == 443482 or args.spellId == 458879) and args:IsDestTypeHostile() then
		specWarnBlessingofDuskDispel:Show(args.destName)
		specWarnBlessingofDuskDispel:Play("dispelboss")
	elseif args.spellId == 445407 then
		warnBloodthirsty:Show(args.destName)
	end
end

--[[
function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	if args.spellId == 1098 then

	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 138561 and destGUID == UnitGUID("player") and self:AntiSpam() then

	end
end
--]]

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 216584 then--Nerubian Captain
		timerWebbedAegisCD:Stop(args.destGUID)
		timerWideSwipeCD:Stop(args.destGUID)
	elseif cid == 208242 then--Nerubian Darkcaster
		timerShadowsofStrifeCD:Stop(args.destGUID)
    elseif cid == 223541 then--Stolen Loader
        timerLavablastCD:Stop(args.destGUID)
		timerLavablast:Stop(args.destGUID)
		timerMagmaHammerCD:Stop(args.destGUID)
	elseif cid == 207460 then--Fungarian Flinger
		timerRotWaveVolleyCD:Stop(args.destGUID)
	elseif cid == 204127 then--Kobold Taskfinder
		timerBlazingWickCD:Stop(args.destGUID)
		timerBlazingWick:Stop(args.destGUID)
		timerBattleCryCD:Stop(args.destGUID)
	elseif cid == 207454 then--Fungal Gutter
		timerBattleRoarCD:Stop(args.destGUID)
		timerViciousStabsCD:Stop(args.destGUID)
	elseif cid == 207456 then--Fungal Speartender
		timerBattleRoarCD:Stop(args.destGUID)
	elseif cid == 207450 then--Fungal Stabber
		timerDebilitatingVenomCD:Stop(args.destGUID)
	elseif cid == 211062 then--Bill
		timerBladeTossCD:Stop(args.destGUID)
	elseif cid == 207455 then--Fungal Speartender
		timerVineSpearCD:Stop(args.destGUID)
	elseif cid == 213434 then--Sporbit (annoying ass undying exploding spores)
		timerRelocateCD:Stop(args.destGUID)--As noted above, they are undying, but JUST IN CASE
	elseif cid == 208245 or cid == 220508 then--Skittering Swarmer & The Puppetmaster?
		timerSkitterChargeCD:Stop(args.destGUID)
	elseif cid == 207482 then--Invasive Sporecap
		timerFungalBreathCD:Stop(args.destGUID)
		timerFungalBloomCD:Stop(args.destGUID)
	elseif cid == 208728 then--Treasure Wraith
		timerCastigateCD:Stop(args.destGUID)
		timerUmbrelSlashCD:Stop(args.destGUID)
	elseif cid == 214338 then--Kobyss Spearfisher
		timerSpearFishCD:Stop(args.destGUID)
	elseif cid == 211777 then--Spitfire Fusetender
		timerThrowDynoCD:Stop(args.destGUID)
	elseif cid == 214551 then--Wandering Gutter
		timerSerratedCleaveCD:Stop(args.destGUID)
		timerBloodthirstyCD:Stop(args.destGUID)
	elseif cid == 216583 then--Chittering Fearmonger
		timerFearfulShriekCD:Stop(args.destGUID)
	elseif cid == 219035 then--Deepwalker Guardian
		timerJaggedBarbs:Stop(args.destGUID)
	elseif cid == 218103 then--Nerubian Lord
		timerJaggedBarbs:Stop(args.destGUID)
	elseif cid == 220510 then--The Puppetmaster?
		timerJaggedBarbs:Stop(args.destGUID)
	elseif cid == 219454 then--Crazed Abomination
		timerEnrageCD:Stop(args.destGUID)
		timerArmorShellCD:Stop(args.destGUID)
	elseif cid == 217870 then--Devouring Shade
		timerShadowStrikeCD:Stop(args.destGUID)
		timerUmbralSlamCD:Stop(args.destGUID)
	elseif cid == 219022 or cid == 220507 then--Ascended Webfriar / The Puppetmaster?
		timerGrimweaveOrbCD:Stop(args.destGUID)
	elseif cid == 214343 then--Kobyss Trickster
		timerIllusionStepCD:Stop(args.destGUID)
	elseif cid == 220643 then--Deepwater Makura
		timerBubbleSurgeCD:Stop(args.destGUID)
	elseif cid == 220432 then--Particularly Bad Guy
		timerHidousLaughterCD:Stop(args.destGUID)
	elseif cid == 231925 then--Drill Sergeant
		timerDrillQuakeCD:Stop(args.destGUID)
	elseif cid == 231904 then--Punchy Thug
		timerFlurryOfPunchesCD:Stop(args.destGUID)
	elseif cid == 234553 then--Dark Walker
		timerShadowSmashCD:Stop(args.destGUID)
		timerLureoftheVoidCD:Stop(args.destGUID)
		--timerAbysmalGraspCD:Stop(args.destGUID)
	elseif cid == 234208 then--Hideous Amalgamation
		timerConcussiveSmashCD:Stop(args.destGUID)
		timerShadowStompCD:Stop(args.destGUID)
	elseif cid == 234900 then--Underpin's Adoring Fan
		timerWorthlessAdorationsCD:Stop(args.destGUID)
		timerTakeASelfieCD:Stop(args.destGUID)
	elseif cid == 236895 then--Malfunctioning Pummeler
		timerTheresTheDoorCD:Stop(args.destGUID)
		timerZapCD:Stop(args.destGUID)
	elseif cid == 234905 then--Aggressively Lost Hobgoblin
		timerHeedlessChargeCD:Stop(args.destGUID)
	elseif cid == 231910 then--Masked Freelancer
		timerBloodBathCD:Stop(args.destGUID)
	elseif cid == 231906 then--Aerial Support Bot
		timerRocketBarrageCD:Stop(args.destGUID)
	elseif cid == 236892 then--Treasure Crap
		timerHardenShellCD:Stop(args.destGUID)
		timerCrushingPinchCD:Stop(args.destGUID)
	elseif cid == 239412 then--Awakened Defensive Construct
		timerGolemSmashCD:Stop(args.destGUID)
	elseif cid == 236838 then--Overcharged Bot
		timerOverchargedSlamCD:Stop(args.destGUID)
		timerCrankshaftAssaultCD:Stop(args.destGUID)
		timerOverchargeCD:Stop(args.destGUID)
	elseif cid == 244415 then--Pactsworn Dustblade
		timerSandCrashCD:Stop(args.destGUID)
	elseif cid == 244448 then--Invasive Phasecrawler
		timerEssenceCleaveCD:Stop(args.destGUID)
		--timerGravityShatterCD:Stop(args.destGUID)
	elseif cid == 244755 then--Nexus-Princess Ky'veza
		timerDarkMassacreCD:Stop(args.destGUID)
		timerNexusDaggersCD:Stop(args.destGUID)
	elseif cid == 247486 then--Waxface Variant in 3 boss room
		timerBurnAwayCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 216584 then--Nerubian Captain
		timerWebbedAegisCD:Start(6-delay, guid)--Recheck with even better zone debug
		timerWideSwipeCD:Start(3.8-delay, guid)
	elseif cid == 208242 then--Nerubian Darkcaster
		timerShadowsofStrifeCD:Start(7.8-delay, guid)--7.8-11.2
	elseif cid == 223541 then--Stolen Loader
		timerMagmaHammerCD:Start(5.9-delay, guid)
		timerLavablastCD:Start(12-delay, guid)
	elseif cid == 207460 then--Fungarian Flinger
--		timerRotWaveVolleyCD:Start(9.4-delay, guid)
	elseif cid == 204127 then--Kobold Taskfinder
--		timerBlazingWickCD:Start(14.6-delay, guid)
--		timerBattleCryCD:Start(30.3-delay, guid)
--	elseif cid == 207454 then--Fungal Gutter
--		timerBattleRoarCD:Start(19.9-delay, guid)--Cast instantly on engage
--		timerViciousStabsCD:Start(14-delay, guid)--Unknown, difficult to filter due to RP mobs fighting in background cluttering up logs
--	elseif cid == 207456 then--Fungal Speartender
--		timerBattleRoarCD:Start(9.9-delay, guid)--Cast instantly on engage
	elseif cid == 207450 then--Fungal Stabber
--		timerDebilitatingVenomCD:Start(13.3-delay, guid)
	elseif cid == 211062 then--Bill
		timerBladeTossCD:Start(4.7-delay, guid)
--	elseif cid == 207455 then--Fungal Speartender
--		timerVineSpearCD:Start(14.9-delay, guid)
	elseif cid == 213434 then--Sporesong
--		timerRelocateCD:Start(70-delay, guid)
	elseif cid == 208245 or cid == 220508 then--Skittering Swarmer & The Puppetmaster?
--		timerSkitterChargeCD:Start(12.5-delay, guid)
	elseif cid == 207482 then--Invasive Sporecap
		timerFungalBreathCD:Start(6-delay, guid)
		timerFungalBloomCD:Start(10.9-delay, guid)
	elseif cid == 208728 then--Treasure Wraith
--		timerCastigateCD:Start(17.8-delay, guid)
--		timerUmbrelSlashCD:Start(17.8-delay, guid)
--	elseif cid == 214338 then--Kobyss Spearfisher
--		timerSpearFishCD:Start(9.2-delay, guid)
	elseif cid == 211777 then--Spitfire Fusetender
--		timerThrowDynoCD:Start(7.2-delay, guid)
	elseif cid == 214551 then--Wandering Gutter
		timerBloodthirstyCD:Start(5.6-delay, guid)
		timerSerratedCleaveCD:Start(11.6-delay, guid)
	elseif cid == 216583 then--Chittering Fearmonger
		timerFearfulShriekCD:Start(3.6-delay, guid)
	elseif cid == 219454 then--Crazed Abomination
--		timerEnrageCD:Start(23-delay, guid)
--		timerArmorShellCD:Start(24-delay, guid)
	elseif cid == 217870 then--Devouring Shade
		timerShadowStrikeCD:Start(5-delay, guid)
		timerUmbralSlamCD:Start(11.2-delay, guid)
	elseif cid == 219022 or cid == 220507 then--Ascended Webfriar / The Puppetmaster?
		timerGrimweaveOrbCD:Start(6-delay, guid)--6 minimun time but can be massively delayed by CCs
	elseif cid == 214343 then--Kobyss Trickster
		timerIllusionStepCD:Start(5-delay, guid)--5-20
	elseif cid == 220643 then--Deepwater Makura
		timerBubbleSurgeCD:Start(10.4-delay, guid)
	elseif cid == 220432 then--Particularly Bad Guy
		timerHidousLaughterCD:Start(3-delay, guid)
	elseif cid == 231925 then--Drill Sergeant
		timerDrillQuakeCD:Start(5-delay, guid)
	elseif cid == 231904 then--Punchy Thug
		timerFlurryOfPunchesCD:Start(3-delay, guid)
	elseif cid == 234553 then--Dark Walker
		timerShadowSmashCD:Start(5.7-delay, guid)--5.7-7.2
		timerLureoftheVoidCD:Start(15.4-delay, guid)
		--timerAbysmalGraspCD:Start(32-delay, guid)
	elseif cid == 234208 then--Hideous Amalgamation
		--timerConcussiveSmashCD:Start(7.7-delay, guid)--Can be used instantly on pull
		timerShadowStompCD:Start(28.6-delay, guid)--Probably totally wrong, not enough data
	elseif cid == 234900 then--Underpin's Adoring Fan
		timerWorthlessAdorationsCD:Start(4.9-delay, guid)
		timerTakeASelfieCD:Start(9.5-delay, guid)
	elseif cid == 236895 then--Malfunctioning Pummeler
		timerZapCD:Start(5.1-delay, guid)
		timerTheresTheDoorCD:Start(10.3-delay, guid)
	elseif cid == 234905 then--Aggressively Lost Hobgoblin
		timerHeedlessChargeCD:Start(3.5-delay, guid)
	elseif cid == 231910 then--Masked Freelancer
		timerBloodBathCD:Start(31.2-delay, guid)
	elseif cid == 231906 then--Aerial Support Bot
		timerRocketBarrageCD:Start(7-delay, guid)
	elseif cid == 236892 then--Treasure Crap
		timerCrushingPinchCD:Start(2-delay, guid)--2-5
--		timerHardenShellCD:Start(13-delay, guid)--i think first one is health based due to large variations
	elseif cid == 239412 then--Awakened Defensive Construct
		timerGolemSmashCD:Start(14-delay, guid)
	elseif cid == 236838 then--Overcharged Bot
		timerOverchargeCD:Start(6-delay, guid)
		timerCrankshaftAssaultCD:Start(9.5-delay, guid)
		timerOverchargedSlamCD:Start(22.9-delay, guid)
	elseif cid == 244415 then--Pactsworn Dustblade
		timerSandCrashCD:Start(9.8-delay, guid)
	elseif cid == 244448 then--Invasive Phasecrawler
		timerEssenceCleaveCD:Start(6.8-delay, guid)
		--timerGravityShatterCD:Start(10.6-delay, guid)
	elseif cid == 244755 then--Nexus-Princess Ky'veza
		timerDarkMassacreCD:Start(15.5-delay, guid)
		timerNexusDaggersCD:Start(29.8-delay, guid)
	elseif cid == 247486 then--Waxface Variant in 3 boss room
		timerBurnAwayCD:Start(18.2-delay, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end

