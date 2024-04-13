local mod	= DBM:NewMod("AtalDazarTrash", "DBM-Party-BfA", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(1763)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 255824 253562 255041 253544 253517 256849 252781 256138 253239 254959 252923 256882 255567 256846 252687",
	"SPELL_CAST_SUCCESS 253583 253721",
	"SPELL_AURA_APPLIED 260666 255824 256849 252781 252687 255814",
	"SPELL_AURA_APPLIED_DOSE 255814",
	"UNIT_DIED"
)

--TODO, target scan Merciless Assault?
--TODO, Reanimation Totem?
--TODO, deadly aim target scan?
--TODO, RP timers
--[[
(ability.id = 255824 or ability.id = 253562 or ability.id = 255041 or ability.id = 253544 or ability.id = 253517 or ability.id = 256849 or ability.id = 252781 or ability.id = 256138 or ability.id = 253239 or ability.id = 254959 or ability.id = 252923 or ability.id = 256882 or ability.id = 255567 or ability.id = 256846 or ability.id = 252687) and type = "begincast"
 or (ability.id = 253583 or ability.id = 253721) and type = "cast"
--]]
local warnBulwarkofJuju				= mod:NewSpellAnnounce(253721, 2)--Add Crowd Control audio
local warnFerventStrike				= mod:NewCastAnnounce(256138, 3, nil, nil, "Tank|Healer")
local warnMercilessAssault			= mod:NewCastAnnounce(253239, 3)
local warnDeadlyAim					= mod:NewCastAnnounce(256846, 3)
local warnSoulburn					= mod:NewCastAnnounce(254959, 3, nil, nil, false)--Mentioned in guide but not emphasized
local warnTerrifyingScreech			= mod:NewCastAnnounce(255041, 4)
local warnBwonsamdisMantle			= mod:NewCastAnnounce(253544, 4)
local warnMendingWord				= mod:NewCastAnnounce(253517, 4)
local warnUnstableHex				= mod:NewCastAnnounce(252781, 4)
local warnRendingMaul				= mod:NewStackAnnounce(255814, 2, nil, "Tank|Healer")
--local warnFrenziedCharge			= mod:NewTargetNoFilterAnnounce(255567, 4)

local specWarnWildThrash			= mod:NewSpecialWarningSpell(256882, nil, nil, nil, 2, 2)
local specWarnVenomfangStrike		= mod:NewSpecialWarningDefensive(252687, nil, nil, nil, 1, 2)
local specWarnUnstableHexSelf		= mod:NewSpecialWarningMoveAway(252781, nil, nil, nil, 1, 2)
local yellUnstableHex				= mod:NewYell(252781)
local specWarnFrenziedCharge		= mod:NewSpecialWarningDodge(255567, nil, nil, nil, 2, 2)
local yellFrenziedCharge			= mod:NewYell(255567)
local specWarnFanaticsRage			= mod:NewSpecialWarningInterrupt(255824, "HasInterrupt", nil, nil, 1, 2)
local specWarnWildFire				= mod:NewSpecialWarningInterrupt(253562, false, nil, 2, 1, 2)
local specWarnFieryEnchant			= mod:NewSpecialWarningInterrupt(253583, "HasInterrupt", nil, nil, 1, 2)
local specWarnTerrifyingScreech		= mod:NewSpecialWarningInterrupt(255041, "HasInterrupt", nil, nil, 1, 2)
local specWarnBwonsamdisMantle		= mod:NewSpecialWarningInterrupt(253544, "HasInterrupt", nil, nil, 1, 2)
local specWarnMendingWord			= mod:NewSpecialWarningInterrupt(253517, "HasInterrupt", nil, nil, 1, 2)
local specWarnDinoMight				= mod:NewSpecialWarningInterrupt(256849, "HasInterrupt", nil, nil, 1, 2)
local specWarnUnstableHex			= mod:NewSpecialWarningInterrupt(252781, "HasInterrupt", nil, nil, 1, 2)
local specWarnVenomBlast			= mod:NewSpecialWarningInterrupt(252923, false, nil, 2, 1, 2)
local specWarnTransfusion			= mod:NewSpecialWarningMoveTo(260666, nil, nil, nil, 3, 2)
local specWarnFanaticsRageDispel	= mod:NewSpecialWarningDispel(255824, "RemoveEnrage", nil, 2, 1, 2)
local specWarnDinoMightDispel		= mod:NewSpecialWarningDispel(256849, "MagicDispeller", nil, nil, 1, 2)
local specWarnVenomfangStrikeDispel	= mod:NewSpecialWarningDispel(252687, "RemovePoison", nil, nil, 1, 2)

