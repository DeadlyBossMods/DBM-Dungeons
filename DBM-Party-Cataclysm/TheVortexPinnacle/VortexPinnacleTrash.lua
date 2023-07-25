local mod	= DBM:NewMod("VortexPinnacleTrash", "DBM-Party-Cataclysm", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(657)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 88061 88010 88201 88194 87762 87761 87779 411012 411000 410870 410999 411002 411001 413385",
	"SPELL_CAST_SUCCESS 88055 87759 87923 411004 410998",
	"SPELL_AURA_APPLIED 88171 88186 88010 410870 87726",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 87726",
	"UNIT_DIED"
)

--[[

--]]
--TODO, verify cyclone can actually be interrupted
--TODO, empyrean assassin stack alerts? https://www.wowhead.com/spell=88182/lethargic-poison
--TODO can chilling Blast be side stepped?
--TODO, timer for Air Nova-87933 ?
--TODO, maybe wind blast timer off by default? a lot of those mobs can be up at once
--TODO, hurricane no longer exists in 10.1?
--TODO, "Rushing Wind-410873-npc:45477-0001271105 = pull:144.6, 17.0", -- [70] ?
--TODO, spell interrupt for https://www.wowhead.com/ptr/spell=410760/wind-bolt ?
--NOTE: if 10.1 values differ from 10.0 values for timers, retain both for classic cataclysm
--[[
(ability.id = 88061 or ability.id = 88010 or ability.id = 88201 or ability.id = 88194 or ability.id = 87762 or ability.id = 87761 or ability.id = 87779 or ability.id = 411012 or ability.id = 411000 or ability.id = 410870 or ability.id = 410999 or ability.id = 411002 or ability.id = 411001 or ability.id = 413385) and type = "begincast"
 or (ability.id = 88055 or ability.id = 87759 or ability.id = 87923 or ability.id = 411004 or ability.id = 410998) and type = "cast"
--]]
local warnCyclone								= mod:NewTargetNoFilterAnnounce(88010, 4)
local warnGaleStrike							= mod:NewCastAnnounce(88061, 3, nil, nil, "Tank|Healer|MagicDispeller")
local warnIcyBuffet								= mod:NewCastAnnounce(88194, 3, nil, nil, "Tank|Healer")
local warnRally									= mod:NewCastAnnounce(87761, 3, nil, nil, "Tank|Healer")
local warnHealingWell							= mod:NewCastAnnounce(88201, 2)
local warnCloudGuard							= mod:NewCastAnnounce(411000, 2)
local warnWindblast								= mod:NewSpellAnnounce(87923, 2, nil, "RemoveMagic|Tank")
local warnPressurizedBlast						= mod:NewCastAnnounce(410999, 4)
local warnBombCyclone							= mod:NewSpellAnnounce(411005, 3)
local warnWindFlurry							= mod:NewSpellAnnounce(410998, 3, nil, "Tank|Healer")
local warnLethalCurrent							= mod:NewCastAnnounce(411001, 4)
local warnOverloadGroundingField				= mod:NewCastAnnounce(413385, 4)
local warnLightningLash							= mod:NewTargetAnnounce(87762, 3)

