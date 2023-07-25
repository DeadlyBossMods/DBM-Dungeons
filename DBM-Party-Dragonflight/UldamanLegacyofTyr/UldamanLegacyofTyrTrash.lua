local mod	= DBM:NewMod("UldamanLegacyofTyrTrash", "DBM-Party-Dragonflight", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 369811 382578 369674 369823 369675 369806 377732 369399 369335 369400 369365 369423 369411 381593 382696 377500 369409",
	"SPELL_CAST_SUCCESS 377738 369465 369328 377732 382696 369811",
	"SPELL_AURA_APPLIED 369365 369828 369823 369818 369400 369366 377500",
	"SPELL_AURA_APPLIED_DOSE 369828 377738 369419",
--	"SPELL_AURA_REMOVED 339525",
	"UNIT_DIED"
)

--TODO, check target scanning of chain lightning
--TODO, add throw rock even though it's spammy? maybe off by default?
--TODO, dispel warning for https://www.wowhead.com/spell=377510/stolen-time ?
--[[
(ability.id = 369811 or ability.id = 382578 or ability.id = 369674 or ability.id = 369823 or ability.id = 369675 or ability.id = 369806 or ability.id = 377732 or ability.id = 369399 or ability.id = 369335 or ability.id = 369400 or ability.id = 369365 or ability.id = 369423 or ability.id = 369411 or ability.id = 381593 or ability.id = 382696 or ability.id = 377500) and type = "begincast"
 or (ability.id = 377738 or ability.id = 369465 or ability.id = 369328) and type = "cast"
--]]
local warnBlessingofTyr						= mod:NewCastAnnounce(382578, 4, nil, nil, "Tank|Healer")
local warnChainLightning					= mod:NewCastAnnounce(369675, 3)
local warnChomp								= mod:NewStackAnnounce(369828, 2, nil, "Tank|Healer")
local warnAncientPower						= mod:NewStackAnnounce(377738, 2, nil, "Tank|Healer")
local warnVenomousFangs						= mod:NewStackAnnounce(369419, 2, nil, "Tank|Healer|RemovePoison")
local warnRecklessRage						= mod:NewCastAnnounce(369806, 3, nil, nil, "Tank|Healer|RemoveEnrage")
local warnCleave							= mod:NewCastAnnounce(369409, 3, nil, nil, "Tank|Healer")
local warnJaggedBite						= mod:NewCastAnnounce(377732, 3, nil, nil, "Tank|Healer")
local warnHailofStone						= mod:NewCastAnnounce(369465, 4, nil, nil, nil, nil, nil, 3)
local warnEarthenWard						= mod:NewCastAnnounce(369400, 3)
local warnPounce							= mod:NewCastAnnounce(369423, 3)
local warnSonicBurst						= mod:NewCastAnnounce(369411, 4)
local warnThunderousClap					= mod:NewCastAnnounce(381593, 3)
local warnBulwarkSlam						= mod:NewCastAnnounce(382696, 4, nil, nil, "Tank|Healer")
local warnHasten							= mod:NewCastAnnounce(377500, 3)

local specWarnBrutalSlam					= mod:NewSpecialWarningRun(369811, nil, nil, nil, 4, 2)
local specWarnFissuringSlam					= mod:NewSpecialWarningDodge(369335, nil, nil, nil, 2, 2)
local specWarnEarthquake					= mod:NewSpecialWarningSpell(369328, nil, nil, nil, 2, 2)
--local specWarnChainLitYou					= mod:NewSpecialWarningMoveAway(369675, nil, nil, nil, 1, 2)
local yellTrappedInStone					= mod:NewYell(369366)
local specWarnCurseofStone					= mod:NewSpecialWarningDispel(369365, "RemoveCurse", nil, nil, 1, 2)
local specWarnTrappedinStone				= mod:NewSpecialWarningDispel(369366, "RemoveCurse", nil, nil, 1, 2)
local specWarnDiseasedbite					= mod:NewSpecialWarningDispel(369818, "RemoveDisease", nil, nil, 1, 2)
local specWarnSpikedCarapaceDispel			= mod:NewSpecialWarningDispel(369823, "MagicDispeller", nil, nil, 1, 2)
local specWarnEarthenWard					= mod:NewSpecialWarningDispel(369400, "MagicDispeller", nil, nil, 1, 2)
local specWarnHastenDispel					= mod:NewSpecialWarningDispel(377500, "MagicDispeller", nil, nil, 1, 2)
local specWarnChainLightning				= mod:NewSpecialWarningInterrupt(369675, "HasInterrupt", nil, nil, 1, 2)
local specWarnStoneSpike					= mod:NewSpecialWarningInterrupt(369674, "HasInterrupt", nil, nil, 1, 2)
local specWarnSpikedCarapace				= mod:NewSpecialWarningInterrupt(369823, "HasInterrupt", nil, nil, 1, 2)
local specWarnStoneBolt						= mod:NewSpecialWarningInterrupt(369399, "HasInterrupt", nil, nil, 1, 2)
local specWarnCurseofStoneKick				= mod:NewSpecialWarningInterrupt(369365, "HasInterrupt", nil, nil, 1, 2)
local specWarnSonicBurst					= mod:NewSpecialWarningInterrupt(369411, "HasInterrupt", nil, nil, 1, 2)
local specWarnHasten						= mod:NewSpecialWarningInterrupt(377500, "HasInterrupt", nil, nil, 1, 2)

