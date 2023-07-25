local mod	= DBM:NewMod(2535, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod.multiIDSingleBoss = true
mod:SetCreatureID(198997, 201792, 201788, 201790)--It's technically just one creature animated 3 others, but checkbossHp will query all and return highest health for boss health percent
mod:SetEncounterID(2668)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetBossHPInfoToHighest()--may not be needed due to shared/synced health pools
mod:SetHotfixNoticeRev(20230711000000)
mod:SetMinSyncRevision(20230704000000)
--mod.respawnTime = 29
--mod.sendMainBossGUID = true--sendMainBossGUID is not sent because of stage 3 split

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 408029 406886 407159 408141",
	"SPELL_CAST_SUCCESS 408029 407978",
	"SPELL_AURA_APPLIED 407147 415097 415114 407406 418346",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 407406"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 406886 or ability.id = 407159 or ability.id = 408029 or ability.id = 408141) and type = "begincast"
 or ability.id = 407978 and type = "cast"
 or ability.id = 415097 or ability.id = 415114
 or (source.type = "NPC" and source.firstSeen = timestamp) and (source.id = 201792 or source.id = 201788 or source.id = 201790) or (target.type = "NPC" and target.firstSeen = timestamp) and (target.id = 201792 or target.id = 201788 or target.id = 201790)
 or type = "death" and (target.id = 201792 or target.id = 201788 or target.id = 201790)
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --TODO, maybe target scan frost to be slightly faster? Can also use applied of 408084 but that's even slower than success
 --TODO, Possibly transition stages on REMOVED not applied?
 --TODO, attach GUID to timers in a way that's compat with multi target
 --TODO, need much longer logs to fix many of timers again
--]]
local warnCorrosion							= mod:NewTargetNoFilterAnnounce(407406, 3)
local warnCorruptedMind						= mod:NewTargetNoFilterAnnounce(418346, 4)

local specWarnCorrosiveInfusion				= mod:NewSpecialWarningDodgeCount(406886, nil, nil, nil, 1, 2)
local specWarnCorrosion						= mod:NewSpecialWarningYou(407406, nil, nil, nil, 1, 2)
local yellCorrosion							= mod:NewYell(407406)
local yellCorrosionFades					= mod:NewShortFadesYell(407406, nil, nil, nil, "YELL")--WHen countdown shows, it needs to be passed, so it's a share yell not an avoid one, IE red text
local specWarnCorrosionClear				= mod:NewSpecialWarningMoveTo(407406, nil, nil, nil, 1, 2)
local specWarnReclamation					= mod:NewSpecialWarningCount(407159, nil, nil, nil, 2, 2)
local specWarnNecroticWinds					= mod:NewSpecialWarningDodgeCount(407978, nil, nil, nil, 1, 2)
local specWarnNecrofrost					= mod:NewSpecialWarningSwitchCount(408029, "Dps", nil, nil, 1, 2)
local yellNecrofrost						= mod:NewYell(408029, nil, nil, nil, "YELL")
local specWarnIncinBlightBreath				= mod:NewSpecialWarningDodgeCount(408141, nil, nil, nil, 1, 2)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(407147, nil, nil, nil, 1, 8)

