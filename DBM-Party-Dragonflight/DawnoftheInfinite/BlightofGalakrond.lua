local mod	= DBM:NewMod(2535, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod.multiIDSingleBoss = true
mod:SetCreatureID(198997, 201792, 201788, 201790)--It's technically just one creature animated 3 others, but checkbossHp will query all and return highest health for boss health percent
mod:SetEncounterID(2668)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetBossHPInfoToHighest()--may not be needed due to shared/synced health pools
mod:SetHotfixNoticeRev(20230704000000)
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
local specWarnNecrofrost					= mod:NewSpecialWarningSwitch(408029, "Dps", nil, nil, 1, 2)
local yellNecrofrost						= mod:NewYell(408029, nil, nil, nil, "YELL")
local specWarnIncinBlightBreath				= mod:NewSpecialWarningDodgeCount(408141, nil, nil, nil, 1, 2)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(407147, nil, nil, nil, 1, 8)

local timerCorrosiveInfusionCD				= mod:NewCDCountTimer(19.4, 386173, nil, nil, nil, 3)
local timerBlightReclamationCD				= mod:NewCDCountTimer(19.4, 407159, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerNecroticWindsCD					= mod:NewCDCountTimer(19.4, 407978, nil, nil, nil, 2)
local timerNecrofrostCD						= mod:NewCDCountTimer(43.7, 408029, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)
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
			timer = 32.7
		else
			timer = 43.7
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
			timer = 32.7
		else
			timer = 43.7
		end
		timerBlightReclamationCD:Start(timer, self.vb.reclaimCount+1)
	elseif spellId == 408029 then
		self.vb.windsCount = self.vb.windsCount + 1
		timerNecrofrostCD:Start(43.7, self.vb.windsCount+1)
	elseif spellId == 408141 then
		self.vb.fireBreathCount = self.vb.fireBreathCount + 1
		specWarnIncinBlightBreath:Show(self.vb.fireBreathCount)
		specWarnIncinBlightBreath:Play("breathsoon")
		timerIncineratingBlightbreathCD:Start(21.1, self.vb.fireBreathCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 408029 then
		if args:IsPlayer() then
			yellNecrofrost:Yell()
		else
			specWarnNecrofrost:Show()
			specWarnNecrofrost:Play("targetchange")
		end
	elseif spellId == 407978 then
		self.vb.windsCount = self.vb.windsCount + 1
		specWarnNecroticWinds:Show()
		specWarnNecroticWinds:Play("aesoon")
		specWarnNecroticWinds:ScheduleVoice(1.5, "watchstep")
		timerNecroticWindsCD:Start(32.7, self.vb.windsCount+1)
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
		timerBlightReclamationCD:Start(11.7, 1)
		timerCorrosiveInfusionCD:Start(21.5, 1)
		timerNecroticWindsCD:Start(31.1, 1)
	elseif spellId == 415114 then--Malignant Transferal (stage 2)
		self:SetStage(3)
		self.vb.corrosiveCount = 0
		self.vb.reclaimCount = 0
		self.vb.windsCount = 0
		timerCorrosiveInfusionCD:Stop()
		timerBlightReclamationCD:Stop()
		timerNecroticWindsCD:Stop()
		timerBlightReclamationCD:Start(12.1, 1)
		timerIncineratingBlightbreathCD:Start(18.6, 1)
		timerCorrosiveInfusionCD:Start(27.9, 1)
		timerNecrofrostCD:Start(46.1, 1)
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
