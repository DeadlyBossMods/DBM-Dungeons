local mod	= DBM:NewMod("DelveTrashCommon", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)--Stays active in all zones for zone change handlers, but registers events based on dungeon ids
--2664, 2679, 2680, 2681, 2683, 2684, 2685, 2686, 2687, 2688, 2689, 2690, 2767, 2768
mod:RegisterZoneCombat(2664)
mod:RegisterZoneCombat(2679)
mod:RegisterZoneCombat(2680)
mod:RegisterZoneCombat(2681)
mod:RegisterZoneCombat(2683)
mod:RegisterZoneCombat(2684)
mod:RegisterZoneCombat(2685)
mod:RegisterZoneCombat(2686)
mod:RegisterZoneCombat(2687)
mod:RegisterZoneCombat(2688)
mod:RegisterZoneCombat(2689)
mod:RegisterZoneCombat(2690)
mod:RegisterZoneCombat(2767)
mod:RegisterZoneCombat(2768)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"PLAYER_MAP_CHANGED"
)

--TODO Add Void Bolt interrupt. it hits for 1.4 Million on level 2
--TODO, add firecharge timer
--NOTE: Many abilities are shared by mobs that can spawn in ANY delve.
--But others are for mobs that only spawn in specific delves. Over time these should be split up appropriately
--for now ALL are being put in common til we have enough data to scope trash abilities to appropriate modules
--NOTE: Jagged Slash (450176) has precisely 9.7 CD, but is it worth tracking?
--NOTE: Stab (443510) is a 14.6 CD, but is it worth tracking?
--TODO: add "Gatling Wand-461757-npc:228044-00004977F7 = pull:1392.7, 17.0, 17.0", (used by Reno Jackson)
--TODO: timer for Armored Core from WCL
--TODO, is https://www.wowhead.com/spell=453149/gossamer-webbing worth adding, Brann seems to think so
--TODO, Umbral Slam timer?
--TODO, detect and alert https://www.wowhead.com/npc=217208/zekvir spawning in your delve with a large warning
--TODO, add/confirm timers for random spawn version of zekvir for nameplate timers
local warnDebilitatingVenom					= mod:NewTargetNoFilterAnnounce(424614, 3)--Brann will dispel this if healer role
local warnCastigate							= mod:NewTargetNoFilterAnnounce(418297, 4)
local warnSpearFish							= mod:NewTargetNoFilterAnnounce(430036, 2)
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
local warnEnrage							= mod:NewSpellAnnounce(448161, 3)
local warnThrowDyno							= mod:NewSpellAnnounce(448600, 3)

