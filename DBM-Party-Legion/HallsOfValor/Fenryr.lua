local mod	= DBM:NewMod(1487, "DBM-Party-Legion", 4, 721)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(95674, 99868)--First engage, Second engage
mod:SetEncounterID(1807)
mod:DisableEEKillDetection()--ENCOUNTER_END fires a wipe when fenryr casts stealth and runs to new location (P2)
mod:SetHotfixNoticeRev(20230306000000)
--mod.sendMainBossGUID = true--Boss does lots of on fly timer adjustments, lets not overwhelm external handlers just yet

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 196838 196543 197558 196512",
	"SPELL_CAST_SUCCESS 196567 196512 207707",
	"SPELL_AURA_APPLIED 197556 196838",
	"SPELL_AURA_REMOVED 197556 196838",
	"UNIT_DIED"
)

--[[
(ability.id = 196838 or ability.id = 196543 or ability.id = 197558) and type = "begincast"
 or (ability.id = 196567 or ability.id = 196512 or ability.id = 207707) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnLeap							= mod:NewTargetAnnounce(197556, 2)
local warnPhase2						= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)
local warnFixate						= mod:NewTargetAnnounce(196838, 2)
local warnFixateEnded					= mod:NewEndAnnounce(196838, 1)
local warnClawFrenzy					= mod:NewSpellAnnounce(196512, 3, nil, nil, 2)

local specWarnLeap						= mod:NewSpecialWarningMoveAway(197556, nil, nil, nil, 1, 2)
local yellLeap							= mod:NewYell(197556)
local specWarnHowl						= mod:NewSpecialWarningCast(196543, "SpellCaster", nil, nil, 1, 2)
local specWarnFixate					= mod:NewSpecialWarningRun(196838, nil, nil, nil, 4, 2)
local specWarnWolves					= mod:NewSpecialWarningSwitch("ej12600", "Tank", nil, nil, 1, 2)

local timerLeapCD						= mod:NewCDTimer(31, 197556, nil, nil, nil, 3)--31-36
local timerClawFrenzyCD					= mod:NewCDCountTimer(9.7, 196512, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)--it is 10 sec, but is spell queued half the time
local timerHowlCD						= mod:NewCDTimer(31.5, 196543, nil, "SpellCaster", nil, 2)--32ish unless spell queued
local timerScentCD						= mod:NewCDTimer(37.6, 196838, nil, nil, nil, 3)--seems 37 now, up from old 34
local timerWolvesCD						= mod:NewCDTimer(33.8, "ej12600", nil, nil, nil, 1, 199184)--33.8-56

mod:AddRangeFrameOption(10, 197556)

mod.vb.clawCount = 0

function mod:FixateTarget(targetname, uId)
	if not targetname then return end
	if self:AntiSpam(5, targetname) then
		if targetname == UnitName("player") then
			specWarnFixate:Show()
			specWarnFixate:Play("runaway")
			specWarnFixate:ScheduleVoice(1, "keepmove")
		else
			warnFixate:Show(targetname)
		end
	end
end

--Even though wolves timer is all over the place, it's NOT affected by any of the spell queue ICDs, which makes me wonder if wolves just isn't a timer at all but health trigger?
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	--Abilities that exist in P1 and P2
	if timerClawFrenzyCD:GetRemaining(self.vb.clawCount+1) < ICD then
		local elapsed, total = timerClawFrenzyCD:GetTime(self.vb.clawCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerClawFrenzyCD extended by: "..extend, 2)
		timerClawFrenzyCD:Update(elapsed, total+extend, self.vb.clawCount+1)
	end
	if timerLeapCD:GetRemaining() < ICD then
		local elapsed, total = timerLeapCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerLeapCD extended by: "..extend, 2)
		timerLeapCD:Update(elapsed, total+extend)
	end
	if timerHowlCD:GetRemaining() < ICD then
		local elapsed, total = timerHowlCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerHowlCD extended by: "..extend, 2)
		timerHowlCD:Update(elapsed, total+extend)
	end
	--Specific Phase ability timers
	if self.vb.phase == 2 then--Abilities that only exist in phase 2
		if timerScentCD:GetRemaining() < ICD then
			local elapsed, total = timerScentCD:GetTime()
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerScentCD extended by: "..extend, 2)
			timerScentCD:Update(elapsed, total+extend)
		end
	end
end

function mod:OnCombatStart(delay)
	self.vb.clawCount = 0
	self:SetWipeTime(5)
	--If howl isn't cast within that 1 second of cooldown window before leap comes off CD, leap takes higher priority and is cast instead and flips order rest of pull
	--Claw frenzy can be 2nd or 3rd as well, depending on spell queue. for most part initial timers can't be fully trusted until first 2 of 3 casts happen and correct them
	timerHowlCD:Start(5-delay)
	timerLeapCD:Start(6-delay)
	timerClawFrenzyCD:Start(17-delay, 1)
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 196838 then
		timerScentCD:Start()
		self:BossTargetScanner(99868, "FixateTarget", 0.2, 12, true, nil, nil, nil, true)--Target scanning used to grab target 2-3 seconds faster. Doesn't seem to anymore?
		updateAllTimers(self, 18.1)--18.1-19.2 based on distance to return to tank
	elseif spellId == 196543 then
		specWarnHowl:Show()
		specWarnHowl:Play("stopcast")
		timerHowlCD:Start()
		updateAllTimers(self, 4.8)
	elseif spellId == 197558 then
		timerLeapCD:Start()
		updateAllTimers(self, 10.9)
	elseif spellId == 196512 and self:AntiSpam(3, 1) then
		self.vb.clawCount = self.vb.clawCount + 1
		warnClawFrenzy:Show(self.vb.clawCount)
		timerClawFrenzyCD:Start(self.vb.phase == 2 and 8.5 or 9.7, self.vb.clawCount+1)
		updateAllTimers(self, 3.8)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 196567 then--Stealth (boss retreat)
		--Stop all timers but not combat
		for _, v in ipairs(self.timers) do
			v:Stop()
		end
		--Artificially set no wipe to 30 minutes
		self:SetWipeTime(1800)
		--Scan for Boss to be re-enraged
		self:RegisterShortTermEvents(
			"ENCOUNTER_START"
		)
	elseif spellId == 196512 and self:AntiSpam(3, 1) then
		self.vb.clawCount = self.vb.clawCount + 1
		warnClawFrenzy:Show(self.vb.clawCount)
		timerClawFrenzyCD:Start(nil, self.vb.clawCount+1)
		updateAllTimers(self, 3.8)
	elseif spellId == 207707 and self:AntiSpam(2, 2) then--Wolves spawning out of stealth
		specWarnWolves:Show()
		specWarnWolves:Play("killmob")
--		timerWolvesCD:Start()--Too much variation that doesn't look as easily correctable as other timers, maybe it's health based outside of initial set?
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 197556 then
		warnLeap:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnLeap:Show()
			specWarnLeap:Play("runout")
			yellLeap:Yell()
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(10)
			end
		end
	elseif spellId == 196838 then
		--Backup if target scan failed
		if self:AntiSpam(5, args.destName) then
			if args:IsPlayer() then
				specWarnFixate:Show()
				specWarnFixate:Play("runaway")
				specWarnFixate:ScheduleVoice(1, "keepmove")
			else
				warnFixate:Show(args.destName)
			end
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 197556 and args:IsPlayer() and self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	elseif spellId == 196838 and args:IsPlayer() then
		warnFixateEnded:Show()
	end
end

function mod:ENCOUNTER_START(encounterID)
	--Re-engaged, kill scans and long wipe time
	if encounterID == 1807 and self:IsInCombat() then
		self.vb.clawCount = 0
--		self:SetWipeTime(5)
--		self:UnregisterShortTermEvents()
		warnPhase2:Show()
		warnPhase2:Play("ptwo")
		timerHowlCD:Start(4.4)
		timerWolvesCD:Start(6)
		timerLeapCD:Start(9.3)--9.3-15
		timerClawFrenzyCD:Start(12, 1)--12-45 (massive variation cause if it's not cast immediately it gets spell queued behind leap, howl and then casts at 22-25 unless scent also spell queues it then it's 42-45sec ater p2 start
		timerScentCD:Start(20.2)--20-27.8
	end
end

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 99868 then
		DBM:EndCombat(self)
	end
end
