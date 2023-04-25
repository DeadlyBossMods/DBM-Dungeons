local mod	= DBM:NewMod("HallsofInfusionTrash", "DBM-Party-Dragonflight", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 390290 374080 375351 375348 375327 375384 374563 374045 374339 374066 374020 395694 374699 374706 375079 374823 385141 377341 377402",
	"SPELL_AURA_APPLIED 374724 374615 391610 391613 377384 377402",
	"SPELL_AURA_APPLIED_DOSE 374389",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"GOSSIP_SHOW"
)

--NOTE: A lot of this is drycoded off of https://www.wowhead.com/guide/dungeons/halls-of-infusion-strategy and subject to needed adjustments/corrections
--TODO, who does dazzle target? just the tank, everyone?
--TODO, should rumbling earth be a dodge or interrupt?
--TODO, tweak thunderstorm alert sound/text?
--TODO, https://www.wowhead.com/spell=376171/refreshing-tides ? it's not in guide, and has no tooltip, is it even still used?
--[[
(ability.id = 390290 or ability.id = 374080 or ability.id = 375351 or ability.id = 375348 or ability.id = 375327 or ability.id = 375384 or ability.id = 374563 or ability.id = 374045 or ability.id = 374339 or ability.id = 374066 or ability.id = 374020 or ability.id = 395694 or ability.id = 374699 or ability.id = 374706 or ability.id = 375079 or ability.id = 374823 or ability.id = 385141 or ability.id = 377341 or ability.id = 377402) and type = "begincast"
 or ability.id = 374724 and type = "applydebuff"
--]]
local warnBlastingGust						= mod:NewCastAnnounce(374080, 4)
local warnContainmentBeam					= mod:NewCastAnnounce(374020, 2, nil, nil, false)--Can be spammy, it's kind of sort of a passive constant cast of these mobs, so opt in
local warnExpulse							= mod:NewCastAnnounce(374045, 3)
local warnDemoralizingShout					= mod:NewCastAnnounce(374339, 2)
local warnElementalFocus					= mod:NewCastAnnounce(395694, 4)
local warnCauterize							= mod:NewCastAnnounce(374699, 3)--20.6?
local warnWhirlingFury						= mod:NewCastAnnounce(375079, 3)
local warnZephyrsCall						= mod:NewCastAnnounce(374823, 2)
local warnTidalDivergence					= mod:NewCastAnnounce(377341, 3)
local warnAqueousBarrier					= mod:NewCastAnnounce(377402, 4)
local warnCheapShot							= mod:NewTargetNoFilterAnnounce(374615, 4)
local warnMoltenSubduction					= mod:NewTargetNoFilterAnnounce(374724, 3)

local specWarnGulpSwogToxin					= mod:NewSpecialWarningStack(374389, nil, 8, nil, nil, 1, 6)
local specWarnOceanicBreath					= mod:NewSpecialWarningDodge(375351, nil, nil, nil, 2, 2)
local specWarnGustingBreath					= mod:NewSpecialWarningDodge(375348, nil, nil, nil, 2, 2)
local specWarnTectonicBreath				= mod:NewSpecialWarningDodge(375327, nil, nil, nil, 2, 2)
local specWarnRumblingEarth					= mod:NewSpecialWarningDodge(375384, nil, nil, nil, 2, 2)
local specWarnDazzle						= mod:NewSpecialWarningDodge(374563, nil, nil, nil, 2, 2)
local specWarnFlashFlood					= mod:NewSpecialWarningDodge(390290, nil, nil, nil, 3, 2)
local specWarnThunderstorm					= mod:NewSpecialWarningYou(385141, nil, nil, nil, 1, 2)
local specWarnCreepingMold					= mod:NewSpecialWarningYou(391613, nil, nil, nil, 2, 2)
local specWarnCreepingMoldDispel			= mod:NewSpecialWarningDispel(391613, "RemoveDisease", nil, nil, 1, 2)
local specWarnBindingWinds					= mod:NewSpecialWarningDispel(391610, "RemoveMagic", nil, nil, 1, 2)
local specWarnBoilingRage					= mod:NewSpecialWarningDispel(377384, "RemoveEnrage", nil, nil, 1, 2)
local specWarnAqueousBarrierDispel			= mod:NewSpecialWarningDispel(377402, "MagicDispeller", nil, nil, 1, 2)
local yellThunderstorm						= mod:NewYell(385141)
--local yellConcentrateAnimaFades				= mod:NewShortFadesYell(339525)
local specWarnBlastingGust					= mod:NewSpecialWarningInterrupt(374080, "HasInterrupt", nil, nil, 1, 2)
local specWarnExpulse						= mod:NewSpecialWarningInterrupt(374045, "HasInterrupt", nil, nil, 1, 2)
local specWarnDemoShout						= mod:NewSpecialWarningInterrupt(374339, "HasInterrupt", nil, nil, 1, 2)
local specWarnEarthShield					= mod:NewSpecialWarningInterrupt(374066, "HasInterrupt", nil, nil, 1, 2)
local specWarnElementalFocus				= mod:NewSpecialWarningInterrupt(395694, "HasInterrupt", nil, nil, 1, 2)
local specWarnCauterize						= mod:NewSpecialWarningInterrupt(374699, "HasInterrupt", nil, nil, 1, 2)
local specWarnPyreticBurst					= mod:NewSpecialWarningInterrupt(374706, false, nil, nil, 1, 2)
local specWarnTidalDivergence				= mod:NewSpecialWarningInterrupt(377341, "HasInterrupt", nil, nil, 1, 2)
local specWarnAqueousBarrier				= mod:NewSpecialWarningInterrupt(377402, "HasInterrupt", nil, nil, 1, 2)

