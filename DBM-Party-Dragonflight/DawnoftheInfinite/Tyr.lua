local mod	= DBM:NewMod(2526, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198998)
mod:SetEncounterID(2670)
mod:SetUsedIcons(1, 2)
mod:SetHotfixNoticeRev(20231102000000)
mod:SetMinSyncRevision(20231102000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 401248 401482 400641 400649",
	"SPELL_CAST_SUCCESS 400642",
	"SPELL_AURA_APPLIED 403724 400681",
	"SPELL_AURA_REMOVED 400681 400642"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--[[
(ability.id = 401248 or ability.id = 401482 or ability.id = 400641 or ability.id = 400649) and type = "begincast"
 or ability.id = 400642 and (type = "cast" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, fine tune who should be soaking
--TODO, Keep an eye on if the combo stays random order or if it gets normalized later to be static
local warnSparkofTyr								= mod:NewTargetNoFilterAnnounce(400681, 3, nil, "RemoveMagic|Healer")
local warnSiphonOath								= mod:NewCountAnnounce(400642, 3)
local warnSiphonOathOver							= mod:NewEndAnnounce(400642, 1)

local specWarnTitanicBlow							= mod:NewSpecialWarningDefensive(401248, nil, nil, nil, 1, 2)
local specWarnInfiniteAnnihilation					= mod:NewSpecialWarningDodgeCount(401482, nil, nil, nil, 2, 2)
local specWarnDividingStrike						= mod:NewSpecialWarningSoakCount(400641, nil, nil, nil, 2, 2)
local specWarnSparkofTyr							= mod:NewSpecialWarningMoveAway(400681, nil, nil, nil, 1, 2)
local yellSparkofTyr								= mod:NewShortPosYell(400681)
local specWarnGTFO									= mod:NewSpecialWarningGTFO(403724, nil, nil, nil, 1, 8)

--These 3 are shared timers tied to Infinite Hand Technique
local timerTitanicBlowCD							= mod:NewCDCountTimer(8, 401248, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerInfiniteAnnihilationCD					= mod:NewCDCountTimer(8, 401482, nil, nil, nil, 3)
local timerDividingStrikeCD							= mod:NewCDCountTimer(8, 400641, nil, nil, nil, 5)

--Bosses other abilities
local timerSparkofTyrCD								= mod:NewCDCountTimer(60.7, 400681, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSiphonOathCD								= mod:NewCDCountTimer(60.7, 400642, nil, nil, nil, 6, nil, DBM_COMMON_L.DAMAGE_ICON)

mod:AddSetIconOption("SetIconOnSparkofTyr", 400681, true, false, {1, 2})

mod.vb.sparkCount = 0
mod.vb.barrierCount = 0
mod.vb.DebuffIcon = 1
mod.vb.sharedCount = 0--Dividing and Titanic share a count
--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
mod.vb.firstShared = 0
mod.vb.secondShared = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.dividingCount = 0
	self.vb.sparkCount = 0
	self.vb.barrierCount = 0
	self.vb.sharedCount = 0
	--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
	self.vb.firstShared = 0
	self.vb.secondShared = 0
	timerSparkofTyrCD:Start(5.9-delay, 1)
	--Any of these can be first, we don't know which until time of cast
	timerTitanicBlowCD:Start(12.5-delay, 1)
	timerInfiniteAnnihilationCD:Start(12.5-delay, 1)
	timerDividingStrikeCD:Start(12.5-delay, 1)
	timerSiphonOathCD:Start(44.9-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 401248 then
		self.vb.sharedCount = self.vb.sharedCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTitanicBlow:Show(self.vb.sharedCount)
			specWarnTitanicBlow:Play("carefly")
		end
		--Shared Cd between 3 abilities, have to do fancy logic stuffs
		if self.vb.sharedCount == 1 then
			--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
			self.vb.firstShared = 1
			--Still don't know what's 2nd, only that it isn't Blow
			timerDividingStrikeCD:Start(nil, 2)
			timerInfiniteAnnihilationCD:Start(nil, 2)
		elseif self.vb.sharedCount == 2 then
			--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
			self.vb.secondShared = 1
			if self.vb.firstShared == 2 then--We know next is dividing since first was infinite
				timerDividingStrikeCD:Start(nil, 3)
			else--First was dividing so next is infinite
				timerInfiniteAnnihilationCD:Start(nil, 3)
			end
		elseif self.vb.sharedCount == 3 then
			--The 4 cast in combo, is whatever cast 2 was
			if self.vb.secondShared == 1 then
				timerTitanicBlowCD:Start(nil, 4)
			elseif self.vb.secondShared == 2 then
				timerInfiniteAnnihilationCD:Start(nil, 4)
			else
				timerDividingStrikeCD:Start(nil, 4)
			end
		end
	elseif spellId == 401482 then
		self.vb.sharedCount = self.vb.sharedCount + 1
		specWarnInfiniteAnnihilation:Show(self.vb.sharedCount)
		specWarnInfiniteAnnihilation:Play("shockwave")
		--Shared Cd between 3 abilities, have to do fancy logic stuffs
		if self.vb.sharedCount == 1 then
			--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
			self.vb.firstShared = 2
			--Still don't know what's 2nd, only that it isn't Infinite
			timerDividingStrikeCD:Start(nil, 2)
			timerTitanicBlowCD:Start(nil, 2)
		elseif self.vb.sharedCount == 2 then
			--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
			self.vb.secondShared = 2
			if self.vb.firstShared == 1 then--We know next is dividing since first was Blow
				timerDividingStrikeCD:Start(nil, 3)
			else--First was dividing so next is blow
				timerTitanicBlowCD:Start(nil, 3)
			end
		elseif self.vb.sharedCount == 3 then
			--The 4 cast in combo, is whatever cast 2 was
			if self.vb.secondShared == 1 then
				timerTitanicBlowCD:Start(nil, 4)
			elseif self.vb.secondShared == 2 then
				timerInfiniteAnnihilationCD:Start(nil, 4)
			else
				timerDividingStrikeCD:Start(nil, 4)
			end
		end
	elseif spellId == 400641 then
		self.vb.sharedCount = self.vb.sharedCount + 1
		specWarnDividingStrike:Show(self.vb.sharedCount)
		specWarnDividingStrike:Play("helpsoak")
		--Shared Cd between 3 abilities, have to do fancy logic stuffs
		if self.vb.sharedCount == 1 then
			--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
			self.vb.firstShared = 3
			--Still don't know what's 2nd, only that it isn't Dividing
			timerInfiniteAnnihilationCD:Start(nil, 2)
			timerTitanicBlowCD:Start(nil, 2)
		elseif self.vb.sharedCount == 2 then
			--Shared Keys, 1 Titan, 2 Infinite, 3 Dividing
			self.vb.secondShared = 3
			if self.vb.firstShared == 1 then--We know next is infinite since first was Blow
				timerInfiniteAnnihilationCD:Start(nil, 3)
			else--First was dividing so next is blow
				timerTitanicBlowCD:Start(nil, 3)
			end
		elseif self.vb.sharedCount == 3 then
			--The 4 cast in combo, is whatever cast 2 was
			if self.vb.secondShared == 1 then
				timerTitanicBlowCD:Start(nil, 4)
			elseif self.vb.secondShared == 2 then
				timerInfiniteAnnihilationCD:Start(nil, 4)
			else
				timerDividingStrikeCD:Start(nil, 4)
			end
		end
	elseif spellId == 400649 then
		self.vb.DebuffIcon = 1
		self.vb.sparkCount = self.vb.sparkCount + 1
		--Timer not started here, since it's 1 cast per cycle at moment and we start itmer on shield end
--		timerSparkofTyrCD:Start(nil, self.vb.sparkCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 400642 then
		self:SetStage(2)
		self.vb.barrierCount = self.vb.barrierCount + 1
		warnSiphonOath:Show(self.vb.barrierCount)
--		timerSiphonOathCD:Start(nil, self.vb.barrierCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 403724 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 400681 then
		local icon = self.vb.DebuffIcon
		if self.Options.SetIconOnSparkofTyr then
			self:SetIcon(args.destName, icon)
		end
		if args:IsPlayer() then
			specWarnSparkofTyr:Show()
			specWarnSparkofTyr:Play("scatter")
			yellSparkofTyr:Yell(icon, icon)
		end
		warnSparkofTyr:CombinedShow(0.5, args.destName)
		self.vb.DebuffIcon = self.vb.DebuffIcon + 1
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 400681 then
		if self.Options.SetIconOnSparkofTyr then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 400642 then--Siphon ending
		self:SetStage(1)
		self.vb.sharedCount = 0
		self.vb.firstShared = 0
		self.vb.secondShared = 0
		warnSiphonOathOver:Show()
		--Timers same as engage
		timerSparkofTyrCD:Start(6, self.vb.sparkCount+1)
		--Either one of these can be first, we don't know which until time of cast
		timerTitanicBlowCD:Start(12.5, 1)
		timerInfiniteAnnihilationCD:Start(12.5, 1)
		timerDividingStrikeCD:Start(12.5, 1)
		timerSiphonOathCD:Start(45.7, self.vb.barrierCount+1)
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
