if DBM:GetTOC() < 100105 then return end
local mod	= DBM:NewMod(2528, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198996)
mod:SetEncounterID(2667)
mod:SetUsedIcons(1, 2)
--mod:SetHotfixNoticeRev(20221015000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 405696 405431 414303",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 404141",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 404141"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 405696 or ability.id = 405431 or ability.id = 414303 or ability.id = 414307) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, more data, but I need to figure out what causes the fluke non 30.3 timers (one higher by 7 seconds, and one lower by 7 seconds)
local warnChronoFaded								= mod:NewTargetCountAnnounce(405696, 3)

local specWarnChronofaded							= mod:NewSpecialWarningMoveTo(405696, nil, nil, nil, 1, 2)
local yellChronofaded								= mod:NewShortPosYell(405696)
local yellChronofadedFades							= mod:NewIconFadesYell(405696)
local specWarnFragmentsofTime						= mod:NewSpecialWarningDodgeCount(405431, nil, nil, nil, 2, 2)
local specWarnUnwind								= mod:NewSpecialWarningDefensive(414303, nil, nil, nil, 1, 2)
--local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

local timerChronofadedCD							= mod:NewCDCountTimer(30.3, 405696, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerFragmentsofTimeCD						= mod:NewCDCountTimer(30.3, 405431, nil, nil, nil, 3)
local timerUnwindCD									= mod:NewCDCountTimer(30.3, 414303, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddSetIconOption("SetIconOnChronoFaded", 405696, true, false, {1, 2})

local fastTime = DBM:GetSpellInfo(403912)
mod.vb.DebuffIcon = 1
mod.vb.fadedCount = 0
mod.vb.fragmentsCount = 0
mod.vb.unwindCount = 0

function mod:OnCombatStart(delay)
	self.vb.fadedCount = 0
	self.vb.fragmentsCount = 0
	self.vb.unwindCount = 0
	timerUnwindCD:Start(5.9-delay, 1)
	timerFragmentsofTimeCD:Start(15.6-delay, 1)
	timerChronofadedCD:Start(30.2-delay, 1)
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
	if spellId == 405696 then
		self.vb.DebuffIcon = 1
		self.vb.fadedCount = self.vb.fadedCount + 1
		if self.vb.fadedCount == 2 then
			timerChronofadedCD:Start(37.2, self.vb.fadedCount+1)
		else
			timerChronofadedCD:Start(30.3, self.vb.fadedCount+1)
		end
	elseif spellId == 405431 then
		self.vb.fragmentsCount = self.vb.fragmentsCount + 1
		specWarnFragmentsofTime:Show(self.vb.fragmentsCount)
		specWarnFragmentsofTime:Play("watchorb")
		timerFragmentsofTimeCD:Start(nil, self.vb.fragmentsCount+1)
	elseif spellId == 414303 then
		self.vb.unwindCount = self.vb.unwindCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnUnwind:Show()
			specWarnUnwind:Play("defensive")
		end
		if self.vb.unwindCount == 3 then
			timerUnwindCD:Start(23.8, self.vb.unwindCount+1)
		else
			timerUnwindCD:Start(30.3, self.vb.unwindCount+1)
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 387691 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 404141 then
		local icon = self.vb.DebuffIcon
		if self.Options.SetIconOnChronoFaded then
			self:SetIcon(args.destName, icon)
		end
		if args:IsPlayer() then
			specWarnChronofaded:Show(fastTime)
			specWarnChronofaded:Play("targetyou")
			yellChronofaded:Yell(icon, icon)
			yellChronofadedFades:Countdown(spellId, nil, icon)
		end
		warnChronoFaded:CombinedShow(0.5, args.destName)
		self.vb.DebuffIcon = self.vb.DebuffIcon + 1
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 404141 then
		if self.Options.SetIconOnChronoFaded then
			self:SetIcon(args.destName, 0)
		end
		if args:IsPlayer() then
			yellChronofadedFades:Cancel()
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
