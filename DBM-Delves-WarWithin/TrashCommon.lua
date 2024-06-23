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
--NOTE: Many abilities are shared by mobs that can spawn in ANY delve.
--But others are for mobs that only spawn in specific delves. Over time these should be split up appropriately
--for now ALL are being put in common til we have enough data to scope trash abilities to appropriate modules
local warnDebilitatingVenom					= mod:NewTargetNoFilterAnnounce(424614, 3)--Brann will dispel this if healer role
local warnRelocate							= mod:NewSpellAnnounce(427812, 2)
local warnShadowsofStrife					= mod:NewCastAnnounce(449318, 3)--High Prio Interrupt
local warnWebbedAegis						= mod:NewCastAnnounce(450546, 3)
local warnBloatedEruption					= mod:NewCastAnnounce(424798, 4)
local warnBattleRoar						= mod:NewCastAnnounce(414944, 3)
local warnVineSpear							= mod:NewCastAnnounce(424891, 3, nil, nil, nil, nil, nil, 12)

local specWarnFearfulShriek					= mod:NewSpecialWarningDodge(433410, nil, nil, nil, 2, 2)
local specWarnJaggedBarbs					= mod:NewSpecialWarningDodge(450714, nil, nil, nil, 2, 2)
local specWarnLavablast	    				= mod:NewSpecialWarningDodge(445781, nil, nil, nil, 2, 2)
local specWarnFungalBreath    				= mod:NewSpecialWarningDodge(415253, nil, nil, nil, 2, 2)
local specWarnViciousStabs    				= mod:NewSpecialWarningDodge(424704, nil, nil, nil, 2, 2)
local specWarnBlazingWick    				= mod:NewSpecialWarningDodge(449071, nil, nil, nil, 2, 2)
local specWarnBladeRush						= mod:NewSpecialWarningDodge(418791, nil, nil, nil, 2, 2)
local specWarnShadowsofStrife				= mod:NewSpecialWarningInterrupt(449318, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnWebbedAegis					= mod:NewSpecialWarningInterrupt(450546, "HasInterrupt", nil, nil, 1, 2)
local specWarnRotWaveVolley					= mod:NewSpecialWarningInterrupt(425040, "HasInterrupt", nil, nil, 1, 2)

--local timerShadowsofStrifeCD				= mod:NewCDNPTimer(12.4, 449318, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--12.4-15.1
local timerRotWaveVolleyCD					= mod:NewCDNPTimer(12.4, 425040, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--14.6-17
--local timerWebbedAegisCD					= mod:NewCDNPTimer(23.1, 450546, nil, nil, nil, 5)
local timerLavablastCD					    = mod:NewCDNPTimer(15.8, 445781, nil, nil, nil, 3)
local timerBlazingWickCD					= mod:NewCDNPTimer(15.4, 449071, nil, nil, nil, 3)
local timerBattleRoarCD						= mod:NewCDNPTimer(15.4, 414944, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerDebilitatingVenomCD				= mod:NewCDNPTimer(13.4, 424614, nil, nil, nil, 5, nil, DBM_COMMON_L.POISON_ICON)
local timerBladeRushCD						= mod:NewCDNPTimer(15.4, 418791, nil, nil, nil, 3)
local timerVineSpearCD						= mod:NewCDNPTimer(14.9, 424891, nil, nil, nil, 3)
local timerRelocateCD						= mod:NewCDNPTimer(70, 427812, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

do
	local validZones = {[2664] = true, [2679] = true, [2680] = true, [2681] = true, [2682] = true, [2683] = true, [2684] = true, [2685] = true, [2686] = true, [2687] = true, [2688] = true, [2689] = true, [2690] = true, [2767] = true, [2768] = true}
	local eventsRegistered = false
	function mod:DelayedZoneCheck(force)
		local currentZone = DBM:GetCurrentArea() or 0
		if not force and validZones[currentZone] and not eventsRegistered then
			eventsRegistered = true
			self:RegisterShortTermEvents(
                "SPELL_CAST_START 449318 450546 433410 450714 445781 415253 425040 424704 424798 414944 418791 424891",
                "SPELL_CAST_SUCCESS 414944 424614 418791 424891 427812",
				"SPELL_INTERRUPT",
                "SPELL_AURA_APPLIED 424614 449071",
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
		timerRotWaveVolleyCD:Start(nil, args.sourceGUID)
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
	elseif args.spellId == 418791 then
		if self:AntiSpam(3, 2) then
			specWarnBladeRush:Show()
			specWarnBladeRush:Play("chargemove")
		end
	elseif args.spellId == 424891 then
		if self:AntiSpam(3, 6) then
			warnVineSpear:Show()
			warnVineSpear:Play("pullin")
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
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 414944 then
		if args:GetSrcCreatureID() == 207454 then--Fungal Gutter
			timerBattleRoarCD:Start(19.9, args.destGUID)--19.9-24.7
		else--207456 Fungal Speartender
			timerBattleRoarCD:Start(9.9, args.destGUID)--9.9-12
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 424614 and args:IsDestTypePlayer() then
		if args:IsPlayer() or self:CheckDispelFilter("poison") then
			warnDebilitatingVenom:Show(args.destName)
		end
	elseif args.spellId == 449071 then
		timerBlazingWickCD:Start(nil, args.destGUID)
		if self:AntiSpam(3, 2) then
			specWarnBlazingWick:Show()
			specWarnBlazingWick:Play("shockwave")
		end
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
	if cid == 208242 then--Nerubian Darkcaster
	--	timerShadowsofStrifeCD:Stop(args.destGUID)
	elseif cid == 216584 then--Nerubian Captain
	--	timerWebbedAegisCD:Stop(args.destGUID)
    elseif cid == 223541 then--Stolen Loader
        timerLavablastCD:Stop(args.destGUID)
	elseif cid == 207460 then--Fungarian Flinger
		timerRotWaveVolleyCD:Stop(args.destGUID)
	elseif cid == 204127 then--Kobold Taskfinder
		timerBlazingWickCD:Stop(args.destGUID)
	elseif cid == 207454 then--Fungal Gutter
		timerBattleRoarCD:Stop(args.destGUID)
	elseif cid == 207456 then--Fungal Speartender
		timerBattleRoarCD:Stop(args.destGUID)
	elseif cid == 207450 then--Fungal Stabber
		timerDebilitatingVenomCD:Stop(args.destGUID)
	elseif cid == 211062 then--Bill
		timerBladeRushCD:Stop(args.destGUID)
	elseif cid == 207455 then--Fungal Speartender
		timerVineSpearCD:Stop(args.destGUID)
	elseif cid == 213434 then--Sporbit (annoying ass undying exploding spores)
		--As noted above, they are undying, but JUST IN CASE
		timerRelocateCD:Stop(args.destGUID)
	end
end
