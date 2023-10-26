local mod	= DBM:NewMod("DawnoftheInfiniteTrash", "DBM-Party-Dragonflight", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(2579)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 415770 413487 415435 415437 413529 413621 413622 412806 411958 412505 400165 413607 412136 413024 413023 412922 417481 419327 412378 412262 412233 412200 413427 407205 407535 419351 413544",
	"SPELL_CAST_SUCCESS 411994 412012 418435",
	"SPELL_AURA_APPLIED 412063 415554 415437 413547"--415436
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"UNIT_DIED",
--	"GOSSIP_SHOW"
)

--[[
(ability.id = 415770 or ability.id = 413487 or ability.id = 415435 or ability.id = 415437 or ability.id = 413529 or ability.id = 413621 or ability.id = 413622 or ability.id = 412806 or ability.id = 411958 or ability.id = 412505 or ability.id = 400165 or ability.id = 413607 or ability.id = 412136 or ability.id = 413024 or ability.id = 413023 or ability.id = 412922 or ability.id = 417481 or ability.id = 419327 or ability.id = 412378 or ability.id = 412262 or ability.id = 412233 or ability.id = 412200 or ability.id = 413427 or ability.id = 407205 or ability.id = 407535 or ability.id = 419351 ability.id = 415769 or ability.id = 415436 or ability.id = 413544) and type = "begincast"
 or (411994 412012 418435) and type = "cast"
 or ability.id = 412063
--]]
--TODO, 407535 might be wrong for sappers, didn't get a log of this one
local warnTemposlice						= mod:NewSpellAnnounce(412012, 3, nil, nil, nil, nil, nil, 3)
local warnInfiniteBoltVolley				= mod:NewCastAnnounce(415770, 3)
local warnCorrodingVolley					= mod:NewCastAnnounce(413607, 3, nil, nil, nil, nil, nil, 3)
local warnInfiniteSchism					= mod:NewCastAnnounce(419327, 3, nil, nil, nil, nil, nil, 3)
local warnDeployGoblinSappers				= mod:NewCastAnnounce(407535, 3, nil, nil, nil, nil, nil, 3)
local warnTripleStrike						= mod:NewCastAnnounce(413487, 3, nil, nil, "Tank")
local warnRendingCleave						= mod:NewCastAnnounce(412505, 3, nil, nil, "Tank")
local warnTitanicBulwark					= mod:NewCastAnnounce(413024, 3, nil, nil, "Tank")
local warnStatickyPunch						= mod:NewCastAnnounce(412262, 3, nil, nil, "Tank")
local warnBloom								= mod:NewCastAnnounce(413544, 3)
local warnEnervate							= mod:NewTargetAnnounce(415437, 3)

