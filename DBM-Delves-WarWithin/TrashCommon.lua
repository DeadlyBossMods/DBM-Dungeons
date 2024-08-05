local mod	= DBM:NewMod("DelveTrashCommon", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)--Stays active in all zones for zone change handlers, but registers events based on dungeon ids

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
local warnDebilitatingVenom					= mod:NewTargetNoFilterAnnounce(424614, 3)--Brann will dispel this if healer role
local warnCastigate							= mod:NewTargetNoFilterAnnounce(418297, 4)
local warnSpearFish							= mod:NewTargetNoFilterAnnounce(430036, 2)
local warnRelocate							= mod:NewSpellAnnounce(427812, 2)
local warnLeechingSwarm						= mod:NewSpellAnnounce(450637, 2)
local warnShadowsofStrife					= mod:NewCastAnnounce(449318, 3)--High Prio Interrupt
local warnWebbedAegis						= mod:NewCastAnnounce(450546, 3)
local warnBloatedEruption					= mod:NewCastAnnounce(424798, 4)
local warnBattleRoar						= mod:NewCastAnnounce(414944, 3)
local warnVineSpear							= mod:NewCastAnnounce(424891, 3, nil, nil, nil, nil, nil, 12)
local warnSkitterCharge						= mod:NewCastAnnounce(450197, 3, nil, nil, nil, nil, nil, 2)
local warnWicklighterVolley					= mod:NewCastAnnounce(445191, 3)
local warnThrowDyno							= mod:NewSpellAnnounce(448600, 3)

