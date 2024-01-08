if (DBM:GetTOC() < 100200) then return end--DO NOT DELETE DO NOT DELETE DO NOT DELETE. We don't want this module loading in cataclysm
local mod	= DBM:NewMod("ThroneofTidesTrash", "DBM-Party-Cataclysm", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(643)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 76813 76815 76820 426741 426684 426645 428926 76590 429021 426783 428542 429176 426905",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 76820 428542 426618 426659",
	"SPELL_AURA_APPLIED_DOSE 426659",
--	"SPELL_AURA_REMOVED",
	"SPELL_PERIODIC_DAMAGE 426688",
	"SPELL_PERIODIC_MISSED 426688",
	"UNIT_DIED"
)

--TODO, additional spells not covered in wowhead guide?
--TODO, hybrid the mod for cataclysm classic (which basically would only have like 3-4 spells of this entire list
--[[
(ability.id = 76813 or ability.id = 76815 or ability.id = 76820 or ability.id = 426741 or ability.id = 426684 or ability.id = 426645 or ability.id = 428926 or ability.id = 76590 or ability.id = 429021 or ability.id = 426783 or ability.id = 428542 or ability.id = 429176 or ability.id = 426905) and type = "begincast"
--]]
--https://www.wowhead.com/guide/mythic-plus-dungeons/throne-of-the-tides-strategy
local warnCrushingDepths			= mod:NewTargetNoFilterAnnounce(428542, 4)
local warnSlitheringAssault			= mod:NewTargetNoFilterAnnounce(426618, 2, nil, "RemoveEnrage")
local warnHealingWave				= mod:NewCastAnnounce(76813, 3)
local warnHex						= mod:NewCastAnnounce(76820, 2)
local warnClenchingTentacles		= mod:NewCastAnnounce(428926, 4, nil, nil, nil, nil, nil, 13)
local warnPsionicPulse				= mod:NewCastAnnounce(426905, 4, nil, nil, nil, nil, nil, 3)
local warnAcidBarrage				= mod:NewSpellAnnounce(426645, 4)--, nil, nil, nil, nil, nil, 3
local warnRazorJaws					= mod:NewStackAnnounce(426659, 2, nil, "Tank|Healer")

local specWarnShadowSmash			= mod:NewSpecialWarningRun(76590, nil, nil, nil, 4, 2)
local specWarnVolatileBolt			= mod:NewSpecialWarningDodge(426684, nil, nil, nil, 2, 2)
local specWarnShellbreaker			= mod:NewSpecialWarningDefensive(426741, nil, nil, nil, 1, 2)
local specWarnCrush					= mod:NewSpecialWarningDefensive(429021, nil, nil, nil, 1, 2)
--local yellnViciousAmbush			= mod:NewYell(388984)
local specWarnHealingWave			= mod:NewSpecialWarningInterrupt(76813, "HasInterrupt", nil, nil, 1, 2)
local specWarnWrath					= mod:NewSpecialWarningInterrupt(76815, false, nil, nil, 1, 2)--TODO, Is this even used in 10.2 version? no log of it
local specWarnMindFlay				= mod:NewSpecialWarningInterrupt(426783, "HasInterrupt", nil, nil, 1, 2)
local specWarnAquablast				= mod:NewSpecialWarningInterrupt(429176, "HasInterrupt", nil, nil, 1, 2)
local specWarnHex					= mod:NewSpecialWarningDispel(76820, "RemoveMagic", nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(426688, nil, nil, nil, 1, 8)

local timerHealingWaveCD			= mod:NewCDNPTimer(17, 76813, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--17-18.2
local timerHexCD					= mod:NewCDNPTimer(20.4, 76820, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--Weak sample size, could be wrong
local timerCrushingDepthsCD			= mod:NewCDNPTimer(27.9, 428542, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)--Weak sample size, could be wrong
local timerShellbreakerCD			= mod:NewCDNPTimer(17, 426741, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--17-19 (8.4?)
local timerVolatileBoltCD			= mod:NewCDNPTimer(20.6, 426684, nil, nil, nil, 3)--20.6-24.2
local timerAcidBarrageCD			= mod:NewCDNPTimer(10.2, 426645, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--10.2-13 (8.7 lowest?)
local timerClenchingTentaclesCD		= mod:NewCDNPTimer(24.3, 428926, nil, nil, nil, 2)--24.3-25.5
local timerCrushCD					= mod:NewCDNPTimer(17, 429021, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerPsionicPulseCD			= mod:NewCDNPTimer(8.5, 426905, nil, nil, nil, 2)
local timerMindFlayCD				= mod:NewCDNPTimer(8.1, 426783, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 76813 then
		timerHealingWaveCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn76813interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHealingWave:Show(args.sourceName)
			specWarnHealingWave:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHealingWave:Show()
		end
	elseif spellId == 76815 then
		--TODO, timer? Does this even exist?
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWrath:Show(args.sourceName)
			specWarnWrath:Play("kickcast")
		end
	elseif spellId == 429176 then
		--No timer, it's basically spammed off spell lockout
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnAquablast:Show(args.sourceName)
			specWarnAquablast:Play("kickcast")
		end
	elseif spellId == 76820 then
		timerHexCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnHex:Show()
		end
	elseif spellId == 428542 then
		timerCrushingDepthsCD:Start(nil, args.sourceGUID)
	elseif spellId == 426741 then
		timerShellbreakerCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnShellbreaker:Show()
			specWarnShellbreaker:Play("defensive")
		end
	elseif spellId == 426684 then
		timerVolatileBoltCD:Start(nil, args.sourceGUID)
		--If remaining time on acid barrage is less than 6 seconds when volatile bolt is cast, it'll be extended
		if timerAcidBarrageCD:GetRemaining(args.sourceGUID) < 4.8 then
			DBM:Debug("extending acid barrage to 4.8 seconds", 2)
			timerAcidBarrageCD:Stop(args.sourceGUID)
			timerAcidBarrageCD:Start(4.8, args.sourceGUID)
		end
		if self:AntiSpam(3, 2) then
			specWarnVolatileBolt:Show()
			specWarnVolatileBolt:Play("watchstep")
		end
	elseif spellId == 426645 then
		timerAcidBarrageCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnAcidBarrage:Show()
--			warnAcidBarrage:Play("shockwave")
		end
	elseif spellId == 428926 then--Clenching tentacles is the new 10.2 mechanic that now triggers before the old Shadow Smash
		timerClenchingTentaclesCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnClenchingTentacles:Show()
			warnClenchingTentacles:Play("pullin")
		end
	elseif spellId == 76590 and self:AntiSpam(3, 1) then
		specWarnShadowSmash:Show()
		specWarnShadowSmash:Play("justrun")
	elseif spellId == 429021 then
		timerCrushCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnCrush:Show()
			specWarnCrush:Play("defensive")
		end
	elseif spellId == 426905 then
		timerPsionicPulseCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(5, 6) then--A lot of these exist in a single pack, so a larger 5 second antispam window used
			warnPsionicPulse:Show()
			warnPsionicPulse:Play("crowdcontrol")
		end
	elseif spellId == 426783 then
		timerMindFlayCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMindFlay:Show(args.sourceName)
			specWarnMindFlay:Play("kickcast")
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 88055 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 76820 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
		specWarnHex:Show(args.destName)
		specWarnHex:Play("helpdispel")
	elseif spellId == 428542 and (args:IsPlayer() or self:IsHealer()) then
		warnCrushingDepths:Show(args.destName)
	elseif spellId == 426618 and self:AntiSpam(3, 5) then
		warnSlitheringAssault:Show(args.destName)
	elseif spellId == 426659 and args:IsDestTypePlayer() then
		local amount = args.amount or 1
		if self:AntiSpam(3, 5) then
			warnRazorJaws:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 87726 then

	end
end
--]]

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 41096 then--Naz'jar Oracle
		timerHealingWaveCD:Stop(args.destGUID)
		timerHexCD:Stop(args.destGUID)
	elseif cid == 40577 then--Naz'jar Sentinel
		timerCrushingDepthsCD:Stop(args.destGUID)
		timerShellbreakerCD:Stop(args.destGUID)
	elseif cid == 212673 then--Naj'jar Ravager
		timerVolatileBoltCD:Stop(args.destGUID)
		timerAcidBarrageCD:Stop(args.destGUID)
	elseif cid == 40936 then--Faceless watcher
		timerClenchingTentaclesCD:Stop(args.destGUID)
		timerCrushCD:Stop(args.destGUID)
	elseif cid == 212778 then--Minion of Ghur'sha
		timerPsionicPulseCD:Stop(args.destGUID)
	elseif cid == 212775 then--Faceless Seer
		timerMindFlayCD:Stop(args.destGUID)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 426688 and destGUID == UnitGUID("player") and self:AntiSpam(3, 8) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
