local mod	= DBM:NewMod(2526, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198998)
mod:SetEncounterID(2670)
mod:SetUsedIcons(1, 2)
mod:SetHotfixNoticeRev(20230715000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 401248 401482 400641 400649",
	"SPELL_CAST_SUCCESS 400642",
	"SPELL_AURA_APPLIED 403724 400681",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 400681 400642"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 401248 or ability.id = 401482 or ability.id = 400641 or ability.id = 400649) and type = "begincast"
 or ability.id = 400642 and (type = "cast" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, fine tune who should be soaking
--TODO, Keep an eye on if the combo stays random order or if it gets normalized later to be static for Titanic and Dividing
local warnSparkofTyr								= mod:NewTargetNoFilterAnnounce(400649, 3, nil, "RemoveMagic|Healer")
local warnSiphonOath								= mod:NewCountAnnounce(400642, 3)
local warnSiphonOathOver							= mod:NewEndAnnounce(400642, 1)

local specWarnTitanicBlow							= mod:NewSpecialWarningDefensive(401248, nil, nil, nil, 1, 2)
local specWarnInfiniteAnnihilation					= mod:NewSpecialWarningDodgeCount(401482, nil, nil, nil, 2, 2)
local specWarnDividingStrike						= mod:NewSpecialWarningSoakCount(400641, nil, nil, nil, 2, 2)
local specWarnSparkofTyr							= mod:NewSpecialWarningMoveAway(400649, nil, nil, nil, 1, 2)
local yellSparkofTyr								= mod:NewShortPosYell(400649)
local specWarnGTFO									= mod:NewSpecialWarningGTFO(403724, nil, nil, nil, 1, 8)

local timerTitanicBlowCD							= mod:NewCDCountTimer(16, 401248, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerInfiniteAnnihilationCD					= mod:NewCDCountTimer(60.7, 401482, nil, nil, nil, 3)
local timerDividingStrikeCD							= mod:NewCDCountTimer(16, 400641, nil, nil, nil, 5)
local timerSparkofTyrCD								= mod:NewCDCountTimer(60.7, 400649, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSiphonOathCD								= mod:NewCDCountTimer(60.7, 400642, nil, nil, nil, 6, nil, DBM_COMMON_L.DAMAGE_ICON)

mod:AddSetIconOption("SetIconOnSparkofTyr", 400649, true, false, {1, 2})

mod.vb.annihilationCount = 0
mod.vb.sparkCount = 0
mod.vb.barrierCount = 0
mod.vb.DebuffIcon = 1
mod.vb.sharedCount = 0--Dividing and Titanic share a count

function mod:OnCombatStart(delay)
	self.vb.annihilationCount = 0
	self.vb.dividingCount = 0
	self.vb.sparkCount = 0
	self.vb.barrierCount = 0
	self.vb.sharedCount = 0--0 = Not yet known, 1 = D, T, D, 2 = T, D, T
	timerSparkofTyrCD:Start(6-delay, 1)
	timerInfiniteAnnihilationCD:Start(12.5-delay, 1)
	--Either one of these can be first, we don't know which until time of cast
	timerDividingStrikeCD:Start(20.5-delay, 1)
	timerTitanicBlowCD:Start(20.5-delay, 1)
	timerSiphonOathCD:Start(45.7-delay, 1)
end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 401248 then
		self.vb.sharedCount = self.vb.sharedCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTitanicBlow:Show(self.vb.sharedCount)
			specWarnTitanicBlow:Play("carefly")
		end
		--Shared Cd, alternating abilities. Dividing is next after titanic
		if self.vb.sharedCount < 3 then
			timerDividingStrikeCD:Start(nil, self.vb.sharedCount+1)
		end
	elseif spellId == 401482 then
		self.vb.annihilationCount = self.vb.annihilationCount + 1
		specWarnInfiniteAnnihilation:Show(self.vb.annihilationCount)
		specWarnInfiniteAnnihilation:Play("shockwave")
		--Timer not started here, since it's 1 cast per cycle at moment and we start itmer on shield end
--		timerInfiniteAnnihilationCD:Start(nil, self.vb.annihilationCount+1)
	elseif spellId == 400641 then
		self.vb.sharedCount = self.vb.sharedCount + 1
		specWarnDividingStrike:Show(self.vb.sharedCount)
		specWarnDividingStrike:Play("helpsoak")
		--Shared Cd, alternating abilities. titanic is next after dividing
		if self.vb.sharedCount < 3 then
			timerTitanicBlowCD:Start(nil, self.vb.sharedCount+1)
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
		--Upon ending, boss has two possible combos for abilites since it seems dividing and titanic are interchangable
		--The two shared abilities will be 3 casts where he does ability + 8 ability + 8 ability
		--This comes out as one of following
		--Spark, Infinite, Dividing, Titanic Dividing
		--Spark, Infinite, Titanic, Dividing, Titanic
		self.vb.sharedCount = 0
		warnSiphonOathOver:Show()
		--Timers same as engage
		timerSparkofTyrCD:Start(6, self.vb.sparkCount+1)
		timerInfiniteAnnihilationCD:Start(12.5, self.vb.annihilationCount+1)
		--Either one of these can be first, we don't know which until time of cast
		timerDividingStrikeCD:Start(20.5, 1)--Count reset on the shared low Cd abiliteis that are a 3 strike combo
		timerTitanicBlowCD:Start(20.5, 1)--Count reset on the shared low Cd abiliteis that are a 3 strike combo
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

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
