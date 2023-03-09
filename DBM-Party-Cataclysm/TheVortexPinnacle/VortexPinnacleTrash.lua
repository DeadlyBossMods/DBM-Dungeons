local mod	= DBM:NewMod("VortexPinnacleTrash", "DBM-Party-Cataclysm", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(657)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 88061 88010 88201 88194 87762 87761 87779",
	"SPELL_CAST_SUCCESS 88055 87759 87923",
	"SPELL_AURA_APPLIED 88171 88186",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED"
)

--[[

--]]
--TODO, verify cyclone can actually be interrupted
--TODO, empyrean assassin stack alerts? https://www.wowhead.com/spell=88182/lethargic-poison
--TODO can chilling Blast be side stepped?
--TODO, timer for Air Nova-87933 ?
--TODO, maybe wind blast timer off by default? a lot of those mobs can be up at once
--TODO, hurricane has a 17 second cd but packs with this mob have 4-8 of them with desynced timers, That's reason timer is omitted.
--NOTE: if 10.1 values differ from 10.0 values for timers, retain both for classic cataclysm
local warnCyclone								= mod:NewTargetNoFilterAnnounce(88010, 4)
local warnGaleStrike							= mod:NewCastAnnounce(88061, 3, nil, nil, "Tank|Healer|MagicDispeller")
local warnChillingBlast							= mod:NewCastAnnounce(88194, 3, nil, nil, "Tank|Healer")
local warnRally									= mod:NewCastAnnounce(87761, 3, nil, nil, "Tank|Healer")
local warnHealingWell							= mod:NewCastAnnounce(88201, 2)
local warnWindblast								= mod:NewSpellAnnounce(87923, 2, nil, "RemoveMagic|Tank")

local specWarnStormSurge						= mod:NewSpecialWarningRun(88055, nil, nil, nil, 4, 2)--Mob is immune to displacements and interrupts, this is an 8 yard range run out
--local yellnViciousAmbush						= mod:NewYell(388984)
local specWarnCyclone							= mod:NewSpecialWarningInterrupt(88010, "HasInterrupt", nil, nil, 1, 2)
local specWarnLightningLash						= mod:NewSpecialWarningInterrupt(87762, "HasInterrupt", nil, nil, 1, 2)--6sec cd on 10.0 but probably changed in 10.1?
local specWarnGreaterHeal						= mod:NewSpecialWarningInterrupt(87779, "HasInterrupt", nil, nil, 1, 2)
local specWarnVaporForm							= mod:NewSpecialWarningDispel(88186, "MagicDispeller", nil, nil, 1, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(88171, nil, nil, nil, 1, 8)

local timerCycloneCD							= mod:NewCDTimer(19.4, 88010, nil, nil, nil, 3)--19.4-21
local timerStormSurgeCD							= mod:NewCDTimer(16.1, 88055, nil, nil, nil, 2)--Retail 10.0 value
local timerGaleStrikeCD							= mod:NewCDTimer(17, 88061, nil, "Tank|Healer|MagicDispeller", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--Retail 10.0 value
local timerRallyCD								= mod:NewCDTimer(31.6, 87761, nil, nil, nil, 5)--Retail 10.0 value
local timerShockwaveCD							= mod:NewCDTimer(20.2, 87759, nil, "Tank|Healer", nil, 3)--Retail 10.0 value
local timerChillingBlastCD						= mod:NewCDTimer(23, 88194, nil, "Tank|Healer", nil, 3)--Retail 10.0 value
local timerWindBlastCD							= mod:NewCDTimer(10.1, 87923, nil, "Tank|MagicDispeller", nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--Retail 10.0 value

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 88061 then
		timerGaleStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnGaleStrike:Show()
		end
	elseif spellId == 88010 then
		timerCycloneCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCyclone:Show()
			specWarnCyclone:Play("kickcast")
		end
	elseif spellId == 87762 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnLightningLash:Show()
		specWarnLightningLash:Play("kickcast")
	elseif spellId == 87779 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnGreaterHeal:Show()
		specWarnGreaterHeal:Play("kickcast")
	elseif spellId == 88201 then--No throttle on purpose. this particular spell always needs awareness
		warnHealingWell:Show()
	elseif spellId == 88194 then
		timerChillingBlastCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnChillingBlast:Show()
		end
	elseif spellId == 87761 then--No throttle for now, it's a unique mob and infrequent cast
		timerRallyCD:Start(nil, args.sourceGUID)
		warnRally:Show()
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
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 88010 then
		warnCyclone:Show(args.destName)
	elseif spellId == 88171 and args:IsPlayer() and self:AntiSpam(2, 7) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 88186 and self:AntiSpam(2, 5) then
		specWarnVaporForm:Show(args.destName)
		specWarnVaporForm:Play("helpdispel")
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

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 45928 then--Executor of the Caliph
		timerRallyCD:Stop(args.destGUID)
		timerShockwaveCD:Stop(args.destGUID)
	elseif cid == 45915 then--Armored Mistral
		timerGaleStrikeCD:Stop(args.destGUID)
		timerStormSurgeCD:Stop(args.destGUID)
	elseif cid == 45919 then--Young Storm Dragon
		timerChillingBlastCD:Stop(args.destGUID)
	elseif cid == 45912 then--Wild Vortex
		timerCycloneCD:Stop(args.destGUID)
	elseif cid == 45477 then--Gust Soldier
		timerWindBlastCD:Stop(args.destGUID)
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