local specWarnTurbulence						= mod:NewSpecialWarningSpell(411002, nil, nil, nil, 2, 2)
local specWarnChillingBreath					= mod:NewSpecialWarningDodge(411012, nil, nil, nil, 2, 2)
local specWarnStormSurge						= mod:NewSpecialWarningRun(88055, nil, nil, nil, 4, 2)--Mob is immune to displacements and interrupts, this is an 8 yard range run out
local specWarnOverloadGroundingField			= mod:NewSpecialWarningRun(413385, nil, nil, nil, 4, 2)
local specWarnLightningLash						= mod:NewSpecialWarningMoveTo(87762, nil, nil, nil, 1, 2)
--local yellnViciousAmbush						= mod:NewYell(388984)
local specWarnCyclone							= mod:NewSpecialWarningInterrupt(88010, "HasInterrupt", nil, nil, 1, 2)
local specWarnGreaterHeal						= mod:NewSpecialWarningInterrupt(87779, "HasInterrupt", nil, nil, 1, 2)
local specWarnVaporForm							= mod:NewSpecialWarningDispel(88186, "MagicDispeller", nil, nil, 1, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(88171, nil, nil, nil, 1, 8)

local timerCycloneCD							= mod:NewCDTimer(19.4, 88010, nil, nil, nil, 3)--19.4-21
local timerStormSurgeCD							= mod:NewCDTimer(16.1, 88055, nil, nil, nil, 2)
local timerGaleStrikeCD							= mod:NewCDTimer(17, 88061, nil, "Tank|Healer|MagicDispeller", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--Retail 10.0 value
local timerRallyCD								= mod:NewCDTimer(26.7, 87761, nil, nil, nil, 5)
local timerShockwaveCD							= mod:NewCDTimer(20.2, 87759, nil, "Tank|Healer", nil, 3)
local timerIcyBuffetCD							= mod:NewCDTimer(22.6, 88194, nil, "Tank|Healer", nil, 3)
local timerWindBlastCD							= mod:NewCDTimer(10.1, 87923, nil, "Tank|MagicDispeller", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--Retail 10.0 value
local timerCloudGuardCD							= mod:NewCDTimer(19.1, 411000, nil, nil, nil, 5)
local timerPressurizedBlastCD					= mod:NewCDTimer(21.8, 410999, nil, nil, nil, 2)
local timerBombCycloneCD						= mod:NewCDTimer(15.7, 411005, nil, nil, nil, 3)--15.9-17.1
local timerTurbulenceCD							= mod:NewCDTimer(32.8, 411002, nil, nil, nil, 2)
local timerWindFlurryCD							= mod:NewCDTimer(10.1, 410998, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerLightningLashCD						= mod:NewCDTimer(19, 87762, nil, nil, nil, 3)
local timerOverloadGroundingFieldCD				= mod:NewCDTimer(20.5, 413385, nil, nil, nil, 3)
local timerGreaterHealCD						= mod:NewCDTimer(14.1, 87779, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Post retial May 30th 2023 hotfix, in cataclysm this will still be like 3 second CD


--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

local groundingName = DBM:GetSpellInfo(87726)
local playerGrounded = false

function mod:LitTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnLightningLash:Show(groundingName)
		specWarnLightningLash:Play("findshelter")
	else
		warnLightningLash:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 88061 then
		timerGaleStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnGaleStrike:Show()
		end
	elseif spellId == 88010 or spellId == 410870 then--Pre 10.1, post 10.1
		timerCycloneCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCyclone:Show()
			specWarnCyclone:Play("kickcast")
		end
	elseif spellId == 87762 then
		timerLightningLashCD:Start(nil, args.sourceGUID)
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "LitTarget", 0.1, 8)
	elseif spellId == 87779 then
		timerGreaterHealCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGreaterHeal:Show()
			specWarnGreaterHeal:Play("kickcast")
		end
	elseif spellId == 88201 then--No throttle on purpose. this particular spell always needs awareness
		warnHealingWell:Show()
	elseif spellId == 88194 then
		timerIcyBuffetCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnIcyBuffet:Show()
		end
	elseif spellId == 87761 then
		timerRallyCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnRally:Show()
		end
	elseif spellId == 411012 and self:AntiSpam(2, 2) then
		specWarnChillingBreath:Show()
		specWarnChillingBreath:Play("breathsoon")
	elseif spellId == 411000 then
		timerCloudGuardCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnCloudGuard:Show()
		end
	elseif spellId == 410999 then
		timerPressurizedBlastCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnPressurizedBlast:Show()
		end
	elseif spellId == 411002 then
		timerTurbulenceCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnTurbulence:Show()
			specWarnTurbulence:Play("aesoon")
		end
--		specWarnTurbulence:ScheduleVoice("pushbackincoming")
	elseif spellId == 411002 and self:AntiSpam(3, 6) then
		warnLethalCurrent:Show()
	elseif spellId == 413385 then
		timerOverloadGroundingFieldCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			if playerGrounded then
				specWarnOverloadGroundingField:Show()
				specWarnOverloadGroundingField:Play("justrun")
			else
				warnOverloadGroundingField:Show()
			end
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 88055 then
		timerStormSurgeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnStormSurge:Show()
			specWarnStormSurge:Play("justrun")
		end
	elseif spellId == 87759 then
		timerShockwaveCD:Start(nil, args.sourceGUID)
	elseif spellId == 87923 then
		timerWindBlastCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnWindblast:Show()
		end
	elseif spellId == 411004 then
		timerBombCycloneCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnBombCyclone:Show()
		end
	elseif spellId == 410998 then
		timerWindFlurryCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnWindFlurry:Show()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 88010 or spellId == 410870 then
		warnCyclone:Show(args.destName)
	elseif spellId == 88171 and args:IsPlayer() and self:AntiSpam(2, 7) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 88186 and self:AntiSpam(2, 5) then
		specWarnVaporForm:Show(args.destName)
		specWarnVaporForm:Play("helpdispel")
	elseif spellId == 87726 and args:IsPlayer() then
		playerGrounded = true
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 87726 and args:IsPlayer() then
		playerGrounded = false
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 45928 then--Executor of the Caliph
		timerRallyCD:Stop(args.destGUID)
		timerShockwaveCD:Stop(args.destGUID)
	elseif cid == 45915 then--Armored Mistral
		timerGaleStrikeCD:Stop(args.destGUID)--Old
		timerStormSurgeCD:Stop(args.destGUID)--Old
		timerCloudGuardCD:Stop(args.destGUID)--New
		timerPressurizedBlastCD:Stop(args.destGUID)--New
	elseif cid == 45919 then--Young Storm Dragon
		timerIcyBuffetCD:Stop(args.destGUID)
	elseif cid == 45912 then--Wild Vortex
		timerCycloneCD:Stop(args.destGUID)
	elseif cid == 45477 then--Gust Soldier
		timerWindBlastCD:Stop(args.destGUID)
		timerWindFlurryCD:Stop(args.destGUID)
	elseif cid == 45917 then--Cloud Prince
		timerBombCycloneCD:Stop(args.destGUID)
		timerTurbulenceCD:Stop(args.destGUID)
	elseif cid == 45930 then--Minster of Air
		timerLightningLashCD:Stop(args.destGUID)
		timerOverloadGroundingFieldCD:Stop(args.destGUID)
	elseif cid == 45935 then--Temple Adept
		timerGreaterHealCD:Stop(args.destGUID)
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
