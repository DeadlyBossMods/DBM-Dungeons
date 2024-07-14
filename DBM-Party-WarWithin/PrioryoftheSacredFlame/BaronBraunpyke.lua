local mod	= DBM:NewMod(2570, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207939)
mod:SetEncounterID(2835)
mod:SetHotfixNoticeRev(20240608000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 422969 423051 446657 446368",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED 423015 446649",
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, Pyre tracking on infoframe?
--[[
(ability.id = 422969 or ability.id = 423051 or ability.id = 446657 or ability.id = 446368) and type = "begincast"
 or (ability.id = 423015 or ability.id = 446649) and type = "applybuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Announce fade of wrath too?
local warnVindictiveWrath					= mod:NewCountAnnounce(422969, 3)
local warnCastigatorsShield					= mod:NewCountAnnounce(423015, 3)
local warnSacredPyre						= mod:NewCountAnnounce(446368, 3)

local specWarnBurningLight					= mod:NewSpecialWarningInterruptCount(423051, "HasInterrupt", nil, nil, 1, 2)
local specWarnHammerofPurity				= mod:NewSpecialWarningDodgeCount(423062, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerVindictiveWrathCD				= mod:NewCDCountTimer(48.5, 422969, nil, nil, nil, 6)
local timerCastigatorsShieldCD				= mod:NewCDCountTimer(23, 423015, nil, nil, nil, 3)--23-27
local timerBurningLightCD					= mod:NewCDCountTimer(34, 423051, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerHammerofPurityCD					= mod:NewCDCountTimer(18.2, 423062, nil, nil, nil, 3)
local timerSacredPyreCD						= mod:NewAITimer(33.9, 446368, nil, nil, nil, 5, nil, DBM_COMMON_L.MYTHIC_ICON)

--local castsPerGUID = {}

mod.vb.wrathCount = 0
mod.vb.shieldCount = 0
mod.vb.burningCount = 0
mod.vb.hammerCount = 0
mod.vb.pyreCount = 0

function mod:OnCombatStart(delay)
	self.vb.wrathCount = 0
	self.vb.shieldCount = 0
	self.vb.burningCount = 0
	self.vb.hammerCount = 0
	self.vb.pyreCount = 0
	timerVindictiveWrathCD:Start(45.9-delay, 1)
	timerCastigatorsShieldCD:Start(25.2-delay, 1)
	timerBurningLightCD:Start(16.7-delay, 1)
	timerHammerofPurityCD:Start(8.2-delay, 1)
	if self:IsMythic() then
		timerSacredPyreCD:Start(1-delay)
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 422969 then
		self.vb.wrathCount = self.vb.wrathCount + 1
		warnVindictiveWrath:Show(self.vb.wrathCount)
		timerVindictiveWrathCD:Start(nil, self.vb.wrathCount+1)
	elseif spellId == 423051 or spellId == 446657 then--regular, empowered
		--16.7, 35.2, 36.4, 35.2, 34.0
		self.vb.burningCount = self.vb.burningCount + 1
		specWarnBurningLight:Show(args.sourceName, self.vb.burningCount)
		specWarnBurningLight:Play("kickcast")
		timerBurningLightCD:Start(nil, self.vb.burningCount+1)
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

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 423015 or spellId == 446649 then--Regular, empowered

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

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

--NOTE, hammer of purity has a CLEU event now but i need to do more data verification first to see if it's usable
--NOTE, Castigator shield has a CLEU event now, but it isn't always cast, so it has to use this for cast/timer since even if it's not cast, it incurs a CD
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 446587 then
		--"Hammer of Purity-446587-npc:207939-000065268F = pull:8.2, 18.2, 24.3, 19.4, 20.6, 23.1, 21.8, 19.4, 23.1"
		self.vb.hammerCount = self.vb.hammerCount + 1
		specWarnHammerofPurity:Show(self.vb.hammerCount)
		specWarnHammerofPurity:Play("watchstep")
		timerHammerofPurityCD:Start(nil, self.vb.hammerCount+1)
	elseif spellId == 446645 then
		--"Castigator's Shield-446645-npc:207939-000065268F = pull:25.2, 24.3, 23.1, 25.5, 26.7, 23.0, 25.5",
		self.vb.shieldCount = self.vb.shieldCount + 1
		warnCastigatorsShield:Show(self.vb.shieldCount)
		timerCastigatorsShieldCD:Start(nil, self.vb.shieldCount+1)
	end
end
