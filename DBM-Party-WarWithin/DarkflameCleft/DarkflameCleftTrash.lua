local mod	= DBM:NewMod("DarkflameCleftTrash", "DBM-Party-WarWithin", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2651)
mod:RegisterZoneCombat(2651)

mod:RegisterEvents(
	"SPELL_CAST_START 425536 423501 430171 426883 426261 426295 426619 440652 424322 428066 423479 428563 1218117 422541 426260",--422414
	"SPELL_CAST_SUCCESS 422541 424322 428019 425536 426883 426295 1218131",--426295 422414
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 425555 428019 424650",
	"SPELL_AURA_APPLIED_DOSE 425555",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--TODO, longer trash pulls for missing CD timers for: Mole Frenzy, Quenching Blast, Bonk!, Flaming Tether, Drain Light, Surging Wax
--TODO, add https://www.wowhead.com/spell=426260/pyro-pummel for https://www.wowhead.com/npc=212411/torchsnarl ? It's not in combat log?
--TODO, fine tune crude weapons if it feels too spammy
--TODO, spreadsheet suggests https://www.wowhead.com/ptr-2/spell=427929/nasty-nibble but can't find it in any logs
--TODO, add optional candleflame bolt interrupt warning? it's a very spammed tank only firebolt
--TODO, warn when Skittering Darkness is low on health if melee (Unstable Shadows)?
--[[
(ability.id = 422414) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 422414
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 208456) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 208456)
--]]
local warnCrudeWeapons						= mod:NewStackAnnounce(425555, 2, nil, "Tank|Healer")
local warnQuenchingBlast					= mod:NewSpellAnnounce(430171, 2)
local warnMoleFrenzy						= mod:NewCastAnnounce(425536, 3)--High Prio Interrupt
local warnFlamingTether						= mod:NewCastAnnounce(426295, 3)--High Prio Interrupt
local warnExplosiveFlame					= mod:NewCastAnnounce(424322, 3)--High Prio Interrupt
local warnBonk								= mod:NewCastAnnounce(426883, 4, nil, nil, "Tank|Healer")
local warnOverpoweringRoar					= mod:NewCastAnnounce(428066, 3)
local warnDrainLight						= mod:NewCastAnnounce(422541, 3)--High Prio Interrupt
local warnOHHeadlock						= mod:NewTargetNoFilterAnnounce(426619, 4)

