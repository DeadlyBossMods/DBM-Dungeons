local mod	= DBM:NewMod(2582, "DBM-Party-WarWithin", 4, 1269)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213119)
mod:SetEncounterID(2883)
mod:SetHotfixNoticeRev(20241016000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2652)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 427461 427852 427869",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO: Void rift not logged in combat log what so ever, can't fix without transcriptor
--TODO: Target scan unbridled Void?
--[[
(ability.id = 427461 or ability.id = 427852 or ability.id = 427869) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
--]]
local warnVoidCorruption					= mod:NewFadesAnnounce(427329, 1, nil, nil, nil, nil, nil, 2)

local specWarnVoidCorruption				= mod:NewSpecialWarning("specWarnVoidCorruption", nil, nil, nil, 1, 15, nil, nil, 427329)
local specWarnEntropicReckoning				= mod:NewSpecialWarningMoveAwayCount(427852, nil, nil, nil, 1, 15)
local specWarnUnbridledVoid					= mod:NewSpecialWarningDodgeCount(427869, nil, nil, nil, 1, 15)
--local yellSomeAbility						= mod:NewYell(372107)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerVoidCorruptionCD					= mod:NewCDCountTimer(29.1, 427329, nil, nil, nil, 3)--Medium priority, some delays
local timerEntropicReckoningCD				= mod:NewCDCountTimer(24.2, 427852, nil, nil, nil, 3)--Lowest priority, biggest delays
local timerUnbfridledVoidCD					= mod:NewCDCountTimer(20.2, 427869, nil, nil, nil, 3)--Medium priority, some delays

mod.vb.corruptionCount = 0
mod.vb.reckoningCount = 0
mod.vb.unbridledCount = 0

--Unbridled Void does 4.8 lockout (old, not sure if still current with new timers)
--Void Corruption does 3.6 lockout
--Entropic Reckoning does 6 lockout
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerVoidCorruptionCD:GetRemaining(self.vb.corruptionCount+1) < ICD then
		local elapsed, total = timerVoidCorruptionCD:GetTime(self.vb.corruptionCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerVoidCorruptionCD extended by: "..extend, 2)
		timerVoidCorruptionCD:Update(elapsed, total+extend, self.vb.corruptionCount+1)
	end
	if timerEntropicReckoningCD:GetRemaining(self.vb.reckoningCount+1) < ICD then
		local elapsed, total = timerEntropicReckoningCD:GetTime(self.vb.reckoningCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerEntropicReckoningCD extended by: "..extend, 2)
		timerEntropicReckoningCD:Update(elapsed, total+extend, self.vb.reckoningCount+1)
	end
	if timerUnbfridledVoidCD:GetRemaining(self.vb.unbridledCount+1) < ICD then
		local elapsed, total = timerUnbfridledVoidCD:GetTime(self.vb.unbridledCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerUnbfridledVoidCD extended by: "..extend, 2)
		timerUnbfridledVoidCD:Update(elapsed, total+extend, self.vb.unbridledCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.corruptionCount = 0
	self.vb.reckoningCount = 0
	self.vb.unbridledCount = 0
	timerUnbfridledVoidCD:Start(7.3-delay, 1)
	timerVoidCorruptionCD:Start(15.5-delay, 1)
	timerEntropicReckoningCD:Start(21-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 427461 then
		self.vb.corruptionCount = self.vb.corruptionCount + 1
		timerVoidCorruptionCD:Start(nil, self.vb.corruptionCount+1)
		updateAllTimers(self, 3.6)
	elseif spellId == 427852 then
		self.vb.reckoningCount = self.vb.reckoningCount + 1
		specWarnEntropicReckoning:Show(self.vb.reckoningCount)
		specWarnEntropicReckoning:Play("scatter")
		timerEntropicReckoningCD:Start(nil, self.vb.reckoningCount+1)--Now 24-28
		updateAllTimers(self, 6)
	elseif spellId == 427869 then
		self.vb.unbridledCount = self.vb.unbridledCount + 1
		specWarnUnbridledVoid:Show(self.vb.unbridledCount)
		specWarnUnbridledVoid:Play("frontal")
		timerUnbfridledVoidCD:Start(nil, self.vb.unbridledCount+1)
		updateAllTimers(self, 4.8)
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
	if spellId == 427329 then
		if args:IsPlayer() then
			specWarnVoidCorruption:Show()
			specWarnVoidCorruption:Play("riftdispel")
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 427329 and args:IsPlayer() then
		warnVoidCorruption:Show()
		warnVoidCorruption:Play("safenow")
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

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
