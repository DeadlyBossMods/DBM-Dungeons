local mod	= DBM:NewMod(2528, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge"--No Follower dungeon

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198996)
mod:SetEncounterID(2667)
mod:SetUsedIcons(1, 2)
mod:SetHotfixNoticeRev(20231102000000)
mod:SetMinSyncRevision(20231102000000)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 405696 405431",--414303
	"SPELL_AURA_APPLIED 404141",
	"SPELL_AURA_REMOVED 404141"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--[[
(ability.id = 405696 or ability.id = 405431 or ability.id = 414303 or ability.id = 414307) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, more data, but I need to figure out what causes the fluke non 30.3 timers (one higher by 7 seconds, and one lower by 7 seconds)
--TODO, Add RP timer, still missing for this boss
--NOTE: 10.2 seems to have utterly deleted "Unwind" from encounter. For now its commented but kept in case this is an error or still around but not noted
local warnChronoFaded								= mod:NewTargetCountAnnounce(405696, 3)

local specWarnChronofaded							= mod:NewSpecialWarningMoveTo(405696, nil, nil, nil, 1, 2)
local yellChronofaded								= mod:NewShortPosYell(405696)
local yellChronofadedFades							= mod:NewIconFadesYell(405696)
local specWarnFragmentsofTime						= mod:NewSpecialWarningDodgeCount(405431, nil, nil, nil, 2, 2)
--local specWarnUnwind								= mod:NewSpecialWarningDefensive(414303, nil, nil, nil, 1, 2)
--local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

--local timerRP										= mod:NewRPTimer(8)
local timerChronofadedCD							= mod:NewCDCountTimer(30.3, 405696, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerFragmentsofTimeCD						= mod:NewCDCountTimer(30.3, 405431, nil, nil, nil, 3)
--local timerUnwindCD									= mod:NewCDCountTimer(30.3, 414303, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddSetIconOption("SetIconOnChronoFaded", 405696, true, false, {1, 2})

local fastTime = DBM:GetSpellInfo(403912)
mod.vb.DebuffIcon = 1
mod.vb.fadedCount = 0
mod.vb.fragmentsCount = 0
--mod.vb.unwindCount = 0

function mod:OnCombatStart(delay)
	self.vb.fadedCount = 0
	self.vb.fragmentsCount = 0
--	self.vb.unwindCount = 0
--	timerUnwindCD:Start(5.9-delay, 1)
	timerFragmentsofTimeCD:Start(15.6-delay, 1)
	timerChronofadedCD:Start(30.2-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 405696 then
		self.vb.DebuffIcon = 1
		self.vb.fadedCount = self.vb.fadedCount + 1
		timerChronofadedCD:Start(nil, self.vb.fadedCount+1)
	elseif spellId == 405431 then
		self.vb.fragmentsCount = self.vb.fragmentsCount + 1
		specWarnFragmentsofTime:Show(self.vb.fragmentsCount)
		specWarnFragmentsofTime:Play("watchorb")
		timerFragmentsofTimeCD:Start(nil, self.vb.fragmentsCount+1)
--	elseif spellId == 414303 then
--		self.vb.unwindCount = self.vb.unwindCount + 1
--		if self:IsTanking("player", "boss1", nil, true) then
--			specWarnUnwind:Show()
--			specWarnUnwind:Play("defensive")
--		end
--		timerUnwindCD:Start(nil, self.vb.unwindCount+1)
	end
end

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
		warnChronoFaded:CombinedShow(0.5, self.vb.fadedCount, args.destName)
		self.vb.DebuffIcon = self.vb.DebuffIcon + 1
	end
end

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