local specWarnSpearFish						= mod:NewSpecialWarningYou(430036, nil, nil, nil, 2, 12)
local specWarnFungalBloom					= mod:NewSpecialWarningSpell(415250, nil, nil, nil, 2, 2)
local specWarnFearfulShriek					= mod:NewSpecialWarningDodge(433410, nil, nil, nil, 2, 2)
local specWarnJaggedBarbs					= mod:NewSpecialWarningDodge(450714, nil, nil, nil, 2, 15)--11-26
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
local specWarnEchoofRenilash				= mod:NewSpecialWarningRun(434281, nil, nil, nil, 4, 2)
local specWarnNecroticEnd					= mod:NewSpecialWarningRun(445252, nil, nil, nil, 4, 2)
local specWarnHorrendousRoar				= mod:NewSpecialWarningRun(450492, nil, nil, nil, 4, 2)
local specWarnCurseoftheDepths				= mod:NewSpecialWarningDispel(440622, "RemoveCurse", nil, nil, 1, 2)
local specWarnEnrageDispel					= mod:NewSpecialWarningDispel(448161, "RemoveEnrage", nil, nil, 1, 2)
local specWarnBlessingofDuskDispel			= mod:NewSpecialWarningDispel(470592, "MagicDispeller", nil, nil, 1, 2)--Used by most speakers, boss and trash alike
local specWarnShadowsofStrife				= mod:NewSpecialWarningInterrupt(449318, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnWebbedAegis					= mod:NewSpecialWarningInterrupt(450546, "HasInterrupt", nil, nil, 1, 2)
local specWarnRotWaveVolley					= mod:NewSpecialWarningInterrupt(425040, "HasInterrupt", nil, nil, 1, 2)
local specWarnCastigate						= mod:NewSpecialWarningInterrupt(418297, "HasInterrupt", nil, nil, 1, 2)
local specWarnBattleCry						= mod:NewSpecialWarningInterrupt(448399, "HasInterrupt", nil, nil, 1, 2)
local specWarnHolyLight						= mod:NewSpecialWarningInterrupt(459421, "HasInterrupt", nil, nil, 1, 2)
local specWarnArmoredShell					= mod:NewSpecialWarningInterrupt(448179, "HasInterrupt", nil, nil, 1, 2)
local specWarnBlessingofDusk				= mod:NewSpecialWarningInterrupt(470592, "HasInterrupt", nil, nil, 1, 2)--Speaker Davenruth
local specWarnEnfeeblingSpittleInterrupt	= mod:NewSpecialWarningInterrupt(450505, nil, nil, nil, 1, 2)

local timerFearfulShriekCD					= mod:NewCDPNPTimer(13.4, 433410, nil, nil, nil, 3)
local timerShadowsofStrifeCD				= mod:NewCDNPTimer(15.6, 449318, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRotWaveVolleyCD					= mod:NewCDNPTimer(15.2, 425040, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--15.2-17
local timerWebbedAegisCD					= mod:NewCDNPTimer(15.8, 450546, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--14.6 BUT enemies can skip casts sometimes and make it 29.1
local timerMagmaHammerCD					= mod:NewCDNPTimer(8.5, 445718, nil, nil, nil, 5)
local timerLavablastCD					    = mod:NewCDNPTimer(15.8, 445781, nil, nil, nil, 3)
local timerLavablast						= mod:NewCastNPTimer(3, 445781, DBM_COMMON_L.FRONTAL, nil, nil, 5)
local timerBlazingWickCD					= mod:NewCDPNPTimer(14.6, 449071, nil, nil, nil, 3)
local timerBlazingWick						= mod:NewCastNPTimer(2.25, 449071, DBM_COMMON_L.FRONTAL, nil, nil, 5)
local timerBattleRoarCD						= mod:NewCDPNPTimer(15.4, 414944, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerDebilitatingVenomCD				= mod:NewCDNPTimer(13.4, 424614, nil, nil, nil, 5, nil, DBM_COMMON_L.POISON_ICON)
local timerBladeTossCD						= mod:NewCDNPTimer(15.4, 418791, nil, nil, nil, 3)
local timerVineSpearCD						= mod:NewCDNPTimer(14.9, 424891, nil, nil, nil, 3)
local timerRelocateCD						= mod:NewCDNPTimer(70, 427812, nil, nil, nil, 3)
local timerSkitterChargeCD					= mod:NewCDNPTimer(12.2, 450197, nil, nil, nil, 3)
local timerFungalBreathCD					= mod:NewCDNPTimer(15.4, 415253, nil, nil, nil, 3)--28 now?
local timerUmbralSlamCD						= mod:NewCDNPTimer(30, 443292, nil, nil, nil, 3)
local timerUmbrelSlashCD					= mod:NewCDNPTimer(17.8, 418295, nil, nil, nil, 3)
local timerCastigateCD						= mod:NewCDPNPTimer(17.8, 418297, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
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

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

do
	local validZones = {[2664] = true, [2679] = true, [2680] = true, [2681] = true, [2683] = true, [2684] = true, [2685] = true, [2686] = true, [2687] = true, [2688] = true, [2689] = true, [2690] = true, [2767] = true, [2768] = true}
	local eventsRegistered = false
	function mod:DelayedZoneCheck(force)
		local currentZone = DBM:GetCurrentArea() or 0
		if not force and validZones[currentZone] and not eventsRegistered then
			eventsRegistered = true
			self:RegisterShortTermEvents(
                "SPELL_CAST_START 449318 450546 433410 450714 445781 415253 425040 424704 424798 414944 418791 424891 450197 448399 445191 455932 445492 434281 450637 445210 448528 449071 462686 459421 448179 445774 443292 450492 450519 450505 450509 448155 448161 418295 415250 434740 470592 443482 458879 445718",
                "SPELL_CAST_SUCCESS 414944 424614 418791 424891 427812 450546 450197 415253 449318 445191 430036 445252 425040 424704 448399 448528 433410 445492 462686 447392 459421 448179 450509 415250 443162 443292",
				"SPELL_INTERRUPT",
                "SPELL_AURA_APPLIED 424614 449071 418297 430036 440622 441129 448161 470592 443482 458879",
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
	elseif args.spellId == 443292 then
		if self:AntiSpam(3, 2) then
			specWarnUmbralSlam:Show()
			specWarnUmbralSlam:Play("frontal")
		end
	elseif args.spellId == 418295 then
		timerUmbrelSlashCD:Start(nil, args.sourceGUID)
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
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	if args.spellId == 414944 and self:IsValidWarning(args.sourceGUID) then
		if args:GetSrcCreatureID() == 207454 then--Fungal Gutter
			timerBattleRoarCD:Start(19.9, args.sourceGUID)--19.9-24.7
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
	elseif args.spellId == 445492 then
		timerSerratedCleaveCD:Start(29.7, args.sourceGUID)--32.7 - 3
	elseif args.spellId == 462686 then
		timerSkullCrackerCD:Start(13.3, args.sourceGUID)--15.8 - 2.5
	elseif args.spellId == 447392 then--Supply Bag (Cast when Reno Jackson Defeated)
		timerSkullCrackerCD:Stop(args.sourceGUID)
	elseif args.spellId == 459421 then
		timerHolyLightCD:Start(14.5, args.sourceGUID)--17-2.5
	elseif args.spellId == 448179 then
		timerArmorShellCD:Start(24, args.sourceGUID)
	elseif args.spellId == 450509 then
		timerWideSwipeCD:Start(7.9, args.sourceGUID)--7.9-8.5
	elseif args.spellId == 415250 then
		timerFungalBloomCD:Start(nil, args.sourceGUID)
	elseif args.spellId == 443162 then
		timerShadowStrikeCD:Start(8.2, args.sourceGUID)--8.2-8.7
	elseif args.spellId == 443292 then
		timerUmbralSlamCD:Start(27, args.sourceGUID)
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
	elseif args.spellId == 470592 or args.spellId == 443482 or args.spellId == 458879 then
		specWarnBlessingofDuskDispel:Show(args.destName)
		specWarnBlessingofDuskDispel:Play("dispelboss")
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
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartNameplateTimers(guid, cid)
	if cid == 216584 then--Nerubian Captain
		timerWebbedAegisCD:Start(6, guid)--Recheck with even better zone debug
		timerWideSwipeCD:Start(9.5, guid)--Recheck with even better zone debug
	elseif cid == 208242 then--Nerubian Darkcaster
		timerShadowsofStrifeCD:Start(11.2, guid)
	elseif cid == 223541 then--Stolen Loader
		timerMagmaHammerCD:Start(5.9, guid)
		timerLavablastCD:Start(12, guid)
	elseif cid == 207460 then--Fungarian Flinger
--		timerRotWaveVolleyCD:Start(9.4, guid)
	elseif cid == 204127 then--Kobold Taskfinder
--		timerBlazingWickCD:Start(14.6, guid)
--		timerBattleCryCD:Start(30.3, guid)
	elseif cid == 207454 then--Fungal Gutter
--		timerBattleRoarCD:Start(19.9, guid)
--		timerViciousStabsCD:Start(14, guid)
	elseif cid == 207456 then--Fungal Speartender
--		timerBattleRoarCD:Start(9.9, guid)
	elseif cid == 207450 then--Fungal Stabber
--		timerDebilitatingVenomCD:Start(13.3, guid)
	elseif cid == 211062 then--Bill
--		timerBladeTossCD:Start(12.1, guid)
	elseif cid == 207455 then--Fungal Speartender
--		timerVineSpearCD:Start(14.9, guid)
	elseif cid == 213434 then--Sporesong
--		timerRelocateCD:Start(70, guid)
	elseif cid == 208245 or cid == 220508 then--Skittering Swarmer & The Puppetmaster?
--		timerSkitterChargeCD:Start(12.5, guid)
	elseif cid == 207482 then--Invasive Sporecap
		timerFungalBreathCD:Start(6, guid)
		timerFungalBloomCD:Start(10.9, guid)
	elseif cid == 208728 then--Treasure Wraith
--		timerCastigateCD:Start(17.8, guid)
--		timerUmbrelSlashCD:Start(17.8, guid)
	elseif cid == 214338 then--Kobyss Spearfisher
		timerSpearFishCD:Start(9.2, guid)
	elseif cid == 211777 then--Spitfire Fusetender
--		timerThrowDynoCD:Start(7.2, guid)
	elseif cid == 214551 then--Wandering Gutter
--		timerSerratedCleaveCD:Start(32.7, guid)
	elseif cid == 216583 then--Chittering Fearmonger
		timerFearfulShriekCD:Start(3.6, guid)
	elseif cid == 219454 then--Crazed Abomination
--		timerEnrageCD:Start(23, guid)
--		timerArmorShellCD:Start(24, guid)
	elseif cid == 217870 then--Devouring Shade
		timerShadowStrikeCD:Start(5, guid)
		timerUmbralSlamCD:Start(11.2, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop()
end
