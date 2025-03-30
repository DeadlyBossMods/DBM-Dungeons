local mod	= DBM:NewMod(2389, "DBM-Party-Shadowlands", 6, 1187)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(162309)
mod:SetEncounterID(2364)
mod:SetZone(2293)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1215787 474087 473513 474298",
	"SPELL_CAST_SUCCESS 473540",
	"SPELL_AURA_APPLIED 474298 1223804"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
)

--TODO, can tank sidestep the dash?
--[[
(ability.id = 1215787 or ability.id = 474087 or ability.id = 473513 or ability.id = 474298) and type = "begincast"
 or (ability.id = 473540) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnWellofDarkness			= mod:NewTargetNoFilterAnnounce(473540, 3, nil, "Healer|RemoveMagic")

local specWarnDrawSoul				= mod:NewSpecialWarningMoveTo(474298, nil, nil, nil, 1, 2)--Want to run away from boss to spawn it further away
local yellDrawSoul					= mod:NewYell(474298)
local specWarnWellofDarkness		= mod:NewSpecialWarningMoveAway(473540, nil, nil, nil, 1, 2)
local yellWellofDarkness			= mod:NewYell(473540)
local specWarnDeathSpiral			= mod:NewSpecialWarningDodgeCount(1216474, nil, nil, nil, 2, 2, 4)
local specWarnNecroticEruption		= mod:NewSpecialWarningDodgeCount(474087, nil, nil, nil, 1, 15)
local specWarnFeastoftheDamned		= mod:NewSpecialWarningCount(473513, nil, nil, nil, 2, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerDrawSoulCD				= mod:NewVarCountTimer("v53.4-57.1", 474298, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON, nil, 1, 5)
local timerWellofDarknessCD			= mod:NewCDCountTimer(23.1, 473540, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.MAGIC_ICON)--23.1 except when delayed by other stuff
local timerDeathSpiralCD			= mod:NewVarCountTimer("v53.4-57.1", 1216474, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerNecroticEruptionCD		= mod:NewCDCountTimer(20.6, 474087, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFeastoftheDamnedCD		= mod:NewAITimer(20.6, 473513, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)--probably same CD as draw soul, needs confirmation

mod.vb.drawCount = 0
mod.vb.darknessCount = 0
mod.vb.feastCount = 0
mod.vb.spiralCount = 0
mod.vb.necroticEruption = 0

--Well of Darkness triggers 3.7 ICD
--Death Spiral triggers 2.4 ICD
--Draw Soul triggers 10.3 ICD???
---@param self DBMMod
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if self:IsMythic() then
		--if timerDrawSoulCD:GetRemaining(self.vb.drawCount+1) < ICD then
		--	local elapsed, total = timerDrawSoulCD:GetTime(self.vb.drawCount+1)
		--	local extend = ICD - (total-elapsed)
		--	DBM:Debug("timerDrawSoulCD extended by: "..extend, 2)
		--	timerDrawSoulCD:Update(elapsed, total+extend, self.vb.drawCount+1)
		--end
		if timerDeathSpiralCD:GetRemaining(self.vb.spiralCount+1) < ICD then
			local elapsed, total = timerDeathSpiralCD:GetTime(self.vb.spiralCount+1)
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerDeathSpiralCD extended by: "..extend, 2)
			timerDeathSpiralCD:Update(elapsed, total+extend, self.vb.spiralCount+1)
		end
	else
		if timerFeastoftheDamnedCD:GetRemaining(self.vb.feastCount+1) < ICD then
			local elapsed, total = timerFeastoftheDamnedCD:GetTime(self.vb.feastCount+1)
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerFeastoftheDamnedCD extended by: "..extend, 2)
			timerFeastoftheDamnedCD:Update(elapsed, total+extend, self.vb.feastCount+1)
		end
	end
	if timerWellofDarknessCD:GetRemaining(self.vb.darknessCount+1) < ICD then
		local elapsed, total = timerWellofDarknessCD:GetTime(self.vb.darknessCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerWellofDarknessCD extended by: "..extend, 2)
		timerWellofDarknessCD:Update(elapsed, total+extend, self.vb.darknessCount+1)
	end
	if timerNecroticEruptionCD:GetRemaining(self.vb.necroticEruption+1) < ICD then
		local elapsed, total = timerNecroticEruptionCD:GetTime(self.vb.necroticEruption+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerNecroticEruptionCD extended by: "..extend, 2)
		timerNecroticEruptionCD:Update(elapsed, total+extend, self.vb.necroticEruption+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.drawCount = 0
	self.vb.darknessCount = 0
	self.vb.feastCount = 0
	self.vb.spiralCount = 0
	self.vb.necroticEruption = 0
	timerWellofDarknessCD:Start(10.9-delay, 1)--SUCCESS event 473540
	timerNecroticEruptionCD:Start(16.9, 1)--START (16.9-19.1)
	if self:IsMythic() then
		timerDeathSpiralCD:Start(6-delay, 1)--START
		timerDrawSoulCD:Start(25.1-delay, 1)
	else
		timerFeastoftheDamnedCD:Start(50.6-delay)--Unknown, only have mythic logs
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 1215787 then
		self.vb.spiralCount = self.vb.spiralCount + 1
		specWarnDeathSpiral:Show(self.vb.spiralCount)
		specWarnDeathSpiral:Play("watchstep")
		--"Death Spiral-1215787-npc:162309-00004BDA78 = pull:6.0, 30.4, 54.6, 55.8",
		timerDeathSpiralCD:Start((self.vb.spiralCount == 1) and 30.4 or "v53.4-57.1", self.vb.spiralCount+1)
		updateAllTimers(self, 2.4)
	elseif spellId == 474087 then
		self.vb.necroticEruption = self.vb.necroticEruption + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnNecroticEruption:Show(self.vb.necroticEruption)
			specWarnNecroticEruption:Play("frontal")
		end
		--Necrotic Eruption-474087-npc:162309-00004BDA78 = pull:17.0, 30.4, 22.0, 32.7, 22.2",
		local timer = self.vb.necroticEruption == 1 and 30.4 or (self.vb.necroticEruption % 2 == 0) and 22.0 or 32.7
		timerNecroticEruptionCD:Start(timer, self.vb.necroticEruption+1)
	elseif spellId == 473513 then
		self.vb.feastCount = self.vb.feastCount + 1
		specWarnFeastoftheDamned:Show(self.vb.feastCount)
		specWarnFeastoftheDamned:Play("aesoon")
		timerFeastoftheDamnedCD:Start(nil, self.vb.feastCount+1)
	elseif spellId == 474298 then
		self.vb.drawCount = self.vb.drawCount + 1
		--"Draw Soul-474298-npc:162309-00004BDA78 = pull:25.4, 54.7, 55.8",
		timerDrawSoulCD:Start(nil, self.vb.drawCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 473540 then
		self.vb.darknessCount = self.vb.darknessCount + 1
		timerWellofDarknessCD:Start(nil, self.vb.darknessCount+1)
		updateAllTimers(self, 3.8)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 474298 then
		if args:IsPlayer() then
			specWarnDrawSoul:Show(DBM_COMMON_L.ALLIES)
			specWarnDrawSoul:Play("gather")
			yellDrawSoul:Yell()
		end
	elseif spellId == 1223804 then
		if args:IsPlayer() then
			specWarnWellofDarkness:Show()
			specWarnWellofDarkness:Play("scatter")
			yellWellofDarkness:Yell()
		else
			warnWellofDarkness:CombinedShow(0.3, args.destName)
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