local timerCorrosiveInfusionCD				= mod:NewCDCountTimer(19.4, 386173, nil, nil, nil, 3)
local timerBlightReclamationCD				= mod:NewCDCountTimer(19.4, 407159, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerNecroticWindsCD					= mod:NewCDCountTimer(19.4, 407978, nil, nil, nil, 2)
local timerNecrofrostCD						= mod:NewCDCountTimer(19.4, 408029, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerIncineratingBlightbreathCD		= mod:NewCDCountTimer(19.4, 408141, nil, nil, nil, 3)

--mod:AddInfoFrameOption(391977, true)

mod.vb.corrosiveCount = 0
mod.vb.reclaimCount = 0
mod.vb.windsCount = 0--Reused for necrofrost
mod.vb.fireBreathCount = 0

function mod:OnCombatStart(delay)
	self.vb.corrosiveCount = 0
	self.vb.reclaimCount = 0
	self.vb.windsCount = 0
	self.vb.fireBreathCount = 0
	self:SetStage(1)
	timerCorrosiveInfusionCD:Start(4.5-delay, 1)
	timerBlightReclamationCD:Start(14.2-delay, 1)
end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

local function checkDebuffPass(self)
	--Next pass is to tank
	if timerBlightReclamationCD:GetRemaining(self.vb.reclaimCount+1) < 6 then
		--Have debuff, and not the tank, and debuff will expire after next Blight Reclamation, it should go to the tank
		if not self:IsTanking("player", "boss1", nil, true) then
			specWarnCorrosionClear:Show(DBM_COMMON_L.TANK)
			specWarnCorrosionClear:Play("movetotank")
		end
	--Next pass is NOT to tank
	else
		--No tank check, because this condition will run if 5 seconds left on debuff but > 5 seconds til breath, so tank has to pass it too
		specWarnCorrosionClear:Show(DBM_COMMON_L.ALLY)
		specWarnCorrosionClear:Play("gathershare")--Will be changed to "passdebuff" or something later?
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 406886 then
		self.vb.corrosiveCount = self.vb.corrosiveCount + 1
		specWarnCorrosiveInfusion:Show(self.vb.corrosiveCount)
		specWarnCorrosiveInfusion:Play("watchstep")
		local timer
		if self:GetStage(1) then
			timer = 17
		elseif self:GetStage(2) then
			timer = 31.5
		else--Stage 3
			timer = 63.1
			--Update min timers on abilities affected by this
			if timerIncineratingBlightbreathCD:GetRemaining(self.vb.fireBreathCount+1) < 8 then
				local elapsed, total = timerIncineratingBlightbreathCD:GetTime(self.vb.fireBreathCount+1)
				local extend = 8 - (total-elapsed)
				DBM:Debug("timerIncineratingBlightbreathCD extended by: "..extend, 2)
				timerIncineratingBlightbreathCD:Update(elapsed, total+extend, self.vb.fireBreathCount+1)
			end
			if timerNecrofrostCD:GetRemaining(self.vb.windsCount+1) < 15.7 then
				local elapsed, total = timerNecrofrostCD:GetTime(self.vb.windsCount+1)
				local extend = 15.7 - (total-elapsed)
				DBM:Debug("timerNecrofrostCD extended by: "..extend, 2)
				timerNecrofrostCD:Update(elapsed, total+extend, self.vb.windsCount+1)
			end
		end
		timerCorrosiveInfusionCD:Start(timer, self.vb.corrosiveCount+1)
	elseif spellId == 407159 then
		self.vb.reclaimCount = self.vb.reclaimCount + 1
		specWarnReclamation:Show(self.vb.reclaimCount)
		specWarnReclamation:Play("shockwave")--Shockwave used so it doesn't use same voice as other breath
		local timer
		if self:GetStage(1) then
			timer = 17
		elseif self:GetStage(2) then
			timer = 31.5
			--rule only applies to stage 2. If time left on corrosive is less than 9.7, it's extended. this is what causes it to be 34 instead of 31.5 sometimes
			if timerIncineratingBlightbreathCD:GetRemaining(self.vb.corrosiveCount+1) < 9.7 then
				local elapsed, total = timerIncineratingBlightbreathCD:GetTime(self.vb.corrosiveCount+1)
				local extend = 9.7 - (total-elapsed)
				DBM:Debug("timerIncineratingBlightbreathCD extended by: "..extend, 2)
				timerIncineratingBlightbreathCD:Update(elapsed, total+extend, self.vb.corrosiveCount+1)
			end
		else
			timer = 63.1--Not verfied yet, assumed cause it looks same as corrosive
		end
		timerBlightReclamationCD:Start(timer, self.vb.reclaimCount+1)
		if self.vb.reclaimCount == 2 then--To verify the 63.1
			DBM:AddMsg("If you are logging this fight, please share log on DBM discord because you saw at least 2 reclamation casts in stage 3")
		end
	elseif spellId == 408029 then
		self.vb.windsCount = self.vb.windsCount + 1
		--The timers that are delayed will be auto corrected by Corrosive cast
		timerNecrofrostCD:Start(19.4, self.vb.windsCount+1)
	elseif spellId == 408141 then
		self.vb.fireBreathCount = self.vb.fireBreathCount + 1
		specWarnIncinBlightBreath:Show(self.vb.fireBreathCount)
		specWarnIncinBlightBreath:Play("breathsoon")
		--The timers that are delayed will be auto corrected by Corrosive cast
		timerIncineratingBlightbreathCD:Start(17.1, self.vb.fireBreathCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 408029 then
		if args:IsPlayer() then
			yellNecrofrost:Yell()
		else
			specWarnNecrofrost:Show(self.vb.windsCount)
			specWarnNecrofrost:Play("targetchange")
		end
	elseif spellId == 407978 then
		self.vb.windsCount = self.vb.windsCount + 1
		specWarnNecroticWinds:Show(self.vb.windsCount)
		specWarnNecroticWinds:Play("aesoon")
		specWarnNecroticWinds:ScheduleVoice(1.5, "watchstep")
		timerNecroticWindsCD:Start(31.5, self.vb.windsCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 407147 and args:IsPlayer() and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 415097 then--Malignant Transferal (stage 2)
		self:SetStage(2)
		self.vb.corrosiveCount = 0
		self.vb.reclaimCount = 0
		timerCorrosiveInfusionCD:Stop()
		timerBlightReclamationCD:Stop()
		--Starting here is less accurate than spell aura removed, causes ~1.5 variance
		timerCorrosiveInfusionCD:Start(9.7, 1)
		timerNecroticWindsCD:Start(19.4, 1)
		timerBlightReclamationCD:Start(34, 1)
	elseif spellId == 415114 then--Malignant Transferal (stage 2)
		self:SetStage(3)
		self.vb.corrosiveCount = 0
		self.vb.reclaimCount = 0
		self.vb.windsCount = 0
		timerCorrosiveInfusionCD:Stop()
		timerBlightReclamationCD:Stop()
		timerNecroticWindsCD:Stop()
		--Starting here is less accurate than spell aura removed, causes ~1.5 variance
		timerCorrosiveInfusionCD:Start(17.8, 1)
		timerIncineratingBlightbreathCD:Start(26.8, 1)
		timerNecrofrostCD:Start(34.7, 1)
		timerBlightReclamationCD:Start(67.5, 1)
	elseif spellId == 407406 then
		if args:IsPlayer() then
			specWarnCorrosion:Show()
			specWarnCorrosion:Play("targetyou")
			yellCorrosion:Yell()
			yellCorrosionFades:Countdown(spellId, 3)
			self:Unschedule(checkDebuffPass)
			self:Schedule(7, checkDebuffPass, self)--Check pass conditions 5 seconds til expire
		else
			warnCorrosion:Show(args.destName)
		end
	elseif spellId == 418346 then
		warnCorruptedMind:Show(args.destName)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 407406 then
		if args:IsPlayer() then
			yellCorrosionFades:Cancel()
			self:Unschedule(checkDebuffPass)
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 386201 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
