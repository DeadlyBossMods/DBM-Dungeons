local mod	= DBM:NewMod("CityofThreadsTrash", "DBM-Party-WarWithin", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2669)
mod:RegisterZoneCombat(2669)

mod:RegisterEvents(
	"SPELL_CAST_START 443430 443433 443500 451543 451423 450784 442536 452162 434137 445813 453840 446086 446717 447271 443507 443397",
	"SPELL_CAST_SUCCESS 443436 443430 443500 451543 452162 446086 443397",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 443437",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 443437",
	"UNIT_DIED"
)

--TODO, see if you can target scan Perfume Toss? since drycoding off WCL not sure if it can actually be side stepped or not
--TODO, track https://www.wowhead.com/beta/spell=441795/pheromone-veil and https://www.wowhead.com/beta/spell=448047/web-wrap ?
--TODO, Quazii's guide also says Lord Vul'azak casts EarthShatter but can't find in any logs. keep an eye out for it though
--TODO, emphasis on Venomous Spray? it seems like aoe is unavoidable and then the dodging is continous after.
--TODO, quazii's guide mentions Sureki Unnaturaler casts https://www.wowhead.com/spell=453840/awakening-calling but I can't find any casts of it in any log for a timer
--TODO, add Venom Strike (443401) dispel alert?
--TODO, add interrupt warning for Web Bolt (443427)? It hits hard but is spammed.
--[[
(ability.id = 443430 or ability.id = 452162 or ability.id = 443433 or ability.id = 446086 or ability.id = 442536 or ability.id = 443500 or ability.id = 451543 or ability.id = 451423 or ability.id = 450784 or ability.id = 434137 or ability.id = 445813 or ability.id = 453840 or ability.id = 446717 or ability.id = 447271) and type = "begincast"
 or (ability.id = 443436 or ability.id = 443430 or ability.id = 443500 or ability.id = 451543 or ability.id = 452162 or ability.id = 446086) and type = "cast"
 or (stoppedAbility.id = 443430 or stoppedAbility.id = 452162 or stoppedAbility.id = 446086)
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 220193) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 220193)
--]]
local warnSilkBinding						= mod:NewCastAnnounce(443430, 3)--High Prio Interrupt
local warnPerfumeToss						= mod:NewCastAnnounce(450784, 2)
local warnMendingWeb						= mod:NewCastAnnounce(452162, 3)--High Prio Interrupt
local warnShadowsofDoubt					= mod:NewTargetAnnounce(443437, 2)
local warnVenomousSpray						= mod:NewSpellAnnounce(434137, 3)
local warnAwakeningCalling					= mod:NewSpellAnnounce(453840, 3)
local warnUmbralWeave						= mod:NewCastAnnounce(446717, 3)--Reason to special warn? can't really do much about it
local warnRavenousSwarm						= mod:NewSpellAnnounce(443507, 3)

