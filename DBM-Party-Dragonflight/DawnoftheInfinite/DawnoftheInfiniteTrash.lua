local mod	= DBM:NewMod("DawnoftheInfiniteTrash", "DBM-Party-Dragonflight", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(2579)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 415770 413487 415435 415437 413529 413621 413622 412806 411958 412505 400165 413607 412136 413024 413023 412922 417481 419327 412378 412262 412233 412200 413427 407205 407535 419351 413544 412215 418200 411300 407891 415769 415436 412156",
	"SPELL_CAST_SUCCESS 411994 412012 418435",
	"SPELL_AURA_APPLIED 412063 415554 415437 413547",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
--	"GOSSIP_SHOW"
)

--[[

--]]
--TODO, mod should add line separators and actually separate abilities by which half of instance it is for cleaner order
--TODO, add https://www.wowhead.com/ptr-2/spell=411952/millennium-aid ?
--TODO, electro Juiced Gigablast timer still needs data
--TODO, Healing wave timer
local warnTemposlice						= mod:NewSpellAnnounce(412012, 3, nil, nil, nil, nil, nil, 3)--High Prio Stun
local warnElectroJuicedGigablast			= mod:NewCastAnnounce(412200, 3, nil, nil, nil, nil, nil, 3)--High Prio Stun
local warnInfiniteSchism					= mod:NewCastAnnounce(419327, 3)--, nil, nil, nil, nil, nil, 3
local warnDeployGoblinSappers				= mod:NewCastAnnounce(407535, 3, nil, nil, nil, nil, nil, 3)
local warnTripleStrike						= mod:NewCastAnnounce(413487, 3, nil, nil, "Tank")
local warnRendingCleave						= mod:NewCastAnnounce(412505, 3, nil, nil, "Tank")--High Prio
local warnTitanicBulwark					= mod:NewCastAnnounce(413024, 3, nil, nil, "Tank")
local warnStatickyPunch						= mod:NewCastAnnounce(412262, 3, nil, nil, "Tank")
local warnBloom								= mod:NewCastAnnounce(413544, 3)
local warnCorrodingVolley					= mod:NewCastAnnounce(413607, 4)--High Prio Off Interrupt
local warnEnervateKick						= mod:NewCastAnnounce(415437, 4)--High Prio Off Interrupt
local warnInfiniteBoltVolley				= mod:NewCastAnnounce(415770, 4)--High Prio Off Interrupt
local warnDisplacedChronosequence			= mod:NewCastAnnounce(417481, 4)--High Prio Off Interrupt
local warnInfiniteBurn						= mod:NewCastAnnounce(418200, 4)--High Prio Off Interrupt
local warnFishBoltVolley					= mod:NewCastAnnounce(411300, 4)--High Prio Off Interrupt
local warnDizzyingSands						= mod:NewCastAnnounce(412378, 4)--High Prio Off Interrupt
local warnRocketBoltVolley					= mod:NewCastAnnounce(412233, 4)--High Prio Off Interrupt
local warnHealingWave						= mod:NewCastAnnounce(407891, 4)--High Prio Off Interrupt
local warnEnervate							= mod:NewTargetAnnounce(415437, 3)

