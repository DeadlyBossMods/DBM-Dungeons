local mod	= DBM:NewMod(2395, "DBM-Party-Shadowlands", 1, 1182)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(162691)
mod:SetEncounterID(2387)
mod:SetHotfixNoticeRev(20240817000000)
--mod:SetMinSyncRevision(20211203000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 320596 320637 320655",
	"SPELL_PERIODIC_DAMAGE 320646",
	"SPELL_PERIODIC_MISSED 320646"
--	"UNIT_SPELLCAST_START boss1"
)

--TODO, https://shadowlands.wowhead.com/spell=320614/blood-gorge stuff?
--[[
(ability.id = 320596 or ability.id = 320637 or ability.id = 320655) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnFetidGas					= mod:NewCountAnnounce(320637, 2)

local specWarnHeavingRetchYou		= mod:NewSpecialWarningMoveAway(320596, nil, nil, nil, 1, 2)
local specWarnHeavingRetch			= mod:NewSpecialWarningDodgeLoc(320596, nil, nil, nil, 2, 15)
local yellHeavingRetch				= mod:NewYell(320596)
local specWarnCrunch				= mod:NewSpecialWarningDefensive(320655, nil, nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(320646, nil, nil, nil, 1, 8)

local timerHeavingRetchCD			= mod:NewCDCountTimer(32.5, 320596, nil, nil, nil, 3)--32.7-42
local timerFetidGasCD				= mod:NewCDCountTimer(25.4, 320637, nil, nil, nil, 3)
local timerCrunchCD					= mod:NewCDCountTimer(12.1, 320655, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--11-20, spell queues behind other 2 casts

mod.vb.retchCount = 0
mod.vb.gasCount = 0
mod.vb.crunchCount = 0

--Crunch Triggers 3.6 ICD
--Heaving Retch Triggers 6-7.3 (almost aways 7.3 but the 6s do happen) ICD
--Fetid Gas Triggers 6 ICD
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerHeavingRetchCD:GetRemaining(self.vb.retchCount+1) < ICD then
		local elapsed, total = timerHeavingRetchCD:GetTime(self.vb.retchCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerHeavingRetchCD extended by: "..extend, 2)
		timerHeavingRetchCD:Update(elapsed, total+extend, self.vb.retchCount+1)
	end
	if timerFetidGasCD:GetRemaining(self.vb.gasCount+1) < ICD then
		local elapsed, total = timerFetidGasCD:GetTime(self.vb.gasCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerFetidGasCD extended by: "..extend, 2)
		timerFetidGasCD:Update(elapsed, total+extend, self.vb.gasCount+1)
	end
	if timerCrunchCD:GetRemaining(self.vb.crunchCount+1) < ICD then
		local elapsed, total = timerCrunchCD:GetTime(self.vb.crunchCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerCrunchCD extended by: "..extend, 2)
		timerCrunchCD:Update(elapsed, total+extend, self.vb.crunchCount+1)
	end
end

function mod:RetchTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnHeavingRetchYou:Show()
		specWarnHeavingRetchYou:Play("runout")
		yellHeavingRetch:Yell()
	else
		specWarnHeavingRetch:Show(targetname)
		specWarnHeavingRetch:Play("frontal")
	end
end

function mod:OnCombatStart(delay)
	self.vb.retchCount = 0
	self.vb.gasCount = 0
	self.vb.crunchCount = 0
	timerCrunchCD:Start(5-delay, 1)
	timerHeavingRetchCD:Start(10.3-delay, 1)
	timerFetidGasCD:Start(22-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 320596 then
		self.vb.retchCount = self.vb.retchCount + 1
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "RetchTarget", 0.1, 4)
		timerHeavingRetchCD:Start(nil, self.vb.retchCount+1)
		updateAllTimers(self, 6)
	elseif spellId == 320637 then
		self.vb.gasCount = self.vb.gasCount + 1
		warnFetidGas:Show(self.vb.gasCount)
		timerFetidGasCD:Start(nil, self.vb.gasCount+1)
		updateAllTimers(self, 6)
	elseif spellId == 320655 then
		self.vb.crunchCount = self.vb.crunchCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnCrunch:Show()
			specWarnCrunch:Play("defensive")
		end
		timerCrunchCD:Start(nil, self.vb.crunchCount+1)
		updateAllTimers(self, 3.6)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 320646 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--"<250.42 21:13:50> [UNIT_SPELLCAST_START] Blightbone(Suijro) - Heaving Retch - 2.5s [[boss1:Cast-3-2085-2286-7772-320596-000026E3DF:320596]]", -- [2791]
--"<250.42 21:13:50> [CLEU] SPELL_CAST_START#Creature-0-2085-2286-7772-162691-000026E310#Blightbone##nil#320596#Heaving Retch#nil#nil", -- [2794]
--"<250.42 21:13:50> [UNIT_TARGET] boss1#Blightbone - Hupe#Blightbone", -- [2795]
--"<250.60 21:13:50> [CHAT_MSG_MONSTER_YELL] Something... coming... up...#Blightbone###Hupe##0#0##0#30#nil#0#false#false#false#false", -- [2796]
--function mod:UNIT_SPELLCAST_START(uId, _, spellId)
--	if spellId == 320596 then
--		self:BossUnitTargetScanner(uId, "RetchTarget", 1)
--	end
--end