local specWarnMassiveStomp					= mod:NewSpecialWarningSpell(1218117, nil, nil, nil, 2, 2)
local specWarnWildWallop					= mod:NewSpecialWarningDodge(423501, nil, nil, nil, 2, 2)
local specWarnCeaselessFlame				= mod:NewSpecialWarningDodge(426261, nil, nil, nil, 2, 15)
local yellCeaselessFlame					= mod:NewYell(426261)
--local specWarnShadowSmash					= mod:NewSpecialWarningDodge(422414, nil, nil, nil, 2, 15)
local specWarnSurgingFlame					= mod:NewSpecialWarningDodge(440652, nil, nil, nil, 2, 2)
local specWarnBurningCandles				= mod:NewSpecialWarningDodge(1218131, nil, nil, nil, 2, 2)
local specWarnPyroPummel					= mod:NewSpecialWarningDodge(426260, nil, nil, nil, 2, 15)--Not CD based, conditional based, so no NP timer
local specWarnOHHeadlock					= mod:NewSpecialWarningYou(426619, nil, nil, nil, 1, 2)
--local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
local specWarnMoleFrenzy					= mod:NewSpecialWarningInterrupt(425536, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnFlamingTether					= mod:NewSpecialWarningInterrupt(426295, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnExplosiveFlame				= mod:NewSpecialWarningInterrupt(424322, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specwarnWicklighterBolt				= mod:NewSpecialWarningInterrupt(423479, false, nil, nil, 1, 2)--Spammed ability, so off by default
local specWarnFlamebolt						= mod:NewSpecialWarningInterrupt(428563, "HasInterrupt", nil, nil, 1, 2)--Spammed ability, so off by default
local specWarnDrainLight					= mod:NewSpecialWarningInterrupt(422541, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specwarnFlashpoint					= mod:NewSpecialWarningDispel(428019, "RemoveMagic", nil, nil, 1, 2)
local specwarnPanicked						= mod:NewSpecialWarningDispel(424650, "RemoveEnrage", nil, nil, 1, 2)

local timerWildWallopCD						= mod:NewCDNPTimer(21, 423501, nil, nil, nil, 3)--S2 value
local timerOverpoweringRoarCD				= mod:NewCDNPTimer(23, 428066, nil, nil, nil, 2)--S2 value
local timerQuenchingBlastCD					= mod:NewCDNPTimer(15.5, 430171, nil, nil, nil, 2)--15.5-18.3 usually 18.2
local timerSurgingFlameCD					= mod:NewCDNPTimer(24.4, 440652, nil, nil, nil, 3)
local timerMoleFrenzyCD						= mod:NewCDPNPTimer(25.8, 425536, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBonkCD							= mod:NewCDNPTimer(17, 426883, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--15-24
local timerCeaselessFlameCD					= mod:NewCDPNPTimer(36.2, 426261, nil, nil, nil, 3)
local timerFlamingTetherCD					= mod:NewCDPNPTimer(36.7, 426295, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerOHHeadlockCD						= mod:NewCDNPTimer(36.4, 426619, nil, nil, nil, 3)
local timerMassiveStompCD					= mod:NewCDNPTimer(18.2, 1218117, nil, nil, nil, 2)
local timerDrainLightCD						= mod:NewCDPNPTimer(16.2, 422541, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerShadowSmashCD					= mod:NewCDPNPTimer(12, 422414, nil, nil, nil, 3)
local timerExplosiveFlameCD					= mod:NewCDPNPTimer(22.8, 424322, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Possibly even higher CD
local timerFlashPointCD						= mod:NewCDNPTimer(13.6, 428019, nil, nil, nil, 5)
local timerBurningCandlesCD					= mod:NewCDNPTimer(17, 1218131, nil, nil, nil, 3)

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:CeaseTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellCeaselessFlame:Yell()
	end
end

function mod:OHHeadlockTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnOHHeadlock:Show()
		specWarnOHHeadlock:Play("targetyou")
	else
		warnOHHeadlock:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 425536 then
		if self.Options.SpecWarn425536interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnMoleFrenzy:Show(args.sourceName)
			specWarnMoleFrenzy:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnMoleFrenzy:Show()
		end
	elseif spellId == 426295 then
		if self.Options.SpecWarn426295interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFlamingTether:Show(args.sourceName)
			specWarnFlamingTether:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnFlamingTether:Show()
		end
	elseif spellId == 424322 then
		if self.Options.SpecWarn424322interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnExplosiveFlame:Show(args.sourceName)
			specWarnExplosiveFlame:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnExplosiveFlame:Show()
		end
	elseif spellId == 423479 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specwarnWicklighterBolt:Show(args.sourceName)
		specwarnWicklighterBolt:Play("kickcast")
	elseif spellId == 430171 then
		if self:AntiSpam(3, 4) then
			warnQuenchingBlast:Show()
		end
		timerQuenchingBlastCD:Start(nil, args.sourceGUID)
	elseif spellId == 426883 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			if self:AntiSpam(3, 5) then
				warnBonk:Show()
			end
		end
	elseif spellId == 423501 then
		timerWildWallopCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnWildWallop:Show()
			specWarnWildWallop:Play("watchstep")
		end
	elseif spellId == 426261 then
		timerCeaselessFlameCD:Start(nil, args.sourceGUID)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CeaseTarget", 0.1, 6)
		if self:AntiSpam(3, 2) then
			specWarnCeaselessFlame:Show()
			specWarnCeaselessFlame:Play("frontal")
		end
	elseif spellId == 426619 then
		timerOHHeadlockCD:Start(nil, args.sourceGUID)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "OHHeadlockTarget", 0.1, 6)
	--elseif spellId == 422414 then
	--	if self:AntiSpam(3, 2) then
	--		specWarnShadowSmash:Show()
	--		specWarnShadowSmash:Play("frontal")
	--	end
	elseif spellId == 440652 then
		timerSurgingFlameCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnSurgingFlame:Show()
			specWarnSurgingFlame:Play("watchstep")
		end
	elseif spellId == 428066 then
		timerOverpoweringRoarCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnOverpoweringRoar:Show()
		end
	elseif spellId == 428563 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnFlamebolt:Show(args.sourceName)
		specWarnFlamebolt:Play("kickcast")
	elseif spellId == 1218117 then
		timerMassiveStompCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnMassiveStomp:Show()
			specWarnMassiveStomp:Play("carefly")
		end
	elseif spellId == 422541 then
		if self.Options.SpecWarn422541interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDrainLight:Show(args.sourceName)
			specWarnDrainLight:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDrainLight:Show()
		end
	elseif spellId == 426260 then
		if self:AntiSpam(3, 2) then
			specWarnPyroPummel:Show()
			specWarnPyroPummel:Play("frontal")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 422541 then
		timerDrainLightCD:Start(16.2, args.sourceGUID)
	--elseif spellId == 422414 then
	--	timerShadowSmashCD:Start(12, args.sourceGUID)
	elseif spellId == 424322 then
		timerExplosiveFlameCD:Start(22.8, args.sourceGUID)
	elseif spellId == 428019 then
		timerFlashPointCD:Start(14.1, args.sourceGUID)
	elseif spellId == 425536 then
		timerMoleFrenzyCD:Start(23.8, args.sourceGUID)--25.8-2
	elseif spellId == 426883 then
		timerBonkCD:Start(14.6, args.sourceGUID)--17-2
	elseif spellId == 426295 then
		timerFlamingTetherCD:Start(36.7, args.sourceGUID)
	elseif spellId == 1218131 and self:AntiSpam(3, 9) then
		if self:AntiSpam(3, 2) then
			specWarnBurningCandles:Show()
			specWarnBurningCandles:Play("watchstep")
		end
		timerBurningCandlesCD:Start(17, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 426295 then
		timerFlamingTetherCD:Start(36.7, args.destGUID)
	elseif spellId == 424322 then
		timerExplosiveFlameCD:Start(22.8, args.destGUID)
	elseif spellId == 425536 then
		timerMoleFrenzyCD:Start(23.8, args.destGUID)--25.8-2
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 425555 then
		local amount = args.amount or 1
		if (amount >= 5) and self:AntiSpam(3, 5) then
			warnCrudeWeapons:Show(args.destName, amount)
		end
	elseif spellId == 428019 and self:CheckDispelFilter("magic") then
		specwarnFlashpoint:Show(args.destName)
		specwarnFlashpoint:Play("dispelnow")
	elseif spellId == 424650 then
		specwarnPanicked:Show(args.destName)
		specwarnPanicked:Play("enrage")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 210818 then--Lowly Moleherd
		timerMoleFrenzyCD:Stop(args.destGUID)
	elseif cid == 211121 then--Rank Overseeer
		timerWildWallopCD:Stop(args.destGUID)
		timerOverpoweringRoarCD:Stop(args.destGUID)
	elseif cid == 208450 then--Wandering Candle
		timerQuenchingBlastCD:Stop(args.destGUID)
		timerSurgingFlameCD:Stop(args.destGUID)
	elseif cid == 212383 then--Kobold Taskworker
		timerBonkCD:Stop(args.destGUID)
	elseif cid == 212412 then--Sootsnout
		timerCeaselessFlameCD:Stop(args.destGUID)
		timerFlamingTetherCD:Stop(args.destGUID)
		timerBurningCandlesCD:Stop(args.destGUID)
	elseif cid == 212411 then--Torchsnarl
		timerOHHeadlockCD:Stop(args.destGUID)
		timerMassiveStompCD:Stop(args.destGUID)
	elseif cid == 208456 then--Shuffling Horror
		--timerShadowSmashCD:Stop(args.destGUID)
		timerDrainLightCD:Stop(args.destGUID)
	elseif cid == 211228 or cid == 220815 or cid == 223770 or cid == 223772 or cid == 223773 or cid == 223774 or cid == 223775 or cid == 223776 or cid == 223777 then--Blazing Fiend
		timerExplosiveFlameCD:Stop(args.destGUID)
	elseif cid == 210812 then--Royal Wicklighter
		timerFlashPointCD:Stop(args.destGUID)
	end
end

--TEMP, most of these timers are set high on purpose due to poor debug on PTR, so idea is to force trigger debug prints with them
--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 210818 then--Lowly Moleherd
		timerMoleFrenzyCD:Start(5.9-delay, guid)
	elseif cid == 211121 then--Rank Overseeer
		timerWildWallopCD:Start(8.4-delay, guid)--8.8-14.5
		timerOverpoweringRoarCD:Start(10.2-delay, guid)--10.2-14.5
	elseif cid == 208450 then--Wandering Candle
		timerQuenchingBlastCD:Start(4.7-delay, guid)
		timerSurgingFlameCD:Start(10.7-delay, guid)
	elseif cid == 212383 then--Kobold Taskworker
		timerBonkCD:Start(4.2-delay, guid)
	elseif cid == 212412 then--Sootsnout
		timerCeaselessFlameCD:Start(6.2-delay, guid)
		timerBurningCandlesCD:Start(9.9-delay, guid)
		timerFlamingTetherCD:Start(21.5-delay, guid)
	elseif cid == 212411 then--Torchsnarl
--		timerOHHeadlockCD:Start(2-delay, guid)--Used near instantly
		timerMassiveStompCD:Start(5.0-delay, guid)
	elseif cid == 208456 then--Shuffling Horror
	--	timerShadowSmashCD:Start(12-delay, guid)
		timerDrainLightCD:Start(2.2-delay, guid)
	--elseif cid == 211228 or cid == 220815 or cid == 223770 or cid == 223772 or cid == 223773 or cid == 223774 or cid == 223775 or cid == 223776 or cid == 223777 then--Blazing Fiend
	--	timerExplosiveFlameCD:Start(20.4-delay, guid)--Used instantly on engage, no initial CD
	elseif cid == 210812 then--Royal Wicklighter
		timerFlashPointCD:Start(3.7-delay, guid)
	end
end

function mod:LeavingZoneCombat()
	self:Stop(true)
end