local specWarnInfiniteFury					= mod:NewSpecialWarningSpell(413622, nil, nil, nil, 2, 2)
local specWarnAncientRadiance				= mod:NewSpecialWarningSpell(413023, nil, nil, nil, 2, 2)
local specWarnTemporalStrike				= mod:NewSpecialWarningDodge(412136, nil, nil, nil, 2, 2)
local specWarnTimerip						= mod:NewSpecialWarningDodge(412063, nil, nil, nil, 2, 2)
local specWarnUntwist						= mod:NewSpecialWarningDodge(413529, nil, nil, nil, 2, 2)
local specWarnTimelessCurse					= mod:NewSpecialWarningDodge(413621, nil, nil, nil, 2, 2)
local specWarnBlightSpew					= mod:NewSpecialWarningDodge(412806, nil, nil, nil, 2, 2)
local specWarnOrbofContemplation			= mod:NewSpecialWarningDodge(412129, nil, nil, nil, 2, 2)--High Prio
local yellOrbofContemplation				= mod:NewShortYell(412129)--targets off a player, but everyone needs to dodge the orb
--local specWarnElectroJuicedGigablast		= mod:NewSpecialWarningDodge(412200, nil, nil, nil, 2, 2)
local specWarnVolatileMortar				= mod:NewSpecialWarningDodge(407205, nil, nil, nil, 2, 2)
local specWarnBronzeExhalation				= mod:NewSpecialWarningDodge(419351, nil, nil, nil, 2, 2)--High Prio
local specWarnShroudingSandstorm			= mod:NewSpecialWarningDodge(412215, nil, nil, nil, 2, 2)--High Prio
local specWarnBombingRun					= mod:NewSpecialWarningDodge(412156, nil, nil, nil, 2, 2)
local specWarnEnervateYou					= mod:NewSpecialWarningMoveAway(415437, nil, nil, nil, 1, 2)
local yellEnervate							= mod:NewShortYell(415437)
--local yellAstralBombFades					= mod:NewShortFadesYell(387843)
local specWarnChronoburst					= mod:NewSpecialWarningDispel(415769, "RemoveMagic", nil, nil, 1, 2)
local yellChronoburst						= mod:NewShortYell(415769)
local specWarnEnervateDispel				= mod:NewSpecialWarningDispel(415437, "RemoveMagic", nil, nil, 1, 2)
local specWarnBloom							= mod:NewSpecialWarningDispel(413544, "RemoveMagic", nil, nil, 1, 2)
local specWarnInfiniteBoltVolley			= mod:NewSpecialWarningInterrupt(415770, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnChronomelt					= mod:NewSpecialWarningInterrupt(411994, "HasInterrupt", nil, nil, 1, 2)
local specWarnInfiniteBolt					= mod:NewSpecialWarningInterrupt(415435, "HasInterrupt", nil, nil, 1, 2)
local specWarnEnervate						= mod:NewSpecialWarningInterrupt(415437, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnStonebolt						= mod:NewSpecialWarningInterrupt(411958, "HasInterrupt", nil, nil, 1, 2)
local specWarnCorrodingVolley				= mod:NewSpecialWarningInterrupt(413607, "HasInterrupt", nil, nil, 1, 2)
local specWarnEpochBolt						= mod:NewSpecialWarningInterrupt(400165, false, nil, 2, 1, 2)--Lower prio over Corroding Volley
local specWarnBindingGrasp					= mod:NewSpecialWarningInterrupt(412922, "HasInterrupt", nil, nil, 1, 2)
local specWarnDisplacedChronosequence		= mod:NewSpecialWarningInterrupt(417481, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnDizzyingSands					= mod:NewSpecialWarningInterrupt(412378, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnRocketBoltVolley				= mod:NewSpecialWarningInterrupt(412233, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnInfiniteBurn					= mod:NewSpecialWarningInterrupt(418200, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnFishBoltVolley				= mod:NewSpecialWarningInterrupt(411300, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnHealingWave					= mod:NewSpecialWarningInterrupt(407891, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnTimebeam						= mod:NewSpecialWarningInterrupt(413427, "HasInterrupt", nil, nil, 1, 2)

--First half
local timerChronomeltCD						= mod:NewCDNPTimer(18.2, 411994, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerTemposliceCD					= mod:NewCDNPTimer(21.8, 378003, nil, nil, nil, 5)--21-37, disabled for now
local timerChronoBurstCD					= mod:NewCDNPTimer(21.8, 415769, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerInfiniteBoltVolleyCD				= mod:NewCDNPTimer(13.3, 415770, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerTripleStrikeCD					= mod:NewCDNPTimer(12.1, 413487, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerTaintedSandsCD					= mod:NewCDNPTimer(13.3, 415436, nil, nil, nil, 3)
local timerEnervateCD						= mod:NewCDNPTimer(13.3, 415437, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBloomCD							= mod:NewCDNPTimer(18.2, 413544, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerUntwistCD						= mod:NewCDNPTimer(13.3, 413529, nil, nil, nil, 3)
local timerTimelessCurseCD					= mod:NewCDNPTimer(14.6, 413621, nil, nil, nil, 3)
local timerInfiniteFuryCD					= mod:NewCDNPTimer(19.8, 413622, nil, nil, nil, 2)
local timerBlightSpewCD						= mod:NewCDNPTimer(13.3, 412806, nil, nil, nil, 3)
local timerStoneboltCD						= mod:NewCDNPTimer(10.9, 411958, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--Second half
local timerRendingCleaveCD					= mod:NewCDNPTimer(8.4, 412505, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--10.5-13.3
local timerCorrodingVolleyCD				= mod:NewCDNPTimer(18.2, 413607, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerTemporalStrikeCD					= mod:NewCDNPTimer(11.2, 412136, nil, nil, nil, 2)--11.2-18
local timerTitanticBulwarkCD				= mod:NewCDNPTimer(25.4, 413024, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerAncientRadianceCD				= mod:NewCDNPTimer(10.5, 413023, nil, nil, nil, 2)--10.5-15
local timerOrbofContemplationCD				= mod:NewCDNPTimer(13.3, 412129, nil, nil, nil, 3)
local timerShroudingSandstormCD				= mod:NewCDNPTimer(23.1, 412215, nil, nil, nil, 2)--Updated Jan 23rd per hotfixes
local timerBindingGraspCD					= mod:NewCDNPTimer(19.4, 412922, nil, nil, nil, 3)
local timerDisplacedChronosequenceCD		= mod:NewCDNPTimer(16.1, 417481, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerInfiniteSchismCD					= mod:NewCDNPTimer(26.7, 419327, nil, nil, nil, 5)
local timerDizzyingSandsCD					= mod:NewCDNPTimer(16.1, 412378, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerStatickyPunchCD					= mod:NewCDNPTimer(12.1, 412262, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerRocketBoltVolleyCD				= mod:NewCDNPTimer(19.5, 412233, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Subpar data
local timerInfiniteBurnCD					= mod:NewCDNPTimer(13.3, 418200, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerElectroJuicedGigablastCD		= mod:NewCDNPTimer(26.7, 412200, nil, nil, nil, 5)--Insuffiicent Data, NYI
local timerBombingRunCD						= mod:NewCDNPTimer(17, 412156, nil, nil, nil, 3)
local timerTimeBeamCD						= mod:NewCDNPTimer(7.2, 413427, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerVolatileMortarCD					= mod:NewCDNPTimer(19.5, 407205, nil, nil, nil, 3)
local timerDeployGoblinSappersCD			= mod:NewCDNPTimer(30.3, 407535, nil, nil, nil, 5)--Poor data
local timerBronzeExhalationCD				= mod:NewCDNPTimer(19.8, 419351, nil, nil, nil, 3)
local timerFishBoltVolleyCD					= mod:NewCDNPTimer(10.4, 411300, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

local function additionalIds(self, args)
	local spellId = args.spellId
	if spellId == 407205 then
		timerVolatileMortarCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnVolatileMortar:Show()
			specWarnVolatileMortar:Play("watchstep")
		end
	elseif spellId == 407535 then
		timerDeployGoblinSappersCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnDeployGoblinSappers:Show()
			warnDeployGoblinSappers:Play("crowdcontrol")
		end
	elseif spellId == 419351 then
		local cid = self:GetCIDFromGUID(args.sourceGUID)
		if cid == 208438 then--Shorter CD (Infinite Saboteur)
			timerBronzeExhalationCD:Start(17, args.sourceGUID)
		else
			timerBronzeExhalationCD:Start(nil, args.sourceGUID)--20.6
		end
		if self:AntiSpam(3, 2) then
			specWarnBronzeExhalation:Show()
			specWarnBronzeExhalation:Play("breathsoon")
		end
	elseif spellId == 413544 then
		timerBloomCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnBloom:Show()
		end
	elseif spellId == 415769 then
		timerChronoBurstCD:Start(nil, args.sourceGUID)
	elseif spellId == 415436 then
		timerTaintedSandsCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 415770 then
		timerInfiniteBoltVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn415770interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnInfiniteBoltVolley:Show(args.sourceName)
			specWarnInfiniteBoltVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnInfiniteBoltVolley:Show()
		end
	elseif spellId == 418200 then
		timerInfiniteBurnCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn418200interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnInfiniteBurn:Show(args.sourceName)
			specWarnInfiniteBurn:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnInfiniteBurn:Show()
		end
	elseif spellId == 407891 then

		if self.Options.SpecWarn407891interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHealingWave:Show(args.sourceName)
			specWarnHealingWave:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHealingWave:Show()
		end
	elseif spellId == 411300 then
		timerFishBoltVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn411300interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFishBoltVolley:Show(args.sourceName)
			specWarnFishBoltVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnFishBoltVolley:Show()
		end
	elseif spellId == 413487 then
		timerTripleStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnTripleStrike:Show()
		end
	elseif spellId == 415435 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnInfiniteBolt:Show(args.sourceName)
			specWarnInfiniteBolt:Play("kickcast")
		end
	elseif spellId == 415437 then
		timerEnervateCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn415437interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnEnervate:Show(args.sourceName)
			specWarnEnervate:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnEnervateKick:Show()
		end
	elseif spellId == 413529 then
		timerUntwistCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnUntwist:Show()
			specWarnUntwist:Play("shockwave")
		end
	elseif spellId == 412215 then
		timerShroudingSandstormCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnShroudingSandstorm:Show()
			specWarnShroudingSandstorm:Play("chargemove")
		end
	elseif spellId == 413621 then
		timerTimelessCurseCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnTimelessCurse:Show()
			specWarnTimelessCurse:Play("watchstep")
		end
	elseif spellId == 412156 then
		timerBombingRunCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBombingRun:Show()
			specWarnBombingRun:Play("watchstep")
		end
	elseif spellId == 413622 then
		timerInfiniteFuryCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnInfiniteFury:Show()
			specWarnInfiniteFury:Play("aesoon")
		end
	elseif spellId == 412806 then
		timerBlightSpewCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBlightSpew:Show()
			specWarnBlightSpew:Play("watchstep")
		end
	elseif spellId == 411958 then
		timerStoneboltCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnStonebolt:Show(args.sourceName)
			specWarnStonebolt:Play("kickcast")
		end
	elseif spellId == 412505 then
		timerRendingCleaveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnRendingCleave:Show()
		end
	elseif spellId == 400165 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnEpochBolt:Show(args.sourceName)
			specWarnEpochBolt:Play("kickcast")
		end
	elseif spellId == 413607 then
		timerCorrodingVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn413607interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCorrodingVolley:Show(args.sourceName)
			specWarnCorrodingVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnCorrodingVolley:Show()
		end
	elseif spellId == 412136 then
		timerTemporalStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnTemporalStrike:Show()
			specWarnTemporalStrike:Play("watchstep")
		end
	elseif spellId == 413024 then
		timerTitanticBulwarkCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnTitanicBulwark:Show()
		end
	elseif spellId == 413023 then
		timerAncientRadianceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			specWarnAncientRadiance:Show()
			specWarnAncientRadiance:Play("aesoon")
		end
	elseif spellId == 412922 then
		timerBindingGraspCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBindingGrasp:Show(args.sourceName)
			specWarnBindingGrasp:Play("kickcast")
		end
	elseif spellId == 417481 then
		timerDisplacedChronosequenceCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn417481interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDisplacedChronosequence:Show(args.sourceName)
			specWarnDisplacedChronosequence:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDisplacedChronosequence:Show()
		end
	elseif spellId == 419327 then
		timerInfiniteSchismCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnInfiniteSchism:Show()
--			warnInfiniteSchism:Play("crowdcontrol")
		end
	elseif spellId == 412378 then
		timerDizzyingSandsCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn412378interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDizzyingSands:Show(args.sourceName)
			specWarnDizzyingSands:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDizzyingSands:Show()
		end
	elseif spellId == 412262 then
		timerStatickyPunchCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnStatickyPunch:Show()
		end
	elseif spellId == 412233 then
		timerRocketBoltVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn412233interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRocketBoltVolley:Show(args.sourceName)
			specWarnRocketBoltVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnRocketBoltVolley:Show()
		end
	elseif spellId == 412200 then
		if self:AntiSpam(3, 6) then
			warnElectroJuicedGigablast:Show()
			warnElectroJuicedGigablast:Play("crowdcontrol")
		end
	elseif spellId == 413427 then
		timerTimeBeamCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTimebeam:Show(args.sourceName)
			specWarnTimebeam:Play("kickcast")
		end
	else--Out of upvalues, goes over 60 below here
		additionalIds(self, args)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 411994 then
		timerChronomeltCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnChronomelt:Show(args.sourceName)
			specWarnChronomelt:Play("kickcast")
		end
	elseif spellId == 412012 then
--		timerHailofStoneCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnTemposlice:Show()
			warnTemposlice:Play("crowdcontrol")
		end
	elseif spellId == 418435 then
		timerOrbofContemplationCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnOrbofContemplation:Show()
			specWarnOrbofContemplation:Play("watchorb")
		end
		if args:IsPlayer() then
			yellOrbofContemplation:Yell()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 412063 and self:AntiSpam(3, 2) then
		specWarnTimerip:Show()
		specWarnTimerip:Play("watchstep")
	elseif spellId == 415554 and args:IsDestTypePlayer() then
		if args:IsPlayer() then
			yellChronoburst:Yell()
		end
		--Multi target, unknown target cap, but one dispel warning is still enough to get message across
		if self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnChronoburst:Show(args.destName)
			specWarnChronoburst:Play("helpdispel")
		end
	elseif spellId == 415437 then
--		warnViciousAmbush:Show(args.destName)
		if self.Options.SpecWarn415437dispel and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnEnervateDispel:Show(args.destName)
			specWarnEnervateDispel:Play("helpdispel")
		elseif args:IsPlayer() then
			specWarnEnervateYou:Show()
			specWarnEnervateYou:Play("targetyou")
			yellEnervate:Yell()
		else
			warnEnervate:Show(args.destName)
		end
	elseif spellId == 413547 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
		specWarnBloom:Show(args.destName)
		specWarnBloom:Play("helpdispel")
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	--First half mobs
	if cid == 205384 then--infinite-chronoweaver
		timerChronomeltCD:Stop(args.destGUID)
--	elseif cid == 205408 then--infinite-timeslicer
		--Temposlice
--	elseif cid == 205435 then--epoch-ripper
		--Timerip (too varaible)
	elseif cid == 206140 then--coalesced-time
		timerChronoBurstCD:Stop(args.destGUID)
		timerInfiniteBoltVolleyCD:Stop(args.destGUID)
	elseif cid == 206068 then--temporal-fusion
		timerTripleStrikeCD:Stop(args.destGUID)
	elseif cid == 206064 then--Coalesced Moment
		timerTaintedSandsCD:Stop(args.destGUID)
	elseif cid == 206066 then--Timestream Leech
		timerEnervateCD:Stop(args.destGUID)
	elseif cid == 199749 then--Timestream Anomaly
		timerBloomCD:Stop(args.destGUID)
		timerUntwistCD:Stop(args.destGUID)
	elseif cid == 206214 then--Infinite Infiltrator
		timerTimelessCurseCD:Stop(args.destGUID)
		timerInfiniteFuryCD:Stop(args.destGUID)
	elseif cid == 205804 then--Risen Dragon
		timerBlightSpewCD:Stop(args.destGUID)
	elseif cid == 205691 then--Iridikron's Creation
		timerStoneboltCD:Stop(args.destGUID)
	--Mobs below here are second half
	elseif cid == 205151 then--tyrs-vanguard
		timerRendingCleaveCD:Stop(args.destGUID)
	elseif cid == 201223 then--Infinite Twilight Magus
		timerCorrodingVolleyCD:Stop(args.destGUID)
	elseif cid == 201222 then--Valow, Timesworn Keeper
		timerTemporalStrikeCD:Stop(args.destGUID)
		timerTitanticBulwarkCD:Stop(args.destGUID)
	elseif cid == 413023 then--Lerai, Timesworn Maiden
		timerAncientRadianceCD:Stop(args.destGUID)
		timerOrbofContemplationCD:Stop(args.destGUID)
	elseif cid == 412922 then--Binding Grasp
		timerBindingGraspCD:Stop(args.destGUID)
		timerShroudingSandstormCD:Stop(args.destGUID)
	elseif cid == 207177 then--Infinite Watchkeeper
		timerTimelessCurseCD:Stop(args.destGUID)
		timerInfiniteFuryCD:Stop(args.destGUID)
	elseif cid == 199748 then--Timeline Marauder
		timerDisplacedChronosequenceCD:Stop(args.destGUID)
		timerInfiniteSchismCD:Stop(args.destGUID)
	elseif cid == 205337 then--Infinite Timebender
		timerDizzyingSandsCD:Stop(args.destGUID)
	elseif cid == 205727 then--Time-Lost Rocketeer
		timerStatickyPunchCD:Stop(args.destGUID)
		timerRocketBoltVolleyCD:Stop(args.destGUID)
	elseif cid == 205723 then--Time-Lost Aerobot
		timerBombingRunCD:Stop(args.destGUID)
	elseif cid == 206074 then--Pendule
		timerTimeBeamCD:Stop(args.destGUID)
	elseif cid == 203861 then--horde-destroyer
		timerVolatileMortarCD:Stop(args.destGUID)
		timerDeployGoblinSappersCD:Stop(args.destGUID)
	elseif cid == 208440 then--Infinite Slayer
		timerInfiniteFuryCD:Stop(args.destGUID)
		timerTimelessCurseCD:Stop(args.destGUID)--Not seen, but wowhead says it's there, so it's here
		timerBronzeExhalationCD:Stop(args.destGUID)
	elseif cid == 206230 then--Infinite Diversionist
		timerTimelessCurseCD:Stop(args.destGUID)
		timerBronzeExhalationCD:Stop(args.destGUID)
	elseif cid == 208438 then--Infinite Saboteur
		timerBronzeExhalationCD:Stop(args.destGUID)
	elseif cid == 205363 then--Time Lost Waveshaper
		timerFishBoltVolleyCD:Stop(args.destGUID)
	elseif cid == 208698 then--Infinite Riftmage
		timerInfiniteBurnCD:Stop(args.destGUID)
	end
end

--[[
function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		--Black, Bronze, Blue, Red, Green
		if self.Options.AGBuffs and (gossipOptionID == 107065 or gossipOptionID == 107081 or gossipOptionID == 107082 or gossipOptionID == 107088 or gossipOptionID == 107083) then -- Buffs
			self:SelectGossip(gossipOptionID)
		end
	end
end
--]]
