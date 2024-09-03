local mod	= DBM:NewMod("DarkflameCleftTrash", "DBM-Party-WarWithin", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 425536 423501 430171 426883 426261 426295 426619 422414 440652 424322",
	"SPELL_CAST_SUCCESS 423501 426261 426619 422541 422414 424322",--425536 426295
	"SPELL_INTERRUPT",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--TODO, longer trash pulls for missing CD timers for: Mole Frenzy, Quenching Blast, Bonk!, Flaming Tether, Drain Light, Surging Wax
--TODO, add https://www.wowhead.com/spell=426260/pyro-pummel for https://www.wowhead.com/npc=212411/torchsnarl ? It's not in combat log?
local warnQuenchingBlast					= mod:NewSpellAnnounce(430171, 2)
local warnMoleFrenzy						= mod:NewCastAnnounce(425536, 3)--High Prio Interrupt
local warnFlamingTether						= mod:NewCastAnnounce(426295, 3)--High Prio Interrupt
local warnExplosiveFlame						= mod:NewCastAnnounce(424322, 3)--High Prio Interrupt
local warnBonk								= mod:NewCastAnnounce(426883, 4, nil, nil, "Tank|Healer")
local warnDrainLight						= mod:NewSpellAnnounce(422541, 3, nil, nil, nil, nil, nil, 3)
local warnOHHeadlock						= mod:NewTargetNoFilterAnnounce(426619, 4)

local specWarnWildWallop					= mod:NewSpecialWarningDodge(423501, nil, nil, nil, 2, 2)
local specWarnCeaselessFlame				= mod:NewSpecialWarningDodge(426261, nil, nil, nil, 2, 2)
local specWarnShadowSmash					= mod:NewSpecialWarningDodge(422414, nil, nil, nil, 2, 2)
local specWarnSurgingWax					= mod:NewSpecialWarningDodge(440652, nil, nil, nil, 2, 2)
local yellCeaselessFlame					= mod:NewYell(426261)
local specWarnOHHeadlock					= mod:NewSpecialWarningYou(426619, nil, nil, nil, 1, 2)
--local specWarnStormshield					= mod:NewSpecialWarningDispel(386223, "MagicDispeller", nil, nil, 1, 2)
local specWarnMoleFrenzy					= mod:NewSpecialWarningInterrupt(425536, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnFlamingTether					= mod:NewSpecialWarningInterrupt(426295, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnExplosiveFlame				= mod:NewSpecialWarningInterrupt(424322, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt

local timerWildWallopCD						= mod:NewCDNPTimer(11.5, 423501, nil, nil, nil, 3)--Poor Sample
--local timerQuenchingBlastCD				= mod:NewCDNPTimer(20.1, 430171, nil, nil, nil, 2)
--local timerSurgingWaxCD					= mod:NewCDNPTimer(20.1, 440652, nil, nil, nil, 3)
--local timerMoleFrenzyCD					= mod:NewCDPNPTimer(19.1, 425536, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerBonkCD							= mod:NewCDNPTimer(20.1, 426883, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerCeaselessFlameCD					= mod:NewCDPNPTimer(33.3, 426261, nil, nil, nil, 3)--Poor Sample
--local timerFlamingTetherCD				= mod:NewCDPNPTimer(20.1, 426295, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerOHHeadlockCD						= mod:NewCDNPTimer(32.4, 426619, nil, nil, nil, 3)
--local timerDrainLightCD					= mod:NewCDPNPTimer(20.1, 422541, nil, nil, nil, 3)
local timerShadowSmashCD					= mod:NewCDPNPTimer(12, 422414, nil, nil, nil, 3)
local timerExplosiveFlameCD					= mod:NewCDPNPTimer(20.4, 424322, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

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
	elseif spellId == 430171 then
		if self:AntiSpam(3, 4) then
			warnQuenchingBlast:Show()
		end
--		timerQuenchingBlastCD:Start(nil, args.sourceGUID)
	elseif spellId == 426883 then
		--timerBonkCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			if self:AntiSpam(3, 5) then
				warnBonk:Show()
			end
		end
	elseif spellId == 423501 then
		if self:AntiSpam(3, 2) then
			specWarnWildWallop:Show()
			specWarnWildWallop:Play("watchstep")
		end
	elseif spellId == 426261 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CeaseTarget", 0.1, 6)
		if self:AntiSpam(3, 2) then
			specWarnCeaselessFlame:Show()
			specWarnCeaselessFlame:Play("shockwave")
		end
	elseif spellId == 426619 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "OHHeadlockTarget", 0.1, 6)
	elseif spellId == 422414 then
		if self:AntiSpam(3, 2) then
			specWarnShadowSmash:Show()
			specWarnShadowSmash:Play("shockwave")
		end
	elseif spellId == 440652 then
		if self:AntiSpam(3, 2) then
			specWarnSurgingWax:Show()
			specWarnSurgingWax:Play("watchstep")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 423501 then
		timerWildWallopCD:Start(11.5, args.sourceGUID)
	elseif spellId == 426261 then
		timerCeaselessFlameCD:Start(33.3, args.sourceGUID)
--	elseif spellId == 426295 then
--		timerFlamingTetherCD:Start(20.1, args.sourceGUID)
	elseif spellId == 426619 then
		timerOHHeadlockCD:Start(32.4, args.sourceGUID)
	elseif spellId == 422541 then
		if self:AntiSpam(3, 6) then
			warnDrainLight:Show()
			warnDrainLight:Play("crowdcontrol")
		end
	elseif spellId == 422414 then
		timerShadowSmashCD:Start(12, args.sourceGUID)
	elseif spellId == 424322 then
		timerExplosiveFlameCD:Start(20.4, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 426295 then
--		timerFlamingTetherCD:Start(20.1, args.destGUID)
	elseif spellId == 424322 then
		timerExplosiveFlameCD:Start(20.4, args.destGUID)
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 395035 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 210818 then--Lowly Moleherd
--		timerMoleFrenzyCD:Stop(args.destGUID)
	elseif cid == 211121 then--Rank Overseeer
		timerWildWallopCD:Stop(args.destGUID)
	elseif cid == 208450 then--Wandering Candle
--		timerQuenchingBlastCD:Stop(args.destGUID)
--		timerSurgingWaxCD:Stop(args.destGUID)
	elseif cid == 212383 then--Kobold Taskworker
--		timerBonkCD:Stop(args.destGUID)
	elseif cid == 212412 then--Sootsnout
		timerCeaselessFlameCD:Stop(args.destGUID)
		--timerFlamingTetherCD:Stop(args.destGUID)
	elseif cid == 212411 then--Torchsnarl
		timerOHHeadlockCD:Stop(args.destGUID)
	elseif cid == 208456 then--Shuffling Horror
		timerShadowSmashCD:Stop(args.destGUID)
	elseif cid == 211228 or cid == 220815 or cid == 223770 or cid == 223772 or cid == 223773 or cid == 223774 or cid == 223775 or cid == 223776 or cid == 223777 then--Blazing Fiend
		timerExplosiveFlameCD:Stop(args.destGUID)
	end
end