local specWarnInfiniteFury					= mod:NewSpecialWarningSpell(413622, nil, nil, nil, 2, 2)
local specWarnAncientRadiance				= mod:NewSpecialWarningSpell(413023, nil, nil, nil, 2, 2)
local specWarnTimerip						= mod:NewSpecialWarningDodge(412063, nil, nil, nil, 2, 2)
local specWarnUntwist						= mod:NewSpecialWarningDodge(413529, nil, nil, nil, 2, 2)
local specWarnTimelessCurse					= mod:NewSpecialWarningDodge(413621, nil, nil, nil, 2, 2)
local specWarnBlightSpew					= mod:NewSpecialWarningDodge(412806, nil, nil, nil, 2, 2)
local specWarnTemporalStrike				= mod:NewSpecialWarningDodge(412136, nil, nil, nil, 2, 2)
local specWarnOrbofContemplation			= mod:NewSpecialWarningDodge(412129, nil, nil, nil, 2, 2)
local yellOrbofContemplation				= mod:NewShortYell(412129)--targets off a player, but everyone needs to dodge the orb
local specWarnElectroJuicedGigablast		= mod:NewSpecialWarningDodge(412200, nil, nil, nil, 2, 2)
local specWarnVolatileMortar				= mod:NewSpecialWarningDodge(407205, nil, nil, nil, 2, 2)
local specWarnBronzeExhalation				= mod:NewSpecialWarningDodge(419351, nil, nil, nil, 2, 2)
local specWarnEnervateYou					= mod:NewSpecialWarningMoveAway(415437, nil, nil, nil, 1, 2)
local yellEnervate							= mod:NewShortYell(415437)
--local yellAstralBombFades					= mod:NewShortFadesYell(387843)
local specWarnChronoburst					= mod:NewSpecialWarningDispel(415769, "RemoveMagic", nil, nil, 1, 2)
local yellChronoburst						= mod:NewShortYell(415769)
--local specWarnTaintedSands				= mod:NewSpecialWarningDispel(415436, "RemoveMagic", nil, nil, 1, 2)
local specWarnEnervateDispel				= mod:NewSpecialWarningDispel(415437, "RemoveMagic", nil, nil, 1, 2)
local specWarnBloom							= mod:NewSpecialWarningDispel(413544, "RemoveMagic", nil, nil, 1, 2)
local specWarnInfiniteBoltVolley			= mod:NewSpecialWarningInterrupt(415770, "HasInterrupt", nil, nil, 1, 2)
local specWarnChronomelt					= mod:NewSpecialWarningInterrupt(411994, "HasInterrupt", nil, nil, 1, 2)
local specWarnInfiniteBolt					= mod:NewSpecialWarningInterrupt(415435, "HasInterrupt", nil, nil, 1, 2)
local specWarnEnervate						= mod:NewSpecialWarningInterrupt(415437, "HasInterrupt", nil, nil, 1, 2)
local specWarnStonebolt						= mod:NewSpecialWarningInterrupt(411958, "HasInterrupt", nil, nil, 1, 2)
local specWarnEpochBolt						= mod:NewSpecialWarningInterrupt(400165, "HasInterrupt", nil, nil, 1, 2)
local specWarnBindingGrasp					= mod:NewSpecialWarningInterrupt(412922, "HasInterrupt", nil, nil, 1, 2)
local specWarnDisplacedChronosequence		= mod:NewSpecialWarningInterrupt(417481, "HasInterrupt", nil, nil, 1, 2)
local specWarnDizzyingSands					= mod:NewSpecialWarningInterrupt(412378, "HasInterrupt", nil, nil, 1, 2)
local specWarnRocketBoltVolley				= mod:NewSpecialWarningInterrupt(412233, "HasInterrupt", nil, nil, 1, 2)
local specWarnTimebeam						= mod:NewSpecialWarningInterrupt(413427, "HasInterrupt", nil, nil, 1, 2)
--
--local timerInfiniteBoltVolleyCD				= mod:NewCDNPTimer(36, 415770, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerDeadlyWindsCD						= mod:NewCDNPTimer(10.9, 378003, nil, nil, nil, 3)

--mod:AddBoolOption("AGBuffs", true)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt


function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 415770 then
--		timerInfiniteBoltVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn415770interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnInfiniteBoltVolley:Show(args.sourceName)
			specWarnInfiniteBoltVolley:Play("kickcast")
		elseif self:AntiSpam(2, 7) then
			warnInfiniteBoltVolley:Show()
		end
	elseif spellId == 413487 and self:AntiSpam(2, 5) then
		warnTripleStrike:Show()
	elseif spellId == 415435 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnInfiniteBolt:Show(args.sourceName)
		specWarnInfiniteBolt:Play("kickcast")
	elseif spellId == 415437 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnEnervate:Show(args.sourceName)
		specWarnEnervate:Play("kickcast")
	elseif spellId == 413529 and self:AntiSpam(2, 2) then
		specWarnUntwist:Show()
		specWarnUntwist:Play("shockwave")
	elseif spellId == 413621 and self:AntiSpam(3, 2) then
		specWarnTimelessCurse:Show()
		specWarnTimelessCurse:Play("watchstep")
	elseif spellId == 413622 and self:AntiSpam(2, 4) then
		specWarnInfiniteFury:Show()
		specWarnInfiniteFury:Play("aesoon")
	elseif spellId == 412806 and self:AntiSpam(3, 2) then
		specWarnBlightSpew:Show()
		specWarnBlightSpew:Play("watchstep")
	elseif spellId == 411958 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnStonebolt:Show(args.sourceName)
		specWarnStonebolt:Play("kickcast")
	elseif spellId == 412505 and self:AntiSpam(2, 5) then
		warnRendingCleave:Show()
	elseif spellId == 400165 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnEpochBolt:Show(args.sourceName)
		specWarnEpochBolt:Play("kickcast")
	elseif spellId == 413607 and self:AntiSpam(3, 6) then
		warnCorrodingVolley:Show()
		warnCorrodingVolley:Play("crowdcontrol")
	elseif spellId == 412136 and self:AntiSpam(3, 2) then
		specWarnTemporalStrike:Show()
		specWarnTemporalStrike:Play("watchstep")
	elseif spellId == 413024 and self:AntiSpam(2, 5) then
		warnTitanicBulwark:Show()
	elseif spellId == 413023 and self:AntiSpam(2, 4) then
		specWarnAncientRadiance:Show()
		specWarnAncientRadiance:Play("aesoon")
	elseif spellId == 412922 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBindingGrasp:Show(args.sourceName)
		specWarnBindingGrasp:Play("kickcast")
	elseif spellId == 417481 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDisplacedChronosequence:Show(args.sourceName)
		specWarnDisplacedChronosequence:Play("kickcast")
	elseif spellId == 419327 and self:AntiSpam(3, 6) then
		warnInfiniteSchism:Show()
		warnInfiniteSchism:Play("crowdcontrol")
	elseif spellId == 412378 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDizzyingSands:Show(args.sourceName)
		specWarnDizzyingSands:Play("kickcast")
	elseif spellId == 412262 and self:AntiSpam(2, 5) then
		warnStatickyPunch:Show()
	elseif spellId == 412233 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnRocketBoltVolley:Show(args.sourceName)
		specWarnRocketBoltVolley:Play("kickcast")
	elseif spellId == 412200 and self:AntiSpam(2, 2) then
		specWarnElectroJuicedGigablast:Show()
		specWarnElectroJuicedGigablast:Play("shockwave")
	elseif spellId == 413427 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnTimebeam:Show(args.sourceName)
		specWarnTimebeam:Play("kickcast")
	elseif spellId == 407205 and self:AntiSpam(3, 2) then
		specWarnVolatileMortar:Show()
		specWarnVolatileMortar:Play("watchstep")
	elseif spellId == 407535 and self:AntiSpam(3, 6) then
		warnDeployGoblinSappers:Show()
		warnDeployGoblinSappers:Play("crowdcontrol")
	elseif spellId == 419351 and self:AntiSpam(3, 2) then
		specWarnBronzeExhalation:Show()
		specWarnBronzeExhalation:Play("breathsoon")
	elseif spellId == 413544 and self:AntiSpam(2, 5) then
		warnBloom:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 411994 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnChronomelt:Show(args.sourceName)
		specWarnChronomelt:Play("kickcast")
	elseif spellId == 412012 then
--		timerHailofStoneCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnTemposlice:Show()
			warnTemposlice:Play("crowdcontrol")
		end
	elseif spellId == 418435 then
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
--	elseif spellId == 415436 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
--		specWarnTaintedSands:Show(args.destName)
--		specWarnTaintedSands:Play("helpdispel")
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
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 387843 and args:IsPlayer() then

	end
end
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 196044 then
		timerMonotonousLectureCD:Stop(args.destGUID)
	end
end
--]]

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
