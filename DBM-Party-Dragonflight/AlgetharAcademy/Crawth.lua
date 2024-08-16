local mod	= DBM:NewMod(2495, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(191736)
mod:SetEncounterID(2564)
mod:SetHotfixNoticeRev(20221127000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 377034 377004 376997",
	"SPELL_CAST_SUCCESS 377004 376781",
	"SPELL_AURA_APPLIED 376781 181089",
	"SPELL_AURA_REMOVED 376781"
)

--Gale force not in combat log
--TODO, verify target scan
--[[
(ability.id = 377034 or ability.id = 377004 or ability.id = 376997) and type = "begincast"
 or ability.id = 376781
 or ability.id = 181089
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnPlayBall								= mod:NewSpellAnnounce(377182, 2, nil, nil, nil, nil, nil, 2)

local specWarnFirestorm							= mod:NewSpecialWarningDodge(376448, nil, nil, nil, 2, 2)
local specWarnOverpoweringGust					= mod:NewSpecialWarningDodge(377034, nil, nil, nil, 2, 2)
local yellOverpoweringGust						= mod:NewYell(377034)
local specWarnDeafeningScreech					= mod:NewSpecialWarningMoveAwayCount(377004, nil, nil, nil, 2, 2)
local specWarnSavagePeck						= mod:NewSpecialWarningDefensive(376997, nil, nil, nil, 1, 2)

local timerFirestorm							= mod:NewBuffActiveTimer(12, 376448, nil, nil, nil, 1)
local timerOverpoweringGustCD					= mod:NewCDTimer(28.2, 377034, nil, nil, nil, 3)
local timerDeafeningScreechCD					= mod:NewCDCountTimer(22.7, 377004, nil, nil, nil, 3)
local timerSavagePeckCD							= mod:NewCDTimer(13.6, 376997, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Spell queued intoo oblivion often

mod:AddRangeFrameOption(4, 377004)

mod.vb.ScreechCount = 0

function mod:GustTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellOverpoweringGust:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.ScreechCount = 0
	timerSavagePeckCD:Start(3.6-delay)
	timerDeafeningScreechCD:Start(5.4-delay, 1)
	timerOverpoweringGustCD:Start(15.7-delay)
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 377034 then
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "GustTarget", 0.1, 8, true)
		specWarnOverpoweringGust:Show()
		specWarnOverpoweringGust:Play("shockwave")
		timerOverpoweringGustCD:Start()
	elseif spellId == 377004 then
		self.vb.ScreechCount = self.vb.ScreechCount + 1
		specWarnDeafeningScreech:Show(self.vb.ScreechCount)
		if self:IsSpellCaster() then
			specWarnDeafeningScreech:Play("stopcast")
			specWarnDeafeningScreech:ScheduleVoice(1, "scatter")
		else
			specWarnDeafeningScreech:Play("scatter")
		end
		timerDeafeningScreechCD:Start(nil, self.vb.ScreechCount+1)
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(4)
		end
	elseif spellId == 376997 then
		timerSavagePeckCD:Start()
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSavagePeck:Show()
			specWarnSavagePeck:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 377004 then
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	elseif spellId == 376781 then
		specWarnFirestorm:Show()
		specWarnFirestorm:Play("watchstep")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 376781 then
		timerFirestorm:Start()
		--Regardless of time remaining, crawth will cast these coming out of stun
		--Season 4 seems to have swapped these? or spell queue is now happening and either can be cast at 12?
		timerDeafeningScreechCD:Stop()
		timerDeafeningScreechCD:Start(12, 1)
		timerOverpoweringGustCD:Stop()
		timerOverpoweringGustCD:Start(12)--Screech and gust can swap, whatever one is 12 the other is ~17
		timerSavagePeckCD:Stop()--24.6, This one probably restarts too but also gets wierd spell queue and MIGHT not happen
	elseif spellId == 181089 then
		if args:GetDestCreatureID() == 191736 then--Crawth getting buff is play ball starting
			warnPlayBall:Show()
			warnPlayBall:Play("phasechange")
		else--if it's not Crawth, then it's goals activating
			--Swap timer back to same timer with a new count
			local elapsed, total = timerDeafeningScreechCD:GetTime(self.vb.ScreechCount+1)
			if total and total ~= 0 then
				timerDeafeningScreechCD:Stop()--Stop old one
				timerDeafeningScreechCD:Update(elapsed, total, self.vb.ScreechCount+1)--Generate new one with update
			end
			self.vb.ScreechCount = 0
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 376781 then
		timerFirestorm:Stop()
	end
end