local specWarnFearfulShriek					= mod:NewSpecialWarningDodge(433410, nil, nil, nil, 2, 2)
local specWarnJaggedBarbs					= mod:NewSpecialWarningDodge(450714, nil, nil, nil, 2, 2)--11-26
local specWarnLavablast	    				= mod:NewSpecialWarningDodge(445781, nil, nil, nil, 2, 2)
local specWarnFungalBreath    				= mod:NewSpecialWarningDodge(415253, nil, nil, nil, 2, 2)
local specWarnViciousStabs    				= mod:NewSpecialWarningDodge(424704, nil, nil, nil, 2, 2)
local specWarnBlazingWick    				= mod:NewSpecialWarningDodge(449071, nil, nil, nil, 2, 2)
local specWarnBladeRush						= mod:NewSpecialWarningDodge(418791, nil, nil, nil, 2, 2)
local specWarnDefilingBreath				= mod:NewSpecialWarningDodge(455932, nil, nil, nil, 2, 2)
local specWarnSerratedCleave				= mod:NewSpecialWarningDodge(445492, nil, nil, nil, 2, 2)--32.7
local specWarnSpotted						= mod:NewSpecialWarningDodge(441129, nil, nil, nil, 2, 2)
local specWarnFireCharge					= mod:NewSpecialWarningDodge(445210, nil, nil, nil, 2, 2)
local specWarnEchoofRenilash				= mod:NewSpecialWarningRun(434281, nil, nil, nil, 4, 2)
local specWarnNecroticEnd					= mod:NewSpecialWarningRun(445252, nil, nil, nil, 4, 2)
local specWarnCurseoftheDepths				= mod:NewSpecialWarningDispel(440622, "RemoveCurse", nil, nil, 1, 2)
local specWarnShadowsofStrife				= mod:NewSpecialWarningInterrupt(449318, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnWebbedAegis					= mod:NewSpecialWarningInterrupt(450546, "HasInterrupt", nil, nil, 1, 2)
local specWarnRotWaveVolley					= mod:NewSpecialWarningInterrupt(425040, "HasInterrupt", nil, nil, 1, 2)
local specWarnCastigate						= mod:NewSpecialWarningInterrupt(418297, "HasInterrupt", nil, nil, 1, 2)
local specWarnBattleCry						= mod:NewSpecialWarningInterrupt(448399, "HasInterrupt", nil, nil, 1, 2)

local timerFearfulShriekCD					= mod:NewCDNPTimer(13.4, 433410, nil, nil, nil, 3)
local timerShadowsofStrifeCD				= mod:NewCDNPTimer(20, 449318, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Needs more Data
local timerRotWaveVolleyCD					= mod:NewCDNPTimer(15.2, 425040, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--15.2-17
local timerWebbedAegisCD					= mod:NewCDNPTimer(14.6, 450546, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--14.6 BUT enemies can skip casts sometimes and make it 29.1
local timerLavablastCD					    = mod:NewCDNPTimer(15.8, 445781, nil, nil, nil, 3)
local timerBlazingWickCD					= mod:NewCDNPTimer(14.6, 449071, nil, nil, nil, 3)
local timerBattleRoarCD						= mod:NewCDNPTimer(15.4, 414944, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerDebilitatingVenomCD				= mod:NewCDNPTimer(13.4, 424614, nil, nil, nil, 5, nil, DBM_COMMON_L.POISON_ICON)
local timerBladeRushCD						= mod:NewCDNPTimer(15.4, 418791, nil, nil, nil, 3)
local timerVineSpearCD						= mod:NewCDNPTimer(14.9, 424891, nil, nil, nil, 3)
local timerRelocateCD						= mod:NewCDNPTimer(70, 427812, nil, nil, nil, 3)
local timerSkitterChargeCD					= mod:NewCDNPTimer(12.2, 450197, nil, nil, nil, 3)
local timerFungalBreathCD					= mod:NewCDNPTimer(15.4, 415253, nil, nil, nil, 3)
local timerCastigateCD						= mod:NewCDNPTimer(17.8, 418297, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBattleCryCD						= mod:NewCDNPTimer(30.3, 448399, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerWicklighterVolleyCD				= mod:NewCDNPTimer(21.8, 445191, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Needs more Data
local timerSpearFishCD						= mod:NewCDNPTimer(12.1, 430036, nil, nil, nil, 3)
local timerViciousStabsCD					= mod:NewCDNPTimer(20.6, 424704, nil, nil, nil, 3)
local timerThrowDynoCD						= mod:NewCDNPTimer(7.2, 448600, nil, nil, nil, 3)
local timerSerratedCleaveCD					= mod:NewCDNPTimer(32.7, 445492, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Not technically tanks only, just whoever has aggro in it

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

do
	local validZones = {[2664] = true, [2679] = true, [2680] = true, [2681] = true, [2682] = true, [2683] = true, [2684] = true, [2685] = true, [2686] = true, [2687] = true, [2688] = true, [2689] = true, [2690] = true, [2767] = true, [2768] = true}
	local eventsRegistered = false
	function mod:DelayedZoneCheck(force)
		local currentZone = DBM:GetCurrentArea() or 0
		if not force and validZones[currentZone] and not eventsRegistered then
			eventsRegistered = true
			self:RegisterShortTermEvents(
                "SPELL_CAST_START 449318 450546 433410 450714 445781 415253 425040 424704 424798 414944 418791 424891 450197 448399 445191 455932 445492 434281 450637 445210 448528 449071",
                "SPELL_CAST_SUCCESS 414944 424614 418791 424891 427812 450546 450197 415253 449318 445191 430036 445252 425040 424704 448399 448528 433410 445492",
				"SPELL_INTERRUPT",
                "SPELL_AURA_APPLIED 424614 449071 418297 430036 440622 441129",
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
	elseif args.spellId == 450714 then
		if self:AntiSpam(3, 2) then
			specWarnJaggedBarbs:Show()
			specWarnJaggedBarbs:Play("shockwave")
		end
	elseif args.spellId == 445781 then
        timerLavablastCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnLavablast:Show()
			specWarnLavablast:Play("shockwave")
		end
	elseif args.spellId == 415253 then
		if self:AntiSpam(3, 2) then
			specWarnFungalBreath:Show()
			specWarnFungalBreath:Play("shockwave")
		end
	elseif args.spellId == 424704 then
		if self:AntiSpam(3, 2) then
			specWarnViciousStabs:Show()
			specWarnViciousStabs:Play("shockwave")
		end
	elseif args.spellId == 424798 then
		if self:AntiSpam(3, 6) then
			warnBloatedEruption:Show()
		end
	elseif args.spellId == 414944 then
		if self:AntiSpam(3, 5) then
			warnBattleRoar:Show()
		end
	elseif args.spellId == 418791 and self:IsValidWarning(args.sourceGUID) then
		if self:AntiSpam(3, 2) then
			specWarnBladeRush:Show()
			specWarnBladeRush:Play("chargemove")
		end
	elseif args.spellId == 424891 then
		if self:AntiSpam(3, 6) then
			warnVineSpear:Show()
			warnVineSpear:Play("pullin")
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
			specWarnDefilingBreath:Play("shockwave")
		end
	elseif args.spellId == 445492 then
		if self:AntiSpam(3, 2) then
			specWarnSerratedCleave:Show()
			specWarnSerratedCleave:Play("shockwave")
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
		if self:AntiSpam(3, 2) then
			specWarnBlazingWick:Show()
			specWarnBlazingWick:Play("shockwave")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 414944 then
		if args:GetSrcCreatureID() == 207454 then--Fungal Gutter
			timerBattleRoarCD:Start(19.9, args.sourceGUID)--19.9-24.7
		else--207456 Fungal Speartender
			timerBattleRoarCD:Start(9.9, args.sourceGUID)--9.9-12
		end
	elseif args.spellId == 424614 then
		timerDebilitatingVenomCD:Start(12.3, args.sourceGUID)--13.3 - 1
	elseif args.spellId == 418791 then
		timerBladeRushCD:Start(11.1, args.sourceGUID)--12.1 - 1
	elseif args.spellId == 424891 then
		timerVineSpearCD:Start(10.9, args.sourceGUID)--14.9 - 4
	elseif args.spellId == 427812 then
		timerRelocateCD:Start(70, args.sourceGUID)--Spores teleport every 70 seconds
		if self:AntiSpam(3, 6) then
			warnRelocate:Show()
		end
	elseif args.spellId == 450546 then
		timerWebbedAegisCD:Start(14.6, args.sourceGUID)
	elseif args.spellId == 450197 then
		timerSkitterChargeCD:Start(12.5, args.sourceGUID)-- 14.6 - 2.1
	elseif args.spellId == 415253 then
		timerFungalBreathCD:Start(15.2, args.sourceGUID)-- 18.2 - 3
	elseif args.spellId == 449318 then
		timerShadowsofStrifeCD:Start(17, args.sourceGUID)--20 - 3
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
	elseif args.spellId == 424704 then
		timerViciousStabsCD:Start(18.6, args.sourceGUID)--20.6 - 2
	elseif args.spellId == 448399 then
		timerBattleCryCD:Start(28.3, args.sourceGUID)--30.3 - 2
	elseif args.spellId == 448528 then
		timerThrowDynoCD:Start(5.7, args.sourceGUID)-- 7.2 - 1.5
	elseif args.spellId == 433410 then
		timerFearfulShriekCD:Start(10.4, args.sourceGUID)--13.4 - 3
	elseif args.spellId == 445492 then
		timerSerratedCleaveCD:Start(29.7, args.sourceGUID)--32.7 - 3
	end
end

--Likely some of these aren't even interruptable, but i can't remember sometimes so they get added anyways
function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 414944 then
		if args:GetSrcCreatureID() == 207454 then--Fungal Gutter
			timerBattleRoarCD:Start(19.9, args.destGUID)--19.9-24.7
		else--207456 Fungal Speartender
			timerBattleRoarCD:Start(9.9, args.destGUID)--9.9-12
		end
	elseif args.extraSpellId == 450546 then
		timerWebbedAegisCD:Start(14.6, args.destGUID)
	elseif args.extraSpellId == 449318 then
		timerShadowsofStrifeCD:Start(17, args.destGUID)--20 - 3
	elseif args.extraSpellId == 445191 then
		timerWicklighterVolleyCD:Start(18.3, args.destGUID)--21.8 - 3.5
	elseif args.extraSpellId == 425040 then
		timerRotWaveVolleyCD:Start(9.4, args.destGUID)--12.4 - 3
	elseif args.extraSpellId == 424704 then
		timerViciousStabsCD:Start(18.6, args.destGUID)--20.6 - 2
	elseif args.extraSpellId == 448399 then
		timerBattleCryCD:Start(28.3, args.destGUID)--30.3 - 2
	elseif args.extraSpellId == 448528 then
		timerThrowDynoCD:Start(5.7, args.destGUID)-- 7.2 - 1.5
	elseif args.extraSpellId == 433410 then
		timerFearfulShriekCD:Start(10.4, args.destGUID)--13.4 - 3
	end
end

function mod:SPELL_AURA_APPLIED(args)
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
		warnSpearFish:Show(args.destName)
	elseif args.spellId == 440622 and args:IsDestTypePlayer() then
		if self:CheckDispelFilter("curse") then
			specWarnCurseoftheDepths:Show(args.destName)
			specWarnCurseoftheDepths:Play("helpdispel")
		end
	elseif args.spellId == 441129 and args:IsPlayer() and self:AntiSpam(3, 6) then
		specWarnSpotted:Show()
		specWarnSpotted:Play("watchstep")
		specWarnSpotted:ScheduleVoice(1, "keepmove")
	end
end

--[[
function mod:SPELL_AURA_REMOVED(args)
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
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 216584 then--Nerubian Captain
		timerWebbedAegisCD:Stop(args.destGUID)
	elseif cid == 208242 then--Nerubian Darkcaster
		timerShadowsofStrifeCD:Stop(args.destGUID)
    elseif cid == 223541 then--Stolen Loader
        timerLavablastCD:Stop(args.destGUID)
	elseif cid == 207460 then--Fungarian Flinger
		timerRotWaveVolleyCD:Stop(args.destGUID)
	elseif cid == 204127 then--Kobold Taskfinder
		timerBlazingWickCD:Stop(args.destGUID)
	elseif cid == 207454 then--Fungal Gutter
		timerBattleRoarCD:Stop(args.destGUID)
		timerViciousStabsCD:Stop(args.destGUID)
	elseif cid == 207456 then--Fungal Speartender
		timerBattleRoarCD:Stop(args.destGUID)
	elseif cid == 207450 then--Fungal Stabber
		timerDebilitatingVenomCD:Stop(args.destGUID)
	elseif cid == 211062 then--Bill
		timerBladeRushCD:Stop(args.destGUID)
	elseif cid == 207455 then--Fungal Speartender
		timerVineSpearCD:Stop(args.destGUID)
	elseif cid == 213434 then--Sporbit (annoying ass undying exploding spores)
		timerRelocateCD:Stop(args.destGUID)--As noted above, they are undying, but JUST IN CASE
	elseif cid == 208245 or cid == 220508 then--Skittering Swarmer & The Puppetmaster?
		timerSkitterChargeCD:Stop(args.destGUID)
	elseif cid == 207482 then--Invasive Sporecap
		timerFungalBreathCD:Stop(args.destGUID)
	elseif cid == 208728 then--Treasure Wraith
		timerCastigateCD:Stop(args.destGUID)
	elseif cid == 204127 then--Kobolt Taskfinder
		timerBattleCryCD:Stop(args.destGUID)
	elseif cid == 214338 then--Kobyss Spearfisher
		timerSpearFishCD:Stop(args.destGUID)
	elseif cid == 211777 then--Spitfire Fusetender
		timerThrowDynoCD:Stop(args.destGUID)
	elseif cid == 214551 then--Wandering Gutter
		timerSerratedCleaveCD:Stop(args.destGUID)
	elseif cid == 216583 then--Chittering Fearmonger
		timerFearfulShriekCD:Stop(args.destGUID)
	end
end
