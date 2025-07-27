local mod	= DBM:NewMod("TheDawnbreakerTrash", "DBM-Party-WarWithin", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2662)
mod:RegisterZoneCombat(2662, nil, true)

mod:RegisterEvents(
	"SPELL_CAST_START 451102 450854 451117 451097 431364 431494 432565 432520 431333 431637 451091 451098 431349 446615 450756 431304",
	"SPELL_CAST_SUCCESS 451112 450756 451102 431349 451119 450854 451117 451097 431364 431494 432565 432520 431637 431309 432448 451107",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 451097 432520 451112 431309 432448 451107",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 432448 451107",
	"UNIT_DIED"
)

--NOTE: Abilities for the mini bosses for Anub are also mixed in here
--TODO, more high priority interrupt CDs and alerts?
--TODO, Silken Shell needs rechecking, i moved event handler but i couldn't confirm CD is still same
--TODO, https://www.wowhead.com/beta/spell=431304/dark-floes is super rare in logs and cannot get CD for it cause no mob lives long enough to cast it twice
--[[
(ability.id = 450756 or ability.id = 451091 or ability.id = 451102 or ability.id = 446615 or ability.id = 431349 or ability.id = 451119 or ability.id = 450854 or ability.id = 451117 or ability.id = 451097 or ability.id = 431364 or ability.id = 431494 or ability.id = 432565 or ability.id = 432520 or ability.id = 431333 or ability.id = 431637 or ability.id = 431309 or ability.id = 431304) and (type = "begincast" or type = "cast")
 or (ability.id = 451112 or ability.id = 432448 or ability.id = 451107) and type = "cast"
 or stoppedAbility.id = 450756 or stoppedAbility.id = 451097 or stoppedAbility.id = 431364 or stoppedAbility.id = 431333 or stoppedAbility.id = 431309 or stoppedAbility.id = 432520
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 211341) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 211341)
 --]]
local warnReinforcements					= mod:NewSpellAnnounce(446615, 2)
local warnDarkFloes							= mod:NewSpellAnnounce(431304, 2)
local warnSilkenShell						= mod:NewCastAnnounce(451097, 3)--High prio interrupt
local warnAbyssalHowl						= mod:NewCastAnnounce(450756, 3)--High prio interrupt
local warnUmbrelRush						= mod:NewCastAnnounce(431637, 2)
local warnUmbralBarrier						= mod:NewCastAnnounce(432520, 2, nil, nil, nil, nil, nil, 2)
local warnPlantArathiBomb					= mod:NewCastAnnounce(451091, 3, 15)
local warnEnsaringShadows					= mod:NewTargetNoFilterAnnounce(431309, 2, nil, "RemoveCurse")

local specWarnShadowyDecay					= mod:NewSpecialWarningSpell(451102, nil, nil, nil, 2, 2)
local specWarnDarkOrb						= mod:NewSpecialWarningSpell(450854, nil, nil, nil, 2, 2)
local specWarnBlackEdge						= mod:NewSpecialWarningDodge(431494, nil, nil, nil, 2, 15)
local specWarnBlackHail						= mod:NewSpecialWarningDodge(432565, nil, nil, nil, 2, 2)
local specWarnTerrifyingSlam				= mod:NewSpecialWarningRun(451117, nil, nil, nil, 4, 2)
local specWarnTackyNova						= mod:NewSpecialWarningRun(451098, nil, nil, nil, 4, 2)
local specWarnTormentingEruption			= mod:NewSpecialWarningMoveAway(431349, "Melee", nil, nil, 4, 2)
local specWarnSygianSeed					= mod:NewSpecialWarningMoveAway(432448, nil, nil, nil, 1, 2)
local yellStygianSeed						= mod:NewShortYell(432448)
local yellStygianSeedFades					= mod:NewShortFadesYell(432448)
local specWarnBurstingCacoon				= mod:NewSpecialWarningMoveAway(451107, nil, nil, nil, 1, 2)
local yellBurstingCacoon					= mod:NewShortYell(451107)
local yellBurstingCacoonFades				= mod:NewShortFadesYell(451107)
local specWarnSilkenShell					= mod:NewSpecialWarningInterrupt(451097, "HasInterrupt", nil, nil, 1, 2)--High prio interrupt
local specWarnTormentingRay					= mod:NewSpecialWarningInterrupt(431364, "HasInterrupt", nil, nil, 1, 2)--High prio?
local specWarnTormentingBeam				= mod:NewSpecialWarningInterrupt(431333, "HasInterrupt", nil, nil, 1, 2)--High prio
local specWarnAbyssalHowl					= mod:NewSpecialWarningInterrupt(450756, "HasInterrupt", nil, nil, 1, 2)--High prio
local specWarnSilkenShellDispel				= mod:NewSpecialWarningDispel(451097, "MagicDispeller", nil, nil, 1, 2)
local specWarnUmbrelBarrierDispel			= mod:NewSpecialWarningDispel(432520, "MagicDispeller", nil, nil, 1, 2)
local specWarnTacticiansRageDispel			= mod:NewSpecialWarningDispel(451112, "RemoveEnrage", nil, nil, 1, 2)

