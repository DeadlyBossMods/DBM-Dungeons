local mod	= DBM:NewMod(2570, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207939)
mod:SetEncounterID(2835)
mod:SetHotfixNoticeRev(20250303000000)
mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2649)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 422969 423051 446657 446368 423062 446598",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 446403",
	"SPELL_AURA_APPLIED_DOSE 446403",
	"SPELL_AURA_REMOVED 422969",
	"SPELL_MISSED 446403",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, Pyre tracking on infoframe?
--TODO, timers only vetted for mythic+ . mythic 0 and and heroic and normal and follower not vetted or tested at all
--[[
(ability.id = 422969 or ability.id = 423051 or ability.id = 446657 or ability.id = 446368) and type = "begincast"
 or (ability.id = 423015 or ability.id = 446649) and type = "applybuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Announce fade of wrath too?
local warnVindictiveWrath					= mod:NewCountAnnounce(422969, 3)
local warnVindictiveWrathFades				= mod:NewFadesAnnounce(422969, 1)
local warnCastigatorsShield					= mod:NewCountAnnounce(423015, 3)
local warnSacredPyre						= mod:NewCountAnnounce(446368, 3)
local warnFlamesLeft						= mod:NewAddsLeftAnnounce(446368, 2)

local specWarnBurningLight					= mod:NewSpecialWarningInterruptCount(423051, "HasInterrupt", nil, nil, 1, 2)
local specWarnHammerofPurity				= mod:NewSpecialWarningDodgeCount(423062, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerVindictiveWrathCD				= mod:NewCDCountTimer(68.8, 422969, nil, nil, nil, 6)
local timerCastigatorsShieldCD				= mod:NewVarCountTimer("v33.6-34", 423015, nil, nil, nil, 3)
local timerBurningLightCD					= mod:NewVarCountTimer("v33.6-34", 423051, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerHammerofPurityCD					= mod:NewVarCountTimer("v35.2-36", 423062, nil, nil, nil, 3)
local timerSacredPyreCD						= mod:NewVarCountTimer("v33.6-35.2", 446368, nil, nil, nil, 5, nil, DBM_COMMON_L.MYTHIC_ICON)

--local castsPerGUID = {}

mod.vb.wrathCount = 0
mod.vb.shieldCount = 0
mod.vb.burningCount = 0
mod.vb.hammerCount = 0
mod.vb.pyreCount = 0
mod.vb.flamesRemaining = 3
mod.vb.wrathActive = false

function mod:OnCombatStart(delay)
	self.vb.wrathCount = 0
	self.vb.shieldCount = 0
	self.vb.burningCount = 0
	self.vb.hammerCount = 0
	self.vb.pyreCount = 0
	self.vb.flamesRemaining = 3
	self.vb.wrathActive = false
	timerHammerofPurityCD:Start(7.3-delay, 1)
	timerCastigatorsShieldCD:Start(22.1-delay, 1)
	timerBurningLightCD:Start(29.2-delay, 1)
	timerVindictiveWrathCD:Start(35.2-delay, 1)
	if self:IsMythic() then
		timerSacredPyreCD:Start(15.4-delay, 1)
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 422969 then
		self.vb.wrathActive = true
		self.vb.wrathCount = self.vb.wrathCount + 1
		warnVindictiveWrath:Show(self.vb.wrathCount)
		timerVindictiveWrathCD:Start(nil, self.vb.wrathCount+1)
	elseif spellId == 423051 or spellId == 446657 then--regular, empowered
		self.vb.burningCount = self.vb.burningCount + 1
		specWarnBurningLight:Show(args.sourceName, self.vb.burningCount)
		specWarnBurningLight:Play("kickcast")
		timerBurningLightCD:Start(nil, self.vb.burningCount+1)
	elseif spellId == 446368 then
		self.vb.flamesRemaining = self.vb.wrathActive and 5 or 3
		self.vb.pyreCount = self.vb.pyreCount + 1
		warnSacredPyre:Show(self.vb.pyreCount)
		timerSacredPyreCD:Start(nil, self.vb.pyreCount+1)
	elseif spellId == 423062 or spellId == 446598 then--regular, empowered
		self.vb.hammerCount = self.vb.hammerCount + 1
		specWarnHammerofPurity:Show(self.vb.hammerCount)
		specWarnHammerofPurity:Play("watchstep")
		timerHammerofPurityCD:Start(nil, self.vb.hammerCount+1)
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
	if spellId == 446403 then
		self.vb.flamesRemaining = self.vb.flamesRemaining - 1
		warnFlamesLeft:Cancel()
		warnFlamesLeft:Schedule(1, self.vb.flamesRemaining)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_MISSED(_, _, _, _, _, _, _, _, spellId)
	--"<1397.99 19:10:52> [CLEU] SPELL_MISSED##nil#Player-5764-0040B100#Impyr#446403#Sacrificial Flame",
	if spellId == 446403 then
		self.vb.flamesRemaining = self.vb.flamesRemaining - 1
		warnFlamesLeft:Cancel()
		warnFlamesLeft:Schedule(1, self.vb.flamesRemaining)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 422969 then--Regular, empowered
		self.vb.wrathActive = false
		warnVindictiveWrathFades:Show()
	end
end

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
	if spellId == 446645 then
		--"Castigator's Shield-446645-npc:207939-000065268F = pull:25.2, 24.3, 23.1, 25.5, 26.7, 23.0, 25.5",
		self.vb.shieldCount = self.vb.shieldCount + 1
		warnCastigatorsShield:Show(self.vb.shieldCount)
		timerCastigatorsShieldCD:Start(nil, self.vb.shieldCount+1)
	end
end