local timerBrutalSlamCD						= mod:NewCDTimer(20.1, 369811, nil, nil, nil, 3)
local timerSpikedCarapaceCD					= mod:NewCDTimer(18.2, 369823, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerStoneSpikeCD						= mod:NewCDTimer(6, 369674, nil, false, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Short CD, may interfere with Chain LIghting CD timer, opt in
local timerChainLightningCD					= mod:NewCDTimer(25.5, 369675, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerJaggedBiteCD						= mod:NewCDTimer(11.8, 377732, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerAncientPowerCD					= mod:NewCDTimer(6, 377738, nil, nil, nil, 5)
local timerHailofStoneCD					= mod:NewCDTimer(21.8, 369465, nil, nil, nil, 5)
local timerStoneBoltCD						= mod:NewCDTimer(7.2, 369399, nil, false, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--7-11, off by default to giev prio to Hail of stone
local timerEarthquakeCD						= mod:NewCDTimer(25.4, 369328, nil, nil, nil, 2)
local timerFissuringSlamCD					= mod:NewCDTimer(9.7, 369335, nil, nil, nil, 2)--9.7-15
local timerCleaveCD							= mod:NewCDTimer(15, 369409, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerPounceCD							= mod:NewCDTimer(15.7, 369423, nil, nil, nil, 3)
local timerThunderousClapCD					= mod:NewCDTimer(19, 381593, nil, nil, nil, 2)
local timerBulwarkSlamCD					= mod:NewCDTimer(10.6, 382696, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerHastenCD							= mod:NewCDTimer(23, 377500, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 off dodge (can't be interrupted/CCed and too spammy to be special warning)

--[[
function mod:LitTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnChainLitYou:Show()
		specWarnChainLitYou:Play("runout")
		yellChainLit:Yell()
	end
end
--]]

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 369811 then
		if self:AntiSpam(3, 1) then
			specWarnBrutalSlam:Show()
			specWarnBrutalSlam:Play("justrun")
		end
	elseif spellId == 381593 then
		timerThunderousClapCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 8) then
			warnThunderousClap:Show()
		end
	elseif spellId == 382578 and self:AntiSpam(3, 5) then
		warnBlessingofTyr:Show()
	elseif spellId == 369674 then
		timerStoneSpikeCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnStoneSpike:Show(args.sourceName)
			specWarnStoneSpike:Play("kickcast")
		end
	elseif spellId == 369399 then
		timerStoneBoltCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnStoneBolt:Show(args.sourceName)
			specWarnStoneBolt:Play("kickcast")
		end
	elseif spellId == 369823 then
		timerSpikedCarapaceCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSpikedCarapace:Show(args.sourceName)
			specWarnSpikedCarapace:Play("kickcast")
		end
	elseif spellId == 369675 and args:GetSrcCreatureID() == 184022 then--184022 is trash version of mob (186658 is boss version)
--		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "LitTarget", 0.1, 8, true)
		timerChainLightningCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn369675interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnChainLightning:Show(args.sourceName)
			specWarnChainLightning:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnChainLightning:Show()
		end
	elseif spellId == 369806 and self:AntiSpam(3, 5) then
		warnRecklessRage:Show()
	elseif spellId == 377732 then
		if self:AntiSpam(3, 5) then
			warnJaggedBite:Show()
		end
	elseif spellId == 369409 then
		timerCleaveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnCleave:Show()
		end
	elseif spellId == 369335 then
		if timerEarthquakeCD:GetRemaining(args.sourceGUID) < 10 then
			timerFissuringSlamCD:Start(15.7, args.sourceGUID)
		else
			timerFissuringSlamCD:Start(9.7, args.sourceGUID)
		end
		if self:AntiSpam(3, 2) then
			specWarnFissuringSlam:Show()
			specWarnFissuringSlam:Play("watchstep")
		end
	elseif spellId == 369400 and self:AntiSpam(3, 6) then
		warnEarthenWard:Show()
	elseif spellId == 369365 then
		if self.Options.SpecWarn369365interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCurseofStoneKick:Show(args.sourceName)
			specWarnCurseofStoneKick:Play("kickcast")
--		elseif self:AntiSpam(3, 7) then
--			warnChainLightning:Show()
		end
	elseif spellId == 369423 then
		timerPounceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnPounce:Show()
		end
	elseif spellId == 369411 then
		if self.Options.SpecWarn369411interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSonicBurst:Show(args.sourceName)
			specWarnSonicBurst:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSonicBurst:Show()
		end
	elseif spellId == 382696 then
		if self:AntiSpam(3, 5) then
			warnBulwarkSlam:Show()
		end
	elseif spellId == 377500 then
		timerHastenCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn377500interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHasten:Show(args.sourceName)
			specWarnHasten:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHasten:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 377738 then
		timerAncientPowerCD:Start(nil, args.sourceGUID)
	elseif spellId == 369465 then
		timerHailofStoneCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnHailofStone:Show()
			warnHailofStone:Play("aesoon")
			warnHailofStone:ScheduleVoice(1.5, "crowdcontrol")
		end
	elseif spellId == 369328 then
		timerEarthquakeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnEarthquake:Show()
			specWarnEarthquake:Play("aesoon")
		end
	elseif spellId == 377732 then
		timerJaggedBiteCD:Start(nil, args.sourceGUID)
	elseif spellId == 382696 then
		timerBulwarkSlamCD:Start(nil, args.sourceGUID)
	elseif spellId == 369811 then
		timerBrutalSlamCD:Start(18.1, args.sourceGUID)--20.1 - 2
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 369365 and args:IsDestTypePlayer() and self:CheckDispelFilter("curse") and self:AntiSpam(3, 3) then
		specWarnCurseofStone:Show(args.destName)
		specWarnCurseofStone:Play("helpdispel")
	elseif spellId == 369828 then
		local amount = args.amount or 1
		if self:AntiSpam(3, 5) then
			warnChomp:Show(args.destName, amount)
		end
	elseif spellId == 377738 then
		local amount = args.amount or 1
		if amount >= 3 and self:AntiSpam(3, 5) then
			warnAncientPower:Show(args.destName, amount)
		end
	elseif spellId == 369823 and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnSpikedCarapaceDispel:Show(args.destName)
		specWarnSpikedCarapaceDispel:Play("helpdispel")
	elseif spellId == 369818 and self:CheckDispelFilter("disease") and args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnDiseasedbite:Show(args.destName)
		specWarnDiseasedbite:Play("helpdispel")
	elseif spellId == 369400 and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnEarthenWard:Show(args.destName)
		specWarnEarthenWard:Play("helpdispel")
	elseif spellId == 369366 then
		if self:CheckDispelFilter("curse") and self:AntiSpam(3, 3) then
			specWarnTrappedinStone:Show(args.destName)
			specWarnTrappedinStone:Play("helpdispel")
		end
		if args:IsPlayer() then
			yellTrappedInStone:Yell()
		end
	elseif spellId == 369419 then
		local amount = args.amount or 1
		if amount >= 3 and self:AntiSpam(3, 5) then
			warnVenomousFangs:Show(args.destName, amount)
		end
	elseif spellId == 377500 and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnHastenDispel:Show(args.destName)
		specWarnHastenDispel:Play("helpdispel")
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
	if cid == 184022 then--Stonevault Geomancer (Trash Version)
		timerChainLightningCD:Stop(args.destGUID)
		timerStoneSpikeCD:Stop(args.destGUID)
	elseif cid == 184130 then--Earthen Custodian
		timerCleaveCD:Stop(args.destGUID)
	elseif cid == 184319 then--Refti Custodian
		timerAncientPowerCD:Stop(args.destGUID)
		timerJaggedBiteCD:Stop(args.destGUID)
	elseif cid == 184303 then--Skittering Crawler
		timerPounceCD:Stop(args.destGUID)
	elseif cid == 184131 then--Earthen Guardian
		timerBulwarkSlamCD:Stop(args.destGUID)
	elseif cid == 184020 then--Hulking Berserker
		timerBrutalSlamCD:Stop(args.destGUID)
	elseif cid == 184023 then--Vicious Basilisk
		timerSpikedCarapaceCD:Stop(args.destGUID)
	elseif cid == 186420 then--Earthen Weaver
		timerHailofStoneCD:Stop(args.destGUID)
		timerStoneBoltCD:Stop(args.destGUID)
	elseif cid == 184107 then--Runic Protector
		timerEarthquakeCD:Stop(args.destGUID)
		timerFissuringSlamCD:Stop(args.destGUID)
	elseif cid == 184300 then--Ebonstone Golem
		timerThunderousClapCD:Stop(args.destGUID)
	elseif cid == 184335 then--Infinite Agent
		timerHastenCD:Stop(args.destGUID)
	end
end
