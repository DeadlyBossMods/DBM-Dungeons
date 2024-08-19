local mod	= DBM:NewMod(2596, "DBM-Party-WarWithin", 8, 1274)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(216658)
mod:SetEncounterID(2909)
mod:SetHotfixNoticeRev(20240818000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 439401 439341 437700 438860 439646"
--	"SPELL_AURA_APPLIED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--TODO, timer for the 9 second shift loop (maybe a clean event in transcriptor, maybe scheduling, will wait for transcriptor first
--TODO, nameplate auras that evolve based on stack count on enemies based on stack count
--[[
(ability.id = 439401 or ability.id = 439341 or ability.id = 437700 or ability.id = 438860 or ability.id = 439646) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--local warnShiftingAnomalies				= mod:NewCountAnnounce(439401, 3)--For movements

local specWarnShiftingAnomalies				= mod:NewSpecialWarningDodgeCount(439401, nil, nil, nil, 2, 2)--Only on Spawn
local specWarnSplice						= mod:NewSpecialWarningCount(439341, nil, nil, nil, 2, 2)
local specWarnTremorSlam					= mod:NewSpecialWarningRunCount(437700, nil, nil, nil, 2, 2)
local specWarnUmbralWeave					= mod:NewSpecialWarningCount(438860, nil, nil, nil, 2, 2)
local specWarnProcessofElimination			= mod:NewSpecialWarningDefensive(439646, nil, nil, nil, 1, 2)
local yellProcessofElimination				= mod:NewYell(439646)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerShiftingAnomaliesCD				= mod:NewNextCountTimer(60, 439401, nil, nil, nil, 3)--Spawns AND movements (NYI)
local timerSpliceCD							= mod:NewNextCountTimer(20, 439341, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerTremorSlamCD						= mod:NewCDCountTimer(60, 437700, nil, nil, nil, 3)--NewCDCountTimer used due to randomness of first cast
local timerUmbralWeaveCD					= mod:NewCDCountTimer(60, 438860, nil, nil, nil, 5)--NewCDCountTimer used due to randomness of first cast
local timerProcessofEliminationCD			= mod:NewNextCountTimer(60, 439646, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod.vb.shiftCount = 0
mod.vb.spliceCount = 0
mod.vb.tremorCount = 0
mod.vb.weaveCount = 0
mod.vb.processCount = 0
mod.vb.firstSpell = 0--1 = Tremor, 2 = Umbral

--Note: The way this boss is scripted. He has a repeating combo of
--1. Shifting Anomalies where he teleports
--2. Splice where he aoes
--3. Umbral Weave or Tremor Slam (randomly selected)
--4. Second Splice where he aoes
--5. Umbral Weave or Tremor Slam (whichever wasn't cast first)
function mod:OnCombatStart(delay)
	self.vb.shiftCount = 0
	self.vb.spliceCount = 0
	self.vb.tremorCount = 0
	self.vb.weaveCount = 0
	self.vb.processCount = 0
	self.vb.firstSpell = 0--1 = Tremor, 2 = Umbral
	timerShiftingAnomaliesCD:Start(4-delay, 1)
	timerSpliceCD:Start(10-delay, 1)
	timerUmbralWeaveCD:Start(15.9-delay, 1)
	timerTremorSlamCD:Start(15.9-delay, 1)
	timerProcessofEliminationCD:Start(55-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 439401 then
		self.vb.shiftCount = self.vb.shiftCount + 1
		self.vb.firstSpell = 0--1 = Tremor, 2 = Umbral
		specWarnShiftingAnomalies:Show(self.vb.shiftCount)
		specWarnShiftingAnomalies:Play("watchorb")
		--Sequence resets, including umbral and tremor being randomly selected as first spell
		timerUmbralWeaveCD:Start(12, self.vb.weaveCount+1)
		timerTremorSlamCD:Start(12, self.vb.tremorCount+1)
		timerShiftingAnomaliesCD:Start(55, self.vb.shiftCount+1)
	elseif spellId == 439341 then
		self.vb.spliceCount = self.vb.spliceCount + 1
		specWarnSplice:Show(self.vb.spliceCount)
		specWarnSplice:Play("aesoon")
		--Technically this timer can also just be restarted from shifting anomalies, but it works fine this way too
		timerSpliceCD:Start(self.vb.spliceCount == 2 and 38 or 22, self.vb.spliceCount+1)
	elseif spellId == 437700 then
		if self.vb.firstSpell == 0 then
			self.vb.firstSpell = 1
			timerUmbralWeaveCD:Stop()
			timerUmbralWeaveCD:Start(22, self.vb.weaveCount+1)
		end
		self.vb.tremorCount = self.vb.tremorCount + 1
		specWarnTremorSlam:Show(self.vb.tremorCount)
		specWarnTremorSlam:Play("runout")
		--Timer not handled here anymore. Initial timers for both abilities started in anomalies
		--Then timer for 2nd ability is started on cast of first ability above
--		timerTremorSlamCD:Start(nil, self.vb.tremorCount+1)
	elseif spellId == 438860 then
		if self.vb.firstSpell == 0 then
			self.vb.firstSpell = 2
			timerTremorSlamCD:Stop()
			timerTremorSlamCD:Start(22, self.vb.tremorCount+1)
		end
		self.vb.weaveCount = self.vb.weaveCount + 1
		specWarnUmbralWeave:Show(self.vb.weaveCount)
		specWarnUmbralWeave:Play("gather")--Change sound if it's wrong to stackup for this, but stacking seems smart for aoe
		--Timer not handled here anymore. Initial timers for both abilities started in anomalies
		--Then timer for 2nd ability is started on cast of first ability above
--		timerUmbralWeaveCD:Start(nil, self.vb.weaveCount+1)
	elseif spellId == 439646 then
		self.vb.processCount = self.vb.processCount + 1
		timerProcessofEliminationCD:Start(nil, self.vb.processCount+1)
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnProcessofElimination:Show()
			specWarnProcessofElimination:Play("defensive")
			yellProcessofElimination:Yell()
		end
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 372858 then

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