local timerFieryEnchantCD			= mod:NewCDNPTimer(15.3, 253583, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--More Data needed
local timerMendingWardCD			= mod:NewCDNPTimer(13.3, 253517, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerFerventStrikeCD			= mod:NewCDNPTimer(12.1, 256138, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--17-19
local timerFanaticsRageCD			= mod:NewCDNPTimer(20.2, 255824, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerMercilessAssaultCD		= mod:NewCDNPTimer(9.8, 253239, nil, nil, nil, 3)
local timerBwonsamdisMantleCD		= mod:NewCDNPTimer(20.5, 253544, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSoulburnCD				= mod:NewCDNPTimer(13.3, 254959, nil, nil, nil, 3)
local timerTerrifyingScreechCD		= mod:NewCDNPTimer(18.2, 255041, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Could be 17, watch for debug
local timerVenomfangStrikeCD		= mod:NewCDNPTimer(15.3, 252687, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerBulwarkofJujuCD			= mod:NewCDNPTimer(22.2, 253721, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerHexCD					= mod:NewCDNPTimer(18.1, 252781, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerFrenziedChargeCD			= mod:NewCDNPTimer(13.3, 255567, nil, nil, nil, 3)--13.3-18.2
local timerWildThrashCD				= mod:NewCDNPTimer(13.3, 256882, nil, nil, nil, 3)--13.3-18.2
local timerDinoMightCD				= mod:NewCDNPTimer(14.5, 256849, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--More data needed
local timerDeadeyeAimCD				= mod:NewCDNPTimer(10.9, 256846, nil, nil, nil, 3)--10.9-20

local taintedBlood = DBM:GetSpellInfo(255558)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 gtfo

function mod:ChargeTarget(targetname)
	if not targetname then return end
--	warnFrenziedCharge:Show(targetname)
	if targetname == UnitName("player") then
		yellFrenziedCharge:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 255824 then
		timerFanaticsRageCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFanaticsRage:Show(args.sourceName)
			specWarnFanaticsRage:Play("kickcast")
		end
	elseif spellId == 253562 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWildFire:Show(args.sourceName)
			specWarnWildFire:Play("kickcast")
		end
	elseif spellId == 255041 then
		timerTerrifyingScreechCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn255041interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTerrifyingScreech:Show(args.sourceName)
			specWarnTerrifyingScreech:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnTerrifyingScreech:Show()
		end
	elseif spellId == 253544 then
		timerBwonsamdisMantleCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn253544interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBwonsamdisMantle:Show(args.sourceName)
			specWarnBwonsamdisMantle:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBwonsamdisMantle:Show()
		end
	elseif spellId == 253517 then
		timerMendingWardCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn253517interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMendingWord:Show(args.sourceName)
			specWarnMendingWord:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnMendingWord:Show()
		end
	elseif spellId == 256849 then
		timerDinoMightCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDinoMight:Show(args.sourceName)
			specWarnDinoMight:Play("kickcast")
		end
	elseif spellId == 252781 then
		timerHexCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn252781interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnUnstableHex:Show(args.sourceName)
			specWarnUnstableHex:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnUnstableHex:Show()
		end
	elseif spellId == 252923 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnVenomBlast:Show(args.sourceName)
			specWarnVenomBlast:Play("kickcast")
		end
	elseif spellId == 256138 then
		timerFerventStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnFerventStrike:Show()
		end
	elseif spellId == 253239 then
		timerMercilessAssaultCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnMercilessAssault:Show()
		end
	elseif spellId == 254959 then
		timerSoulburnCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnSoulburn:Show()
		end
	elseif spellId == 256882 then
		timerWildThrashCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnWildThrash:Show()
			specWarnWildThrash:Play("aesoon")
		end
	elseif spellId == 255567 then
		timerFrenziedChargeCD:Start(nil, args.sourceGUID)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ChargeTarget", 0.1, 6)
		specWarnFrenziedCharge:Show()
		specWarnFrenziedCharge:Play("chargemove")
	elseif spellId == 256846 then
		timerDeadeyeAimCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnDeadlyAim:Show()
		end
	elseif spellId == 252687 then
		timerVenomfangStrikeCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 253583 then
		timerFieryEnchantCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFieryEnchant:Show(args.sourceName)
			specWarnFieryEnchant:Play("kickcast")
		end
	elseif spellId == 253721 then
		timerBulwarkofJujuCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			warnBulwarkofJuju:Show()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 260666 and args:IsPlayer() then
		specWarnTransfusion:Show(taintedBlood)
		specWarnTransfusion:Play("takedamage")
	elseif spellId == 255824 and self:AntiSpam(4, 3) then
		specWarnFanaticsRageDispel:Show(args.destName)
		specWarnFanaticsRageDispel:Play("enrage")
	elseif spellId == 256849 and not args:IsDestTypePlayer() and self:AntiSpam(4, 3) then
		specWarnDinoMightDispel:Show(args.destName)
		specWarnDinoMightDispel:Play("helpdispel")
	elseif spellId == 252781 and args:IsPlayer() then
		specWarnUnstableHexSelf:Show()
		specWarnUnstableHexSelf:Play("runout")
		yellUnstableHex:Yell()
	elseif spellId == 252687 and args:IsDestTypePlayer() then
		if args:IsPlayer() then
			specWarnVenomfangStrike:Show()
			specWarnVenomfangStrike:Play("defensive")
		elseif self:CheckDispelFilter("poison") then
			specWarnVenomfangStrikeDispel:Show(args.destName)
			specWarnVenomfangStrikeDispel:Play("helpdispel")
		end
	elseif spellId == 255814 then
		local amount = args.amount or 1
		if self:AntiSpam(3, 5) then
			warnRendingMaul:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 127799 then--Dazar'ai Honor Guard
		timerFerventStrikeCD:Stop(args.destGUID)
	elseif cid == 122971 then--dazarai-juggernaut
		timerMercilessAssaultCD:Stop(args.destGUID)
		timerFanaticsRageCD:Stop(args.destGUID)
	elseif cid == 122973 then--dazarai-confessor
		timerMendingWardCD:Stop(args.destGUID)
		timerBwonsamdisMantleCD:Stop(args.destGUID)
	elseif cid == 122972 then--dazarai-augur
		timerFieryEnchantCD:Stop(args.destGUID)
	elseif cid == 122984 then--dazarai-colossus
		timerSoulburnCD:Stop(args.destGUID)
	elseif cid == 127879 then--shieldbearer-of-zul
		timerBulwarkofJujuCD:Stop(args.destGUID)
	elseif cid == 122969 then--zanchuli-witch-doctor
		timerHexCD:Stop(args.destGUID)
	elseif cid == 128434 then--feasting-skyscreamer
		timerTerrifyingScreechCD:Stop(args.destGUID)
	elseif cid == 129552 then--monzumi
		timerWildThrashCD:Stop(args.destGUID)
	elseif cid == 128455 then--tlonja
		timerFrenziedChargeCD:Stop(args.destGUID)
	elseif cid == 129553 then--dinomancer-kisho
		timerDinoMightCD:Stop(args.destGUID)
		timerDeadeyeAimCD:Stop(args.destGUID)
	elseif cid == 122970 then--Shadowblade Stalker
		timerVenomfangStrikeCD:Stop(args.destGUID)
	end
end
