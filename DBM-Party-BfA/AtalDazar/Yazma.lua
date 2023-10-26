local mod	= DBM:NewMod(2030, "DBM-Party-BfA", 1, 968)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(122968)
mod:SetEncounterID(2087)
mod:SetHotfixNoticeRev(20231023000000)
mod:SetMinSyncRevision(20231023000000)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 249923 259187 250096 249919 250050",
	"SPELL_AURA_APPLIED 250036",
	"SPELL_PERIODIC_DAMAGE 250036",
	"SPELL_PERIODIC_MISSED 250036",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

--[[
(ability.id = 249923 or ability.id = 250096 or ability.id = 250050 or ability.id = 249919 or ability.id = 259187) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 250096 and (type = "cast" or type = "interrupt")
--]]
--TODO: Verify CHAT_MSG_RAID_BOSS_EMOTE for soulrend. I know i saw it but not sure I got spellId right since chatlog only grabs parsed name
local warnSoulRend					= mod:NewTargetAnnounce(259187, 4)

local specWarnSoulRend				= mod:NewSpecialWarningRun(259187, nil, nil, nil, 4, 2)
local yellSoulRend					= mod:NewYell(259187)
local specWarnWrackingPain			= mod:NewSpecialWarningInterruptCount(250096, "HasInterrupt", nil, nil, 1, 2)
local specWarnSkewer				= mod:NewSpecialWarningDefensive(249919, "Tank", nil, nil, 1, 2)
local specWarnEchoes				= mod:NewSpecialWarningDodgeCount(250050, nil, nil, nil, 2, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(250036, nil, nil, nil, 1, 8)

local timerSoulrendCD				= mod:NewCDCountTimer(40.6, 259187, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerWrackingPainCD			= mod:NewCDCountTimer(16.7, 250096, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--17-23
local timerSkewerCD					= mod:NewCDCountTimer(12, 249919, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEchoesCD					= mod:NewCDCountTimer(31.2, 250050, nil, nil, nil, 3)

mod.vb.soulCount = 0
mod.vb.wrackCount = 0
mod.vb.skewerCount = 0
mod.vb.echoCount = 0

--Skewer trigger 3.5 ICD
--Echos also triggers 3.5 ICD
--Soulrend triggers 6 ICD
--Wracking pain triggers 1.5 ICD+cast time before interrupt (not worth coding for)
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerSoulrendCD:GetRemaining(self.vb.soulCount+1) < ICD then
		local elapsed, total = timerSoulrendCD:GetTime(self.vb.soulCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerSoulrendCD extended by: "..extend, 2)
		timerSoulrendCD:Update(elapsed, total+extend, self.vb.soulCount+1)
	end
	if timerWrackingPainCD:GetRemaining(self.vb.wrackCount+1) < ICD then
		local elapsed, total = timerWrackingPainCD:GetTime(self.vb.wrackCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerWrackingPainCD extended by: "..extend, 2)
		timerWrackingPainCD:Update(elapsed, total+extend, self.vb.wrackCount+1)
	end
	if timerSkewerCD:GetRemaining(self.vb.skewerCount+1) < ICD then
		local elapsed, total = timerSkewerCD:GetTime(self.vb.skewerCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerSkewerCD extended by: "..extend, 2)
		timerSkewerCD:Update(elapsed, total+extend, self.vb.skewerCount+1)
	end
	if timerEchoesCD:GetRemaining(self.vb.echoCount+1) < ICD then
		local elapsed, total = timerEchoesCD:GetTime(self.vb.echoCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerEchoesCD extended by: "..extend, 2)
		timerEchoesCD:Update(elapsed, total+extend, self.vb.echoCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.soulCount = 0
	self.vb.wrackCount = 0
	self.vb.skewerCount = 0
	self.vb.echoCount = 0
	timerWrackingPainCD:Start(3.5-delay, 1)
	timerSkewerCD:Start(5-delay, 1)
	timerSoulrendCD:Start(9.6-delay, 1)
	timerEchoesCD:Start(15.6-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 249923 or spellId == 259187 then
		self.vb.soulCount = self.vb.soulCount + 1
		timerSoulrendCD:Start(nil, self.vb.soulCount+1)
		if not self:IsNormal() and not self:IsTank() then
			specWarnSoulRend:Show()
			specWarnSoulRend:Play("runout")
		end
		updateAllTimers(self, 6)
	elseif spellId == 250096 then
		self.vb.wrackCount = self.vb.wrackCount + 1
		timerWrackingPainCD:Start(nil, self.vb.wrackCount+1)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWrackingPain:Show(args.sourceName, self.vb.wrackCount)
			specWarnWrackingPain:Play("kickcast")
		end
	elseif spellId == 249919 then
		self.vb.skewerCount = self.vb.skewerCount + 1
		specWarnSkewer:Show()
		specWarnSkewer:Play("defensive")
		timerSkewerCD:Start(nil, self.vb.skewerCount+1)
		updateAllTimers(self, 3.5)
	elseif spellId == 250050 then
		self.vb.echoCount = self.vb.echoCount + 1
		specWarnEchoes:Show(self.vb.echoCount)
		specWarnEchoes:Play("watchstep")
		timerEchoesCD:Start(nil, self.vb.echoCount+1)
		updateAllTimers(self, 3.5)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 250036 and args:IsPlayer() and self:AntiSpam(2, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

--Same time as SPELL_CAST_START but has target information on normal
function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, targetname)
	if msg:find("spell:249924") then
		if targetname then--Normal, only one person affected, name in emote (name isn't in emote in other difficulties)
			if targetname == UnitName("player") then
				specWarnSoulRend:Show()
				specWarnSoulRend:Play("runout")
				yellSoulRend:Yell()
			else
				warnSoulRend:Show(targetname)
			end
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 250036 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
