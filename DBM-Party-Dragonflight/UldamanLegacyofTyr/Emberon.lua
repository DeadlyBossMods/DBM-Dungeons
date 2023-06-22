local mod	= DBM:NewMod(2476, "DBM-Party-Dragonflight", 2, 1197)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(184422)
mod:SetEncounterID(2558)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 368990 369110 369198 369061",
	"SPELL_CAST_SUCCESS 369049",
	"SPELL_AURA_APPLIED 369110 369198 369043",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 369110 369198 368990 369043"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, detect purging flames ending so timer for next one can start (assuming that is what it's based on)
--TODO, target scan to warn warn for https://www.wowhead.com/beta/spell=369049/seeking-flame targets? doesn't seem like you can do much about it (no interrupts, no splash, just repheal)
--TODO, verify timer resets on boss switching in and out of Puring Flames stage
--TODO, timers were changed, but sine boss is so radically undertuned, don't see 2 of his major abilities literally at all anymore
--[[
(ability.id = 368990 or ability.id = 369110 or ability.id = 369198 or ability.id = 369061) and type = "begincast"
 or ability.id = 369033 and type = "cast"
 or ability.id = 368990 and type = "removebuff"
 or (target.id = 186107 or target.id = 186173) and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 369043
--]]
local warnKeepersRemaining						= mod:NewAddsLeftAnnounce(369033, 3)
local warnUnstableEmbers						= mod:NewTargetNoFilterAnnounce(369110, 3)
local warnSeekingFlame							= mod:NewYouAnnounce(369049, 3, nil, false)--In case you want to know, but not totally practical to enable by default

local specWarnPurgingFlames						= mod:NewSpecialWarningDodgeCount(368990, nil, nil, nil, 2, 2)
local specWarnUnstableEmbers					= mod:NewSpecialWarningMoveAway(369110, nil, nil, nil, 1, 2)
local yellUnstableEmbers						= mod:NewYell(369110)
local yellUnstableEmbersFades					= mod:NewShortFadesYell(369110)
local specWarnSearingClap						= mod:NewSpecialWarningDefensive(369061, nil, nil, nil, 1, 2)
--local specWarnGTFO							= mod:NewSpecialWarningGTFO(340324, nil, nil, nil, 1, 8)

local timerPurgingFlamesCD						= mod:NewCDCountTimer(35, 368990, nil, nil, nil, 6)--Maybe swap for activate keepers instead
local timerUnstableEmbersCD						= mod:NewCDCountTimer(12, 369110, nil, nil, nil, 3)
local timerSearingClapCD						= mod:NewCDCountTimer(23, 369061, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--local berserkTimer							= mod:NewBerserkTimer(600)

--mod:AddRangeFrameOption("8")
--mod:AddInfoFrameOption(361651, true)
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

mod.vb.addsRemaining = 0
mod.vb.embersCount = 0
mod.vb.purgingCount = 0
mod.vb.tankCount = 0

function mod:OnCombatStart(delay)
	self.vb.addsRemaining = 0
	self.vb.embersCount = 0
	self.vb.purgingCount = 0
	self.vb.tankCount = 0
	timerSearingClapCD:Start(4.5-delay, 1)
	timerUnstableEmbersCD:Start(13.1-delay, 1)
	timerPurgingFlamesCD:Start(40.8-delay, 1)--Til actual aoe begin, not infusions 2 seconds before
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
	if spellId == 368990 then
		self.vb.purgingCount = self.vb.purgingCount + 1
		specWarnPurgingFlames:Show(self.vb.purgingCount)
		specWarnPurgingFlames:Play("laserrun")

		--Stop timers here as we enter intermissions.
		timerUnstableEmbersCD:Stop()
		timerSearingClapCD:Stop()
	elseif spellId == 369110 or spellId == 369198 then--110 confirmed, 198 unknown
		self.vb.embersCount = self.vb.embersCount + 1
		timerUnstableEmbersCD:Start(12, 2)
	elseif spellId == 369061 then
		self.vb.tankCount = self.vb.tankCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSearingClap:Show()
			specWarnSearingClap:Play("defensive")
		end
		timerSearingClapCD:Start(nil, self.vb.tankCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 369049 and args:IsPlayer() and self:AntiSpam(3, 1) then
		warnSeekingFlame:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 369110 or spellId == 369198 then--110 confirmed, 198 unknown
		warnUnstableEmbers:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnUnstableEmbers:Show()
			specWarnUnstableEmbers:Play("scatter")
			yellUnstableEmbers:Yell()
			yellUnstableEmbersFades:Countdown(spellId)
		end
	elseif spellId == 369043 then
		self.vb.addsRemaining = self.vb.addsRemaining + 1
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 369110 or spellId == 369198 then
		if args:IsPlayer() then
			yellUnstableEmbersFades:Cancel()
		end
	elseif spellId == 368990 then--Purging Flames over
		self.vb.embersCount = 0--Resetting since it's mostly for timer control
		self.vb.addsRemaining = 0--Reset for good measure
		timerUnstableEmbersCD:Start(1.9, 1)
		timerSearingClapCD:Start(5.5, self.vb.tankCount+1)--Non resetting, for healer/tank CDs
		timerPurgingFlamesCD:Start(42.4, self.vb.purgingCount+1)--Non resetting, for healer/tank CDs
	elseif spellId == 369043 then
		self.vb.addsRemaining = self.vb.addsRemaining - 1
		if self.vb.addsRemaining > 0 then
			warnKeepersRemaining:Show(self.vb.addsRemaining)
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
