local mod	= DBM:NewMod(2573, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207940)
mod:SetEncounterID(2848)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 444546 423539 451605 423536",
	"SPELL_CAST_SUCCESS 423588",
	"SPELL_AURA_APPLIED 423588",
	"SPELL_AURA_REMOVED 423588",
	"SPELL_PERIODIC_DAMAGE 425556",
	"SPELL_PERIODIC_MISSED 425556"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 444546 or ability.id = 423539 or ability.id = 451605 or ability.id = 423536) and type = "begincast"
 or ability.id = 423588 and (type = "cast" or type = "applybuff" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, does boss have a really long RP that's included in ENCOUNTER_START
--TODO, how barrier affects timers. with only a single log I will make no assumptions and leave AI timers for now
local warnBarrierofLight					= mod:NewCountAnnounce(423588, 3)

local specWarnEmbracetheLight				= mod:NewSpecialWarningInterruptCount(423664, "HasInterrupt", nil, nil, 1, 2)
local specWarnPurifyingLight				= mod:NewSpecialWarningDodgeCount(444546, nil, nil, nil, 2, 2)
--local yellSomeAbility						= mod:NewYell(372107)
local specWarnInnerLight					= mod:NewSpecialWarningCount(423539, nil, nil, nil, 2, 2)
local specWarnHolyFlame						= mod:NewSpecialWarningDodgeCount(451606, nil, nil, nil, 2, 2)--451605 has no tooltip, debuff ID used for option key
local specWarnHolySmite						= mod:NewSpecialWarningInterruptCount(423536, false, nil, nil, 1, 2)--Very short cooldown
local specWarnGTFO							= mod:NewSpecialWarningGTFO(425556, nil, nil, nil, 1, 8)

local timerBarrierofLightCD					= mod:NewAITimer(33.9, 423588, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerPurifyingLightCD					= mod:NewAITimer(23, 444546, nil, nil, nil, 3)
local timerInnerLightCD						= mod:NewAITimer(23, 423539, nil, nil, nil, 2)
local timerHolyFlameCD						= mod:NewAITimer(8.4, 451606, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)--8.4-15.7

mod:AddInfoFrameOption(423588)

mod.vb.barrierCount = 0
mod.vb.purifyingCount = 0
mod.vb.innerCount = 0
mod.vb.holyFlameCount = 0
mod.vb.holySmiteCount = 0

function mod:OnCombatStart(delay)
	self.vb.barrierCount = 0
	self.vb.purifyingCount = 0
	self.vb.innerCount = 0
	self.vb.holyFlameCount = 0
	self.vb.holySmiteCount = 0
	timerBarrierofLightCD:Start(1-delay)--24.1
	timerPurifyingLightCD:Start(1-delay)--12.1
	timerInnerLightCD:Start(1-delay)--not cast before first barrier?
	timerHolyFlameCD:Start(1-delay)--9.3
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 444546 then
		self.vb.purifyingCount = self.vb.purifyingCount + 1
		specWarnPurifyingLight:Show(self.vb.purifyingCount)
		specWarnPurifyingLight:Play("watchstep")
		timerPurifyingLightCD:Start()
	elseif spellId == 423539 then
		self.vb.innerCount = self.vb.innerCount + 1
		specWarnInnerLight:Show(self.vb.innerCount)
		specWarnInnerLight:Play("aesoon")
		timerInnerLightCD:Start()
	elseif spellId == 451605 then
		self.vb.holyFlameCount = self.vb.holyFlameCount + 1
		specWarnHolyFlame:Show(self.vb.holyFlameCount)
		specWarnHolyFlame:Play("watchstep")
		timerHolyFlameCD:Start()
	elseif spellId == 423536 then
		self.vb.holySmiteCount = self.vb.holySmiteCount + 1
		if self:CheckInterruptFilter(args.sourceGUID, nil, true) then
			specWarnHolySmite:Show(args.sourceName, self.vb.holySmiteCount)
			specWarnHolySmite:Play("kickcast")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 423588 then
		self.vb.barrierCount = self.vb.barrierCount + 1
		warnBarrierofLight:Show(self.vb.barrierCount)
		timerBarrierofLightCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 423588 then
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 423588 then
		specWarnEmbracetheLight:Show(args.destName, self.vb.barrierCount)
		specWarnEmbracetheLight:Play("kickcast")
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 425556 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