local timerDemoShoutCD						= mod:NewCDTimer(30, 374339, nil, nil, nil, 2)
local timerDazzleCD							= mod:NewCDTimer(18.1, 374563, nil, nil, nil, 3)
local timerZephyrsCallCD					= mod:NewCDTimer(23.1, 374823, nil, nil, nil, 1)
local timerWhirlingFuryCD					= mod:NewCDTimer(19, 375079, nil, nil, nil, 2)
local timerMoltenSubductionCD				= mod:NewCDTimer(25, 374724, nil, nil, nil, 3)
local timerOceanicBreathCD					= mod:NewCDTimer(18.1, 375351, nil, nil, nil, 3)
local timerGustingBreathCD					= mod:NewCDTimer(19.3, 375348, nil, nil, nil, 3)--Could also be 18.1, but need bigger sample
local timerTectonicBreathCD					= mod:NewCDTimer(18.1, 375327, nil, nil, nil, 3)
local timerThunderstormCD					= mod:NewCDTimer(19.4, 385141, nil, nil, nil, 3)
local timerAqueousBarrierCD					= mod:NewCDTimer(17.3, 377402, nil, nil, nil, 5)
local timerFlashFloodCD						= mod:NewCDTimer(23, 390290, nil, nil, nil, 2)

mod:AddBoolOption("AGBuffs", true)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:ThunderstormTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnThunderstorm:Show()
		specWarnThunderstorm:Play("targetyou")
		yellThunderstorm:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 390290 then
		timerFlashFloodCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			specWarnFlashFlood:Show()
			specWarnFlashFlood:Play("justrun")
			specWarnFlashFlood:ScheduleVoice(1.2, "carefly")
		end
	elseif spellId == 374080 then
		if self.Options.SpecWarn374080interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBlastingGust:Show(args.sourceName)
			specWarnBlastingGust:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBlastingGust:Show()
		end
	elseif spellId == 374045 then
		if self.Options.SpecWarn374045interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnExpulse:Show(args.sourceName)
			specWarnExpulse:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnExpulse:Show()
		end
	elseif spellId == 374339 then
		timerDemoShoutCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn374339interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDemoShout:Show(args.sourceName)
			specWarnDemoShout:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDemoralizingShout:Show()
		end
	elseif spellId == 374066 then
		if self.Options.SpecWarn374066interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnEarthShield:Show(args.sourceName)
			specWarnEarthShield:Play("kickcast")
--		elseif self:AntiSpam(3, 7) then
--			warnDemoralizingShout:Show()
		end
	elseif spellId == 395694 then
		if self.Options.SpecWarn395694interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnElementalFocus:Show(args.sourceName)
			specWarnElementalFocus:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnElementalFocus:Show()
		end
	elseif spellId == 374699 then
		if self.Options.SpecWarn374699interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCauterize:Show(args.sourceName)
			specWarnCauterize:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnCauterize:Show()
		end
	elseif spellId == 374706 then
		if self.Options.SpecWarn374706interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPyreticBurst:Show(args.sourceName)
			specWarnPyreticBurst:Play("kickcast")
