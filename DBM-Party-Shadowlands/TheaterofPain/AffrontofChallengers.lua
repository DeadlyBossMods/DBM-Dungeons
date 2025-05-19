local mod	= DBM:NewMod(2397, "DBM-Party-Shadowlands", 6, 1187)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(164451, 164463, 164461)--Dessia, Paceran, Sathel
mod:SetEncounterID(2391)
mod:SetHotfixNoticeRev(20220416000000)
mod:SetBossHPInfoToHighest()
mod:SetZone(2293)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1215741 1215738 1215600 320069 333231 320182",--320063
--	"SPELL_CAST_SUCCESS 320272 320248 333222",--320063, 333540
	"SPELL_AURA_APPLIED 320069 320272 333231 333222 1215600",--333540 326892 324085 320293
	"SPELL_PERIODIC_DAMAGE 320180",
	"SPELL_PERIODIC_MISSED 320180",
	"UNIT_DIED"
)

--[[
(ability.id = 1215741 or ability.id = 1215738 or ability.id = 1215600 or ability.id = 320069 or ability.id = 333231 or ability.id = 320182) and type = "begincast"
 or (target.id = 164451 or target.id = 164463 or target.id = 164461) and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Dessia the Decapitator
mod:AddTimerLine(DBM:EJ_GetSectionInfo(21582))
local warnMortalStrike					= mod:NewTargetNoFilterAnnounce(320069, 3, nil, "Tank|Healer")

local specWarnMightySmash				= mod:NewSpecialWarningCount(1215741, nil, nil, nil, 2, 2)

local timerMightySmashCD				= mod:NewCDCountTimer(15.8, 1215741, nil, nil, nil, 2, nil)--Ultimate
local timerMortalStrikeCD				= mod:NewCDCountTimer(17, 320069, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--17-21.8--delays happen from specials only
--Paceran the Virulent
mod:AddTimerLine(DBM:EJ_GetSectionInfo(21581))
local specWarnDecayingBreath			= mod:NewSpecialWarningDodgeCount(1215738, nil, nil, nil, 2, 2)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(320180, nil, nil, nil, 1, 8)

local timerNoxiousSporeCD				= mod:NewCDCountTimer(15.8, 320180, nil, nil, nil, 3)--Ultimate
local timerDecayingBreathCD				= mod:NewCDCountTimer(14.6, 1215738, nil, nil, nil, 3)--14.6 or 29.9 when casts are skipped due to specials
--Sathel the Accursed
mod:AddTimerLine(DBM:EJ_GetSectionInfo(21591))
local warnSearingDeath					= mod:NewTargetAnnounce(333231, 3)

local specWarnSearingDeath				= mod:NewSpecialWarningMoveAway(333231, nil, nil, nil, 1, 2)
local yellSearingDeath					= mod:NewYell(333231)
local specWarnWitheringTouch			= mod:NewSpecialWarningDispel(1215600, "RemoveMagic", nil, nil, 1, 2)

local timerSearingDeathCD				= mod:NewCDCountTimer(42.5, 333231, nil, nil, nil, 3)--Ultimate
local timerWitheringTouchCD				= mod:NewVarCountTimer("v17-25.3", 1215600, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)--No clean way to correct so we'll use variance timer

--General
mod.vb.willCount = 0
--Dessia
mod.vb.smashCount = 0
mod.vb.mortalStrikeCount = 0
--Paceran
mod.vb.sporeCount = 0
mod.vb.breathCount = 0
--Sathel
mod.vb.deathCount = 0
mod.vb.dispelCount = 0

function mod:StartEngageTimers(guid, cid, delay)
	if cid == 164451 then--Dessia the Dec
		timerMightySmashCD:Start(10.5-delay, 1, guid)
		timerMortalStrikeCD:Start(3.3-delay, 1, guid)
	elseif cid == 164463 then--Paceran the Vir
		timerNoxiousSporeCD:Start(20.6-delay, 1, guid)
		timerDecayingBreathCD:Start(5.1-delay, 1, guid)
	elseif cid == 164461 then--Sathel the Acc
		timerSearingDeathCD:Start(30.3-delay, 1, guid)
		timerWitheringTouchCD:Start(6-delay, 1, guid)
	end
end

function mod:OnCombatStart(delay)
	self.vb.willCount = 0
	self.vb.smashCount = 0
	self.vb.mortalStrikeCount = 0
	self.vb.sporeCount = 0
	self.vb.breathCount = 0
	self.vb.deathCount = 0
	self.vb.dispelCount = 0
	self:RegisterBossUnitScan(2)--Delay engage timer to collect guids for nameplate timers
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 1215741 then
		self.vb.smashCount = self.vb.smashCount + 1
		specWarnMightySmash:Show(self.vb.smashCount)
		specWarnMightySmash:Play("aesoon")
		local timer = self.vb.willCount == 2 and 15.8 or self.vb.willCount == 1 and 29.1 or 43.7
		timerMightySmashCD:Start(timer, self.vb.smashCount+1, args.sourceGUID)
		--If < 4.5 seconds remaining on mortal strike, it'll be delayed until after mighty smash
		if timerMortalStrikeCD:GetRemaining(self.vb.mortalStrikeCount+1, args.sourceGUID) < 4.5 then
			timerMortalStrikeCD:HardStop(args.sourceGUID)--Hard stop to make sure we absolutely do nameplate cleanup
			timerMortalStrikeCD:Start(4.5, self.vb.mortalStrikeCount+1, args.sourceGUID)
		end
	elseif spellId == 1215738 then
		self.vb.breathCount = self.vb.breathCount + 1
		specWarnDecayingBreath:Show(self.vb.breathCount)
		specWarnDecayingBreath:Play("breathsoon")
		timerDecayingBreathCD:Start(nil, self.vb.breathCount+1, args.sourceGUID)
	elseif spellId == 320069 then
		self.vb.mortalStrikeCount = self.vb.mortalStrikeCount + 1
		timerMortalStrikeCD:Start(nil, self.vb.mortalStrikeCount+1, args.sourceGUID)
	elseif spellId == 333231 then
		self.vb.deathCount = self.vb.deathCount + 1
		local timer = self.vb.willCount == 2 and 14.6 or self.vb.willCount == 1 and 27.9 or 41.3
		timerSearingDeathCD:Start(timer, self.vb.deathCount+1, args.sourceGUID)--self.vb.deathCount+1
	elseif spellId == 320182 then
		self.vb.sporeCount = self.vb.sporeCount + 1
		local timer = self.vb.willCount == 2 and 14.6 or self.vb.willCount == 1 and 27.9 or 42.6
		timerNoxiousSporeCD:Start(timer, self.vb.sporeCount+1, args.sourceGUID)
		--Breath timer restarts
		timerDecayingBreathCD:HardStop(args.sourceGUID)
		timerDecayingBreathCD:Start(14.6, self.vb.breathCount+1, args.sourceGUID)
	elseif spellId == 1215600 then
		self.vb.dispelCount = self.vb.dispelCount + 1
		timerWitheringTouchCD:Start(nil, self.vb.dispelCount+1, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 320069 then
		warnMortalStrike:Show(args.destName)
	elseif spellId == 333231 then
		if args:IsPlayer() then
			specWarnSearingDeath:Show()
			specWarnSearingDeath:Play("runout")
			yellSearingDeath:Yell()
		else
			warnSearingDeath:Show(args.destName)
		end
	elseif spellId == 1215600 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") then
		specWarnWitheringTouch:Show(args.destName)
		specWarnWitheringTouch:Play("helpdispel")
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 320180 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 164451 then--Dessia the Decapitator
		self.vb.willCount = self.vb.willCount + 1
		timerMortalStrikeCD:HardStop(args.destGUID)
		timerMightySmashCD:HardStop(args.destGUID)
	elseif cid == 164463 then--Paceran the Virulent
		self.vb.willCount = self.vb.willCount + 1
		timerNoxiousSporeCD:HardStop(args.destGUID)
		timerDecayingBreathCD:HardStop(args.destGUID)
	elseif cid == 164461 then--Sathel the Accursed
		self.vb.willCount = self.vb.willCount + 1
		timerSearingDeathCD:HardStop(args.destGUID)
		timerWitheringTouchCD:HardStop(args.destGUID)
	end
end