local timerDarkFloesCD						= mod:NewCDNPTimer(20.8, 431304, nil, nil, nil, 1)
local timerAbyssalBlastCD					= mod:NewCDNPTimer(9.4, 451119, nil, "Tank|Healer", nil, 5)--9.4-23.98 (wildly varient due to lower priority over other abilities)
local timerShadowyDecayCD					= mod:NewCDNPTimer(23.4, 451102, nil, nil, nil, 2)
local timerDarkOrbCD						= mod:NewCDPNPTimer(14.2, 450854, nil, nil, nil, 3)--14.2-36.8 (wildly varient due to lower priority over other abilities)
local timerTerrifyingSlamCD					= mod:NewCDNPTimer(21.2, 451117, nil, nil, nil, 2)
local timerBlackEdgeCD						= mod:NewCDPNPTimer(10.3, 431494, nil, nil, nil, 3)
local timerBlackHailCD						= mod:NewCDNPTimer(12.5, 432565, nil, nil, nil, 3)
local timerUmbrelRushCD						= mod:NewCDNPTimer(9.1, 431637, nil, nil, nil, 3)
local timerUmbrelBarrierCD					= mod:NewCDPNPTimer(24.2, 432520, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--Single log with single cast, not great sample
local timerTacticiansRageCD					= mod:NewCDNPTimer(18.2, 451112, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSilkenShellCD					= mod:NewCDPNPTimer(18.4, 451097, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerTormentingRayCD					= mod:NewCDPNPTimer(8, 431364, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerAbyssalHowlCD					= mod:NewCDPNPTimer(25.6, 450756, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerTorentingEruptionCD				= mod:NewCDNPTimer(11.2, 431349, nil, nil, nil, 3)
local timerEnsnaringShadowsCD				= mod:NewCDPNPTimer(18.1, 431309, nil, nil, nil, 5, nil, DBM_COMMON_L.CURSE_ICON)
local timerStygianSeedCD					= mod:NewCDNPTimer(21.8, 432448, nil, nil, nil, 3)
local timerBurstingCacoonCD					= mod:NewCDNPTimer(15.7, 451107, nil, nil, nil, 3)

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
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 451102 then
		if self:AntiSpam(3, 4) then
			specWarnShadowyDecay:Show()
			specWarnShadowyDecay:Play("aesoon")
		end
	elseif spellId == 450854 then--Trash Version
		if self:AntiSpam(2.5, 2) then--Lowered exception since it often overlaps with Black edge, and users then think this warning is broken when it does common warning type aggregation
			specWarnDarkOrb:Show()
			specWarnDarkOrb:Play("watchorb")
		end
	elseif spellId == 451117 then
		if self:AntiSpam(3, 6) then
			specWarnTerrifyingSlam:Show()
			specWarnTerrifyingSlam:Play("justrun")
		end
	elseif spellId == 451097 then
		if self.Options.SpecWarn451097interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSilkenShell:Show(args.sourceName)
			specWarnSilkenShell:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSilkenShell:Show()
		end
	elseif spellId == 450756 then
		if self.Options.SpecWarn450756interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnAbyssalHowl:Show(args.sourceName)
			specWarnAbyssalHowl:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnAbyssalHowl:Show()
		end
	elseif spellId == 431364 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTormentingRay:Show(args.sourceName)
			specWarnTormentingRay:Play("kickcast")
		end
	elseif spellId == 431494 then
		if self:AntiSpam(3, 2) then
			specWarnBlackEdge:Show()
			specWarnBlackEdge:Play("frontal")
		end
	elseif spellId == 432565 then
		if self:AntiSpam(3, 2) then
			specWarnBlackHail:Show()
			specWarnBlackHail:Play("watchstep")
		end
	elseif spellId == 432520 then
		if self:AntiSpam(3, 6) then
			warnUmbralBarrier:Show()
			warnUmbralBarrier:Play("crowdcontrol")
		end

	elseif spellId == 431333 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTormentingBeam:Show(args.sourceName)
			specWarnTormentingBeam:Play("kickcast")
		end
	elseif spellId == 431637 then
		if self:AntiSpam(3, 6) then
			warnUmbrelRush:Show()
		end
	elseif spellId == 451091 then
		if self:AntiSpam(3, 6) then
			warnPlantArathiBomb:Show()
		end
	elseif spellId == 451098 then
		if self:AntiSpam(3, 1) then
			specWarnTackyNova:Show()
			specWarnTackyNova:Play("justrun")
		end
	elseif spellId == 431349 then
		if self:AntiSpam(3, 1) then
			specWarnTormentingEruption:Show()
			specWarnTormentingEruption:Play("scatter")
		end
	elseif spellId == 446615 and self:AntiSpam(3, 6) then
		warnReinforcements:Show()
	elseif spellId == 431304 then
		if self:AntiSpam(3, 6) then
			warnDarkFloes:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 451112 then
		timerTacticiansRageCD:Start(18.2, args.sourceGUID)
	elseif spellId == 450756 then
		timerAbyssalHowlCD:Start(25.6, args.sourceGUID)
	elseif spellId == 451102 then
		timerShadowyDecayCD:Start(23.4, args.sourceGUID)
	elseif spellId == 431349 then
		timerTorentingEruptionCD:Start(11.2, args.sourceGUID)
	elseif spellId == 451119 then
		timerAbyssalBlastCD:Start(9.4, args.sourceGUID)
	elseif spellId == 450854 then--Trash Version
		timerDarkOrbCD:Start(14.2, args.sourceGUID)
	elseif spellId == 451117 then
		timerTerrifyingSlamCD:Start(21.2, args.sourceGUID)
	elseif spellId == 451097 then
		timerSilkenShellCD:Start(18.4, args.sourceGUID)
	elseif spellId == 431364 then
		timerTormentingRayCD:Start(8, args.sourceGUID)
	elseif spellId == 431494 then
		timerBlackEdgeCD:Start(10.3, args.sourceGUID)
	elseif spellId == 432565 then
		timerBlackHailCD:Start(12.5, args.sourceGUID)
	elseif spellId == 432520 then
		timerUmbrelBarrierCD:Start(24.2, args.sourceGUID)
	elseif spellId == 431637 then
		timerUmbrelRushCD:Start(9.1, args.sourceGUID)
	elseif spellId == 431309 then
		timerEnsnaringShadowsCD:Start(18.1, args.sourceGUID)
	elseif spellId == 432448 then
		timerStygianSeedCD:Start(21.8, args.sourceGUID)
	elseif spellId == 451107 then
		timerBurstingCacoonCD:Start(15.7, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 450756 then
		timerAbyssalHowlCD:Start(25.6, args.destGUID)
	elseif spellId == 432520 then
		timerUmbrelBarrierCD:Start(24.2, args.destGUID)
	elseif spellId == 431309 then
		timerEnsnaringShadowsCD:Start(18.1, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 451097 and self:AntiSpam(4, 3) then
		specWarnSilkenShellDispel:Show(args.destName)
		specWarnSilkenShellDispel:Play("helpdispel")
	elseif spellId == 432520 and self:AntiSpam(4, 3) then
		specWarnUmbrelBarrierDispel:Show(args.destName)
		specWarnUmbrelBarrierDispel:Play("helpdispel")
	elseif spellId == 451112 and self:AntiSpam(4, 3) then
		specWarnTacticiansRageDispel:Show(args.destName)
		specWarnTacticiansRageDispel:Play("enrage")
	elseif spellId == 431309 and self:CheckDispelFilter("curse") then
		warnEnsaringShadows:CombinedShow(0.3, args.destName)
	elseif spellId == 432448 then
		if args:IsPlayer() then
			specWarnSygianSeed:Show()
			specWarnSygianSeed:Play("runout")
			yellStygianSeed:Yell()
			yellStygianSeedFades:Countdown(spellId)
		end
	elseif spellId == 451107 then
		if args:IsPlayer() then
			specWarnBurstingCacoon:Show()
			specWarnBurstingCacoon:Play("runout")
			yellBurstingCacoon:Yell()
			yellBurstingCacoonFades:Countdown(spellId)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 432448 then
		if args:IsPlayer() then
			yellStygianSeedFades:Cancel()
		end
	elseif spellId == 451107 then
		if args:IsPlayer() then
			yellBurstingCacoonFades:Cancel()
		end
	end
end

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 211261 then--Ascendant Vis'coxria
		timerAbyssalBlastCD:Stop(args.destGUID)--They all cast this
		timerShadowyDecayCD:Stop(args.destGUID)
	elseif cid == 211263 then--Deathscreamer Iken'tak
		timerAbyssalBlastCD:Stop(args.destGUID)--They all cast this
		timerDarkOrbCD:Stop(args.destGUID)
	elseif cid == 211262 then--Ixkreten the Unbreakable
		timerAbyssalBlastCD:Stop(args.destGUID)--They all cast this
		timerTerrifyingSlamCD:Stop(args.destGUID)
	elseif cid == 213932 then--Sureki Militant
		timerSilkenShellCD:Stop(args.destGUID)
	elseif cid == 214761 then--Nightfall Ritualist
		timerTormentingRayCD:Stop(args.destGUID)
		timerStygianSeedCD:Stop(args.destGUID)
	elseif cid == 213934 then--Nightfall Tactician
		timerBlackEdgeCD:Stop(args.destGUID)
		timerTacticiansRageCD:Stop(args.destGUID)
	elseif cid == 211341 then--Manifested Shadow
		timerDarkFloesCD:Stop(args.destGUID)
		timerBlackHailCD:Stop(args.destGUID)
	elseif cid == 213893 or cid == 228539 then--Nightfall Darkcaster
		timerUmbrelBarrierCD:Stop(args.destGUID)
	elseif cid == 213895 or cid == 228537 then--Nightfall Shadowalker
		timerUmbrelRushCD:Stop(args.destGUID)
	elseif cid == 214762 then--Nightfall Commander
		timerAbyssalHowlCD:Stop(args.destGUID)
	elseif cid == 213885 then--Nightfall Dark Architect
		timerTorentingEruptionCD:Stop(args.destGUID)
	elseif cid == 213892 or cid == 228540 then--Nightfall Shadowmage (223994 is an RP mage, not engaged)
		timerEnsnaringShadowsCD:Stop(args.destGUID)
	elseif cid == 210966 then--Sureki Webmage
		timerBurstingCacoonCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 211261 then--Ascendant Vis'coxria
		timerShadowyDecayCD:Start(3.6-delay, guid)--3.6-5.5
		timerAbyssalBlastCD:Start(13.3-delay, guid)--13.3-15.2
	elseif cid == 211263 then--Deathscreamer Iken'tak
		timerAbyssalBlastCD:Start(5.8-delay, guid)--5.8-6.8
		timerDarkOrbCD:Start(12.8-delay, guid)--12.8-13.1
	elseif cid == 211262 then--Ixkreten the Unbreakable
		timerAbyssalBlastCD:Start(2.4-delay, guid)--2.4-5
		timerTerrifyingSlamCD:Start(7.2-delay, guid)--7.2-9.9
--	elseif cid == 213932 then--Sureki Militant (players often don't pull this)
--		timerSilkenShellCD:Start(18.4, guid)
	elseif cid == 214761 then--Nightfall Ritualist
--		timerTormentingRayCD:Start(1.4, guid)--0.1-1.8
		timerStygianSeedCD:Start(9.2-delay, guid)--9.2-11.3
	elseif cid == 213934 then--Nightfall Tactician
		timerBlackEdgeCD:Start(3.2-delay, guid)--3.2-6.2
		timerTacticiansRageCD:Start(7.4-delay, guid)--7.4-11.7
	elseif cid == 211341 then--Manifested Shadow
		timerBlackHailCD:Start(5.3-delay, guid)--5.3-8.8
		timerDarkFloesCD:Start(40-delay, guid)--Quite consistent
--	elseif cid == 213893 or cid == 228539 then--Nightfall Darkcaster
--		timerUmbrelBarrierCD:Start(8.6-delay, guid)--8.6-17 (first cast not likley timer based but health threshold based)
--	elseif cid == 213895 or cid == 228537 then--Nightfall Shadowalker
--		timerUmbrelRushCD:Start(9.1-delay, guid)--Used instantly on engage
	elseif cid == 214762 then--Nightfall Commander
		timerAbyssalHowlCD:Start(6.5-delay, guid)--6.5-10.0
	elseif cid == 213885 then--Nightfall Dark Architect
		timerTorentingEruptionCD:Start(5.4-delay, guid)--5.4-5.9
	elseif cid == 213892 or cid == 228540 then--Nightfall Shadowmage (223994 is an RP mage, not engaged)
		timerEnsnaringShadowsCD:Start(cid == 228540 and (10.8-delay) or (8.0-delay), guid)--8.0-12.9 (213892) 10.8-14 (228540)
	elseif cid == 210966 then--Sureki Webmage
		timerBurstingCacoonCD:Start(1.8-delay, guid)--1.8-11.7
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