--		elseif self:AntiSpam(3, 7) then
--			warnDemoralizingShout:Show()
		end
	elseif spellId == 377341 then
		if self.Options.SpecWarn377341interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTidalDivergence:Show(args.sourceName)
			specWarnTidalDivergence:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnTidalDivergence:Show()
		end
	elseif spellId == 377402 then
		timerAqueousBarrierCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn377402interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnAqueousBarrier:Show(args.sourceName)
			specWarnAqueousBarrier:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnAqueousBarrier:Show()
		end
	elseif spellId == 374020 and self:AntiSpam(3, 6) then
		warnContainmentBeam:Show()
	elseif spellId == 375351 then
		timerOceanicBreathCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnOceanicBreath:Show()
			specWarnOceanicBreath:Play("breathsoon")
		end
	elseif spellId == 375348 then
		timerGustingBreathCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnGustingBreath:Show()
			specWarnGustingBreath:Play("breathsoon")
		end
	elseif spellId == 375327 then
		timerTectonicBreathCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnTectonicBreath:Show()
			specWarnTectonicBreath:Play("breathsoon")
		end
	elseif spellId == 375384 and self:AntiSpam(3, 2) then
		specWarnRumblingEarth:Show()
		specWarnRumblingEarth:Play("watchstep")
	elseif spellId == 374563 then
		timerDazzleCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDazzle:Show()
			specWarnDazzle:Play("shockwave")
		end
	elseif spellId == 375079 then
		timerWhirlingFuryCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnWhirlingFury:Show()
		end
	elseif spellId == 374823 then
		timerZephyrsCallCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnZephyrsCall:Show()
		end
	elseif spellId == 385141 then
		timerThunderstormCD:Start(nil, args.sourceGUID)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ThunderstormTarget", 0.1, 8)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 374389 and args:IsPlayer()then
		local amount = args.amount or 1
		if amount >= 8 and self:AntiSpam(3, 5) then
			specWarnGulpSwogToxin:Show(amount)
			specWarnGulpSwogToxin:Play("stackhigh")
		end
	elseif spellId == 374724 then
		warnMoltenSubduction:Show(args.destName)
		timerMoltenSubductionCD:Start(nil, args.sourceGUID)
	elseif spellId == 374615 then
		warnCheapShot:Show(args.destName)
	elseif spellId == 391610 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
		specWarnBindingWinds:Show(args.destName)
		specWarnBindingWinds:Play("helpdispel")
	elseif spellId == 391613 then
		if args:IsPlayer() then
			specWarnCreepingMold:Show()
			specWarnCreepingMold:Play("targetyou")
		elseif self:CheckDispelFilter("disease") and self:AntiSpam(3, 3) then
			specWarnCreepingMoldDispel:Show(args.destName)
			specWarnCreepingMoldDispel:Play("helpdispel")
		end
	elseif spellId == 377384 and self:AntiSpam(3, 3) then
		specWarnBoilingRage:Show(args.destName)
		specWarnBoilingRage:Play("enrage")
	elseif spellId == 377402 and self:AntiSpam(3, 3) then
		specWarnAqueousBarrierDispel:Show(args.destName)
		specWarnAqueousBarrierDispel:Play("helpdispel")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 339525 and args:IsPlayer() then

	end
end
--]]

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 190340 then--Refi Defender
		timerDemoShoutCD:Stop(args.destGUID)
	elseif cid == 190362 then--Dazzling Dragonfly
		timerDazzleCD:Stop(args.destGUID)
	elseif cid == 190370 then--Spellcaller Cryaz
		timerZephyrsCallCD:Stop(args.destGUID)
		timerWhirlingFuryCD:Stop(args.destGUID)
	elseif cid == 190403 then--Glacial Proto-Dragon
		timerOceanicBreathCD:Stop(args.destGUID)
	elseif cid == 190405 then--Infuser Sariya
		timerAqueousBarrierCD:Stop(args.destGUID)
		timerFlashFloodCD:Stop(args.destGUID)
	elseif cid == 190368 then--Flamecaller Aymi
		timerMoltenSubductionCD:Stop(args.destGUID)
	elseif cid == 190401 then--Gusting Proto-Dragon
		timerGustingBreathCD:Stop(args.destGUID)
	elseif cid == 190373 then----Primalist Galeslinger
		timerThunderstormCD:Stop(args.destGUID)
	elseif cid == 190404 then
		timerTectonicBreathCD:Stop(args.destGUID)
	end
end

--TODO, actually get correct IDs, these are in guide but haven't collected Ids yet
function mod:GOSSIP_SHOW()
--	local gossipOptionID = self:GetGossipID()
--	if gossipOptionID then
--		if self.Options.AGBuffs and (gossipOptionID == 45624 or gossipOptionID == 45624) then -- Engineer/Herb Buff
--			self:SelectGossip(gossipOptionID)
--		end
--	end
end
