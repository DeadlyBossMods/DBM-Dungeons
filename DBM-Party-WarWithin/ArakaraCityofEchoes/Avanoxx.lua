local mod	= DBM:NewMod(2583, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213179)
mod:SetEncounterID(2926)
--mod:SetUsedIcons(1, 2, 3, 4)
mod:SetHotfixNoticeRev(20240818000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2660)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 438471 438476 438473",
	"SPELL_SUMMON 439040",
	"SPELL_AURA_APPLIED 446794 439070 436614",
	"SPELL_AURA_APPLIED_DOSE 446794 434830"
)
--]]

--[[
(ability.id = 438471 or ability.id = 438476 or ability.id = 438473) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--[[
local warnInsatiable						= mod:NewStackAnnounce(446794, 4)
local warnVileWebbing						= mod:NewCountAnnounce(434830, 3, nil, nil, DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.stack:format(434830))--Player
local warnWebWrap							= mod:NewTargetNoFilterAnnounce(436614, 2, nil, "RemoveMagic")

local specWarnAlertingShrill				= mod:NewSpecialWarningCount(438476, nil, nil, nil, 2, 2)
local specWarnGossamerOnslaught				= mod:NewSpecialWarningDodgeCount(438473, nil, nil, nil, 2, 2)
local specWarnVoraciousBite					= mod:NewSpecialWarningDefensive(438471, nil, nil, nil, 1, 2)
local specWarnHunger						= mod:NewSpecialWarningRun(439070, nil, nil, nil, 1, 2)

local timerVoraciousBiteCD					= mod:NewCDCountTimer(14.1, 438471, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerAlertingShrillCD					= mod:NewVarCountTimer("v38.7-40.9", 438476, nil, nil, nil, 1)--38.7-40.9
local timerGossamerOnslaughtCD				= mod:NewVarCountTimer("v38.7-40.5", 438473, nil, nil, nil, 3)--38.7-40.5

mod:AddSetIconOption("SetIconOnAdds", 438476, true, 5, {1, 2, 3, 4})

mod.vb.biteCount = 0
mod.vb.shrillCount = 0
mod.vb.onslaughtCount = 0
mod.vb.mobIcon = 1

function mod:OnCombatStart(delay)
	self.vb.biteCount = 0
	self.vb.shrillCount = 0
	self.vb.onslaughtCount = 0
	self.vb.mobIcon = 1
	timerVoraciousBiteCD:Start(3.3-delay, 1)
	timerAlertingShrillCD:Start(10-delay, 1)
	timerGossamerOnslaughtCD:Start(30.0-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 438471 then
		self.vb.biteCount = self.vb.biteCount + 1
		timerVoraciousBiteCD:Start(nil, self.vb.biteCount+1)
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnVoraciousBite:Show()
			specWarnVoraciousBite:Play("defensive")
		end
	elseif spellId == 438476 then
		self.vb.mobIcon = 1
		self.vb.shrillCount = self.vb.shrillCount + 1
		specWarnAlertingShrill:Show(self.vb.shrillCount)
		specWarnAlertingShrill:Play("aesoon")
		if not self:IsTank() then
			specWarnAlertingShrill:ScheduleVoice(2, "killmob")
		end
		timerAlertingShrillCD:Start(nil, self.vb.shrillCount+1)
		--if time remaining on Voracious Bite is < 6.9, it's extended by this every time
		if timerVoraciousBiteCD:GetRemaining(self.vb.biteCount+1) < 6.9 then
			local elapsed, total = timerVoraciousBiteCD:GetTime(self.vb.biteCount+1)
			local extend = 6.9 - (total-elapsed)
			DBM:Debug("timerVoraciousBiteCD extended by: "..extend, 2)
			timerVoraciousBiteCD:Update(elapsed, total+extend, self.vb.biteCount+1)
		end
	elseif spellId == 438473 then
		self.vb.onslaughtCount = self.vb.onslaughtCount + 1
		specWarnGossamerOnslaught:Show(self.vb.onslaughtCount)
		specWarnGossamerOnslaught:Play("watchstep")
		timerGossamerOnslaughtCD:Start(nil, self.vb.onslaughtCount+1)
		--if time remaining on Voracious Bite is < 12.1, it's extended by this every time
		if timerVoraciousBiteCD:GetRemaining(self.vb.biteCount+1) < 12.1 then
			local elapsed, total = timerVoraciousBiteCD:GetTime(self.vb.biteCount+1)
			local extend = 12.1 - (total-elapsed)
			DBM:Debug("timerVoraciousBiteCD extended by: "..extend, 2)
			timerVoraciousBiteCD:Update(elapsed, total+extend, self.vb.biteCount+1)
		end
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 439040 then
		if self.Options.SetIconOnAdds then
			self:ScanForMobs(args.destGUID, 2, self.vb.mobIcon, 1, nil, 12, "SetIconOnAdds")
		end
		self.vb.mobIcon = self.vb.mobIcon + 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 446794 then
		warnInsatiable:Cancel()
		warnInsatiable:Schedule(1, args.destName, args.amount or 1)
	elseif spellId == 439070 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnHunger:Show()
		specWarnHunger:Play("justrun")
	elseif spellId == 434830 and args:IsPlayer() then
		if (args.amount % 3 == 0) or args.amount >= 8 then
			warnVileWebbing:Show(args.amount)
		end
	elseif spellId == 436614 then
		warnWebWrap:Show(args.destName)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]
