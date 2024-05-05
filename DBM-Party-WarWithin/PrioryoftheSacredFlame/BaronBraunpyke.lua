local mod	= DBM:NewMod(2570, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207939)
mod:SetEncounterID(2835)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 422969 423051 446657 446368",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 423015 446649"
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, verify how shields work, debuffs a little wierd and didn't see the shield aoe explotion in logs at all
--TODO, hammer of purity isn't in CLEU at all except for SPELL_DAMAGE, so it can't be implemented without transcriptor log
--TODO, Pyre tracking on infoframe?
--[[
(ability.id = 422969 or ability.id = 423051 or ability.id = 446657 or ability.id = 446368) and type = "begincast"
 or (ability.id = 423015 or ability.id = 446649) and type = "applybuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Announce fade of wrath too?
local warnVindictiveWrath					= mod:NewCountAnnounce(422969, 3)
local warnCastigatorsShield					= mod:NewTargetNoFilterAnnounce(423015, 3)
local warnSacredPyre						= mod:NewCountAnnounce(446368, 3)

local specWarnCastigatorsShield				= mod:NewSpecialWarningMoveAway(423015, nil, nil, nil, 1, 2)
local yellCastigatorsShield					= mod:NewYell(423015)
local specWarnBurningLight					= mod:NewSpecialWarningInterruptCount(423051, "HasInterrupt", nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerVindictiveWrathCD				= mod:NewAITimer(33.9, 422969, nil, nil, nil, 6)
local timerCastigatorsShieldCD				= mod:NewAITimer(33.9, 423015, nil, nil, nil, 3)
local timerBurningLightCD					= mod:NewAITimer(33.9, 423051, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerHammerofPurityCD				= mod:NewAITimer(33.9, 423062, nil, nil, nil, 3)
local timerSacredPyreCD						= mod:NewAITimer(33.9, 446368, nil, nil, nil, 5)

--local castsPerGUID = {}

mod.vb.wrathCount = 0
mod.vb.shieldCount = 0
mod.vb.burningCount = 0
--mod.vb.hammerCount = 0
mod.vb.pyreCount = 0

function mod:OnCombatStart(delay)
	self.vb.wrathCount = 0
	self.vb.shieldCount = 0
	self.vb.burningCount = 0
	--mod.vb.hammerCount = 0
	self.vb.pyreCount = 0
	timerVindictiveWrathCD:Start(1-delay)
	timerCastigatorsShieldCD:Start(1-delay)
	timerBurningLightCD:Start(1-delay)
	--timerHammerofPurityCD:Start(1-delay)
	timerSacredPyreCD:Start(1-delay)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 422969 then
		self.vb.wrathCount = self.vb.wrathCount + 1
		warnVindictiveWrath:Show()
		timerVindictiveWrathCD:Start()
	elseif spellId == 423051 or spellId == 446657 then--regular, empowered
		self.vb.burningCount = self.vb.burningCount + 1
		specWarnBurningLight:Show(args.sourceName)
		specWarnBurningLight:Play("kickcast")
		timerBurningLightCD:Start()
	elseif spellId == 446368 then
		self.vb.pyreCount = self.vb.pyreCount + 1
		warnSacredPyre:Show(self.vb.pyreCount)
		timerSacredPyreCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 372858 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 423015 or spellId == 446649 then--Regular, empowered
		if self:AntiSpam(3, 1) then
			self.vb.shieldCount = self.vb.shieldCount + 1
			timerCastigatorsShieldCD:Start()
		end
		warnCastigatorsShield:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnCastigatorsShield:Show()
			specWarnCastigatorsShield:Play("scatter")
			yellCastigatorsShield:Yell()
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

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