local specWarnVenomBlade					= mod:NewSpecialWarningDefensive(443397, nil, nil, nil, 1, 2)
local specWarnShadowsofDoubt				= mod:NewSpecialWarningMoveAway(443436, nil, nil, nil, 1, 2)
local yellShadowsofDoubt					= mod:NewShortYell(443436)
local yellShadowsofDoubtFades				= mod:NewShortFadesYell(443436)
local specWarnEarthShatter					= mod:NewSpecialWarningDodge(443500, nil, nil, nil, 2, 15)
local specWarnNullSlam						= mod:NewSpecialWarningDodge(451543, nil, nil, nil, 2, 15)
local specWarnGossamerBarrage				= mod:NewSpecialWarningDodge(451423, nil, nil, nil, 2, 2)
local specWarnDarkBarrage					= mod:NewSpecialWarningDodge(445813, nil, nil, nil, 2, 2)
local specWarnTremorSlam					= mod:NewSpecialWarningRun(447271, nil, nil, nil, 4, 2)--Don't confuse with 437700 which is boss version
--local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
local specWarnSilkBinding					= mod:NewSpecialWarningInterrupt(443430, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnTwistThoughts					= mod:NewSpecialWarningInterrupt(443433, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt (no CD, so no timer)
local specWarnGrimweaveBlast				= mod:NewSpecialWarningInterrupt(442536, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt (no CD, so no timer)
local specWarnMendingWeb					= mod:NewSpecialWarningInterrupt(452162, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnVoidWave						= mod:NewSpecialWarningInterrupt(446086, "HasInterrupt", nil, nil, 1, 2)

local timerVenomBladeCD						= mod:NewCDNPTimer(11, 443397, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerShadowsofDoubtCD					= mod:NewCDNPTimer(11.1, 443436, nil, nil, nil, 3)--11.1-14.6
local timerSilkBindingCD					= mod:NewCDPNPTimer(24.5, 443430, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerEarthShatterCD					= mod:NewCDPNPTimer(11, 443500, nil, nil, nil, 3)
local timerNullSlamCD						= mod:NewCDPNPTimer(24.9, 451543, nil, nil, nil, 3)
local timerGossamerBarrageCD				= mod:NewCDNPTimer(23, 451423, nil, nil, nil, 3)--Start to Start, non CCable caster
local timerPerfumeTossCD					= mod:NewCDNPTimer(17, 450784, nil, nil, nil, 3)--Poor sample, need more data
local timerMendingWebCD						= mod:NewCDPNPTimer(16.6, 452162, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerVenomousSprayCD					= mod:NewCDNPTimer(24.2, 434137, nil, nil, nil, 3)
local timerDarkBarrageCD					= mod:NewCDNPTimer(27.6, 445813, nil, nil, nil, 3)
local timerVoidWaveCD						= mod:NewCDNPTimer(15.4, 446086, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerUmbralWeaveCD					= mod:NewCDNPTimer(20, 446717, nil, nil, nil, 2)
local timerTremorSlamCD						= mod:NewCDNPTimer(20, 447271, nil, nil, nil, 3)
local timerRavenousSwarmCD					= mod:NewCDNPTimer(18.1, 443507, nil, nil, nil, 2)

local xephEngaged

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
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
--]]

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 443430 then
		if self.Options.SpecWarn443430interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSilkBinding:Show(args.sourceName)
			specWarnSilkBinding:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSilkBinding:Show()
		end
	elseif spellId == 452162 then
		if self.Options.SpecWarn452162interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMendingWeb:Show(args.sourceName)
			specWarnMendingWeb:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnMendingWeb:Show()
		end
	elseif spellId == 443433 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTwistThoughts:Show(args.sourceName)
			specWarnTwistThoughts:Play("kickcast")
		end
	elseif spellId == 446086 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnVoidWave:Show(args.sourceName)
			specWarnVoidWave:Play("kickcast")
		end
	elseif spellId == 442536 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGrimweaveBlast:Show(args.sourceName)
			specWarnGrimweaveBlast:Play("kickcast")
		end
	elseif spellId == 443500 then
		if self:AntiSpam(3, 2) then
			specWarnEarthShatter:Show()
			specWarnEarthShatter:Play("frontal")
		end
	elseif spellId == 451543 then
		if self:AntiSpam(3, 2) then
			specWarnNullSlam:Show()
			specWarnNullSlam:Play("frontal")
		end
	elseif spellId == 451423 then
		if not xephEngaged then
			xephEngaged = args.sourceGUID
		end
		timerGossamerBarrageCD:Start(23, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnGossamerBarrage:Show()
			specWarnGossamerBarrage:Play("watchstep")
		end
	elseif spellId == 450784 then
		if not xephEngaged then
			xephEngaged = args.sourceGUID
		end
		timerPerfumeTossCD:Start(17, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnPerfumeToss:Show()
		end
	elseif spellId == 434137 then
		if self:AntiSpam(3, 6) then
			warnVenomousSpray:Show()
		end
		timerVenomousSprayCD:Start(24.2, args.sourceGUID)
	elseif spellId == 445813 then
		if self:AntiSpam(3, 2) then
			specWarnDarkBarrage:Show()
			specWarnDarkBarrage:Play("watchstep")
		end
		timerDarkBarrageCD:Start(27.6, args.sourceGUID)
	elseif spellId == 453840 then
		if self:AntiSpam(3, 6) then
			warnAwakeningCalling:Show()
		end
	elseif spellId == 446717 then
		timerUmbralWeaveCD:Start(20, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnUmbralWeave:Show()
		end
	elseif spellId == 447271 then
		timerTremorSlamCD:Start(20, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnTremorSlam:Show()
			specWarnTremorSlam:Play("justrun")
		end
	elseif spellId == 443507 then
		if self:AntiSpam(3, 2) then
			warnRavenousSwarm:Show()
		end
		--Royal Swarmguard (220197) 18.1, Hulking Warshell (221103) 17.8
		local timer = args:GetSrcCreatureID() == 220197 and 18.1 or 17.8
		timerRavenousSwarmCD:Start(timer, args.sourceGUID)
	elseif spellId == 443397 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnVenomBlade:Show()
			specWarnVenomBlade:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 443436 then
		timerShadowsofDoubtCD:Start(11.1, args.sourceGUID)
	elseif spellId == 443430 then
		timerSilkBindingCD:Start(20.8, args.sourceGUID)
	elseif spellId == 443500 then
		--Royal Swarmguard (220197) 11, Royal VenomShell (220730) 20.8
		local timer = args:GetSrcCreatureID() == 220730 and 20.8 or 11
		timerEarthShatterCD:Start(timer, args.sourceGUID)
	elseif spellId == 451543 then
		timerNullSlamCD:Start(24.9, args.sourceGUID)
	elseif spellId == 452162 then
		timerMendingWebCD:Start(16.6, args.sourceGUID)
	elseif spellId == 446086 then
		timerVoidWaveCD:Start(15.4, args.sourceGUID)
	elseif spellId == 443397 then
		timerVenomBladeCD:Start(11, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 452162 then
		timerMendingWebCD:Start(16.6, args.destGUID)
	elseif spellId == 446086 then
		timerVoidWaveCD:Start(15.4, args.destGUID)
--	elseif spellId == 443430 then
--		timerSilkBindingCD:Start(20.8, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 443437 then
		if args:IsPlayer() then
			specWarnShadowsofDoubt:Show()
			specWarnShadowsofDoubt:Play("runout")
			yellShadowsofDoubt:Yell()
			yellShadowsofDoubtFades:Countdown(spellId)
		else
			warnShadowsofDoubt:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 443437 then
		yellShadowsofDoubtFades:Cancel()
	end
end

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 220196 then--Herald of Ansurekha
		timerShadowsofDoubtCD:Stop(args.destGUID)
	elseif cid == 220195 then--Sureki Silkbinder
		timerSilkBindingCD:Stop(args.destGUID)
	elseif cid == 220197 then--Royal Swarmsguard
		timerEarthShatterCD:Stop(args.destGUID)
		timerRavenousSwarmCD:Stop(args.destGUID)
	elseif cid == 220730 then--Royal VenomShell
		timerVenomousSprayCD:Stop(args.destGUID)
		timerEarthShatterCD:Stop(args.destGUID)
	elseif cid == 220003 or cid == 219983 then--Hallows Resident
		timerNullSlamCD:Stop(args.destGUID)
	elseif cid == 223844 or cid == 224732 then--Covert Webmancer
		timerMendingWebCD:Stop(args.destGUID)
	elseif cid == 216328 then--Unstable test Subject
		timerDarkBarrageCD:Stop(args.destGUID)
	elseif cid == 216339 then--Sureki Unnaturaler
		timerVoidWaveCD:Stop(args.destGUID)
	elseif cid == 221102 then--Elder Shadeweaver
		timerUmbralWeaveCD:Stop(args.destGUID)
	elseif cid == 221103 then--Hulking Warshell
		timerTremorSlamCD:Stop(args.destGUID)
		timerRavenousSwarmCD:Stop(args.destGUID)
	elseif cid == 220193 then--Sureki Venomblade
		timerVenomBladeCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartNameplateTimers(guid, cid)
	if cid == 220196 then--Herald of Ansurekha
		timerShadowsofDoubtCD:Start(9.2, guid)--9.2-10
	elseif cid == 220195 then--Sureki Silkbinder
		timerSilkBindingCD:Start(14.8, guid)--14.8-15.3
	elseif cid == 220197 then--Royal Swarmsguard
		timerEarthShatterCD:Start(5.2, guid)--5.2-7.3
	elseif cid == 220730 then--Royal VenomShell
		timerVenomousSprayCD:Start(6, guid)--6-6.8
		timerEarthShatterCD:Start(20.5, guid)--20.5-21.4
	elseif cid == 220003 or cid == 219983 then--Hallow Resident
		timerNullSlamCD:Start(20.5, guid)--20.5-21.2
	elseif cid == 223844 or cid == 224732 then--Covert Webmancer
		timerMendingWebCD:Start(7.1, guid)--7.1-14.3
	elseif cid == 216328 then--Unstable test Subject
		timerDarkBarrageCD:Start(3.6, guid)--3.5-5.1
	elseif cid == 216339 then--Sureki Unnaturaler
		timerVoidWaveCD:Start(5.6, guid)
	elseif cid == 221102 then--Elder Shadeweaver
		timerUmbralWeaveCD:Start(4.7, guid)--4.7-5.3
	elseif cid == 221103 then--Hulking Warshell
		timerTremorSlamCD:Start(8.6, guid)--8.6-10.7
	elseif cid == 219984 then--Xeph'itik
		xephEngaged = guid
		timerPerfumeTossCD:Start(8.2, guid)--8.2-9.4
		timerGossamerBarrageCD:Start(13, guid)--13-14.3
	elseif cid == 220193 then--Sureki Venomblade
		timerVenomBladeCD:Start(3.5, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't calls top with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	--Xeph'itik is a special case, he doesn't die, so we need to clear his timers some other way
	if xephEngaged then
		timerGossamerBarrageCD:Stop(xephEngaged)
		timerPerfumeTossCD:Stop(xephEngaged)
		xephEngaged = nil
	end
	self:Stop()
end
