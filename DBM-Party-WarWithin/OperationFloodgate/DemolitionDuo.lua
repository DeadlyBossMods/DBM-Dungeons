if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod(2649, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226403, 226402)
mod:SetEncounterID(3019)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 460867 1217653 473690 459799 459779",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_SUMMON 473524 460781",
	"SPELL_AURA_APPLIED 473713 470022",
	"SPELL_AURA_REMOVED 470022",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, DO NOT FORGET to add the count to common local for BBBFG
--TODO, add https://www.wowhead.com/ptr-2/spell=460602/quick-shot
--TODO, optimize charge as needed
--TODO, support nameplate timers when creatureIds known
--[[
(ability.id = 460867 or ability.id = 1217653 or ability.id = 473690 or ability.id = 459799 or ability.id = 459779) and type = "begincast"
 or (target.id = 226403 or target.id = 226402) and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--General
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)
--Keeza Quickfuse
mod:AddTimerLine(DBM:EJ_GetSectionInfo(30321))
--TODO, evertthing
local warnBigBadaBoom						= mod:NewCountAnnounce(460867, 3, nil, nil, 167180)
local warnExplosiveGel						= mod:NewTargetNoFilterAnnounce(473690, 2, nil, "RemoveMagic", DBM_COMMON_L.KNOCKUP)

local specWarnBBBFG							= mod:NewSpecialWarningDodgeCount(1217653, nil, nil, DBM_COMMON_L.FRONTAL, 2, 15)
local specWarnExplosiveGel					= mod:NewSpecialWarningYou(473690, nil, nil, DBM_COMMON_L.KNOCKUP, 1, 2)
local yellExplosiveGel						= mod:NewShortYell(473690, DBM_COMMON_L.KNOCKUP)

local timerBigBadaBoomCD					= mod:NewCDCountTimer(35.3, 460867, 167180, nil, nil, 5)--Short text "Bombs"
--local timerBombsExplode					= mod:NewCastTimer(30, 460787, 167180, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerBBBFG							= mod:NewCDCountTimer(17.7, 1217653, DBM_COMMON_L.FRONTAL, nil, nil, 3)--.." (%s)"
local timerExplosiveGelCD					= mod:NewCDCountTimer(17.7, 473690, DBM_COMMON_L.KNOCKUP, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON..DBM_COMMON_L.MYTHIC_ICON)
--Bront
mod:AddTimerLine(DBM:EJ_GetSectionInfo(30322))
local warnCharge							= mod:NewTargetNoFilterAnnounce(470022, 2, nil, nil, 100)

local specWarnCharge						= mod:NewSpecialWarningYou(470022, nil, 100, nil, 1, 2)
local yellCharge							= mod:NewShortYell(470022, 100)
local yellChargeFades						= mod:NewShortFadesYell(470022, 100)
local specWarnWallop						= mod:NewSpecialWarningDefensive(459799, nil, nil, nil, 1, 2)
local yellWallop							= mod:NewShortYell(459799)

local timerChargeCD							= mod:NewVarCountTimer(33.9, 470022, nil, nil, nil, 3)
local timerWallopCD							= mod:NewVarCountTimer("v17-28", 459799, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--mod.vb.bombCount = 0
mod.vb.bombCastCount = 0
mod.vb.bbbfgCount = 0
mod.vb.knockCount = 0
mod.vb.chargeCount = 0
mod.vb.wallopCount = 0
mod.vb.keezaDead = false

function mod:OnCombatStart(delay)
	--self.vb.bombCount = 0
	self.vb.bombCastCount = 0
	self.vb.bbbfgCount = 0
	self.vb.knockCount = 0
	self.vb.chargeCount = 0
	self.vb.wallopCount = 0
	self.vb.keezaDead = false
	timerWallopCD:Start(5.7-delay, 1)--5.7, 35.2, 17.0, 17.0
	timerBBBFG:Start(6.5-delay, 1)--6.5, 17.1
	timerBigBadaBoomCD:Start(13.9-delay, 1)--13.9
	if self:IsMythic() then
		timerExplosiveGelCD:Start(17.6-delay, 1)
	end
	timerChargeCD:Start(22.7-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 460867 then
		self.vb.bombCastCount = self.vb.bombCastCount + 1
		warnBigBadaBoom:Show(self.vb.bombCastCount)
		timerBigBadaBoomCD:Start(nil, self.vb.bombCastCount+1)
	elseif spellId == 1217653 then
		self.vb.bbbfgCount = self.vb.bbbfgCount + 1
		specWarnBBBFG:Show(self.vb.bbbfgCount)
		specWarnBBBFG:Play("frontal")
		timerBBBFG:Start(nil, self.vb.bbbfgCount+1)
	elseif spellId == 473690 then
		self.vb.knockCount = self.vb.knockCount + 1
		timerExplosiveGelCD:Start(nil, self.vb.knockCount+1)
	elseif spellId == 459799 then
		self.vb.wallopCount = self.vb.wallopCount + 1
		timerWallopCD:Start(nil, self.vb.wallopCount+1)
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnWallop:Show()
			specWarnWallop:Play("defensive")
			yellWallop:Yell()
		end
	elseif spellId == 459779 then
		self.vb.chargeCount = self.vb.chargeCount + 1
		local timer = (self.vb.chargeCount % 3 == 0) and "v23-25" or "v4-6.3"
		timerChargeCD:Start(timer, self.vb.chargeCount+1)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 459779 then

	end
end
--]]

--[[
function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 473524 or spellId == 460781 then
		self.vb.bombCount = self.vb.bombCount + 1
		if self.vb.bombCount == 1 then
			timerBombsExplode:Start()
		end
	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 473713 then
		if args:IsPlayer() then
			specWarnExplosiveGel:Show()
			specWarnExplosiveGel:Play("targetyou")
			yellExplosiveGel:Yell()
		else
			warnExplosiveGel:Show(args.destName)
		end
	elseif spellId == 470022 then
		if args:IsPlayer() then
			specWarnCharge:Show()
			specWarnCharge:Play("targetyou")
			yellCharge:Yell()
			yellChargeFades:Countdown(spellId)
		else
			warnCharge:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 470022 then
		if args:IsPlayer() then
			yellChargeFades:Cancel()
		end
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

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 226403 then--Keeza
		self.vb.keezaDead = true
		timerBigBadaBoomCD:Stop()
		timerBBBFG:Stop()
		timerExplosiveGelCD:Stop()
	elseif cid == 226402 then--Bront
		timerChargeCD:Stop()
		timerWallopCD:Stop()
	--elseif cid == 234528 or cid == 237446 then
	--	self.vb.bombCount = self.vb.bombCount - 1
	--	if self.vb.bombCount == 0 then
	--		timerBombsExplode:Stop()
	--	end
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
