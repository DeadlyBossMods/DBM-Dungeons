local mod	= DBM:NewMod(2331, "DBM-Party-BfA", 11, 1178)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(150396, 144249, 150397)
mod:SetEncounterID(2260)
mod:SetBossHPInfoToHighest()
mod:SetZone(2097)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 291865 291928 292264 291613",
	"SPELL_CAST_SUCCESS 291626 283551 283143 292750",
--	"SPELL_AURA_APPLIED 283143",
--	"SPELL_AURA_REMOVED 283143",
	"UNIT_DIED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3"
--	"UNIT_SPELLCAST_START boss1 boss2 boss3"
)

--TODO, warn tank if not in range in p2 for Ninety-Nine?
--TODO, recalibrate in stage 2 still has no event for it. I can't be assed to schedule a repeater for it since I can't verify the repeater by any means
--[[
(ability.id = 291865 or ability.id = 291928 or ability.id = 292264 or ability.id = 291613) and type = "begincast"
 or (ability.id = 291626 or ability.id = 283551 or ability.id = 283143 or ability.id = 292750) and type = "cast"
 or (target.id = 150396 or target.id = 144249) and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Stage One: Aerial Unit R-21/X
local warnMegaZap					= mod:NewTargetCountAnnounce(291928, 2, nil, nil, nil, nil, nil, nil, true)
local warnRecalibrate				= mod:NewSpellAnnounce(291865, 2, nil, nil, nil, nil, 2)
local warnCuttingBeam				= mod:NewSpellAnnounce(291626, 2)
--Stage Two: Omega Buster
local warnPhase2					= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, 2)
local warnMagnetoArmSoon			= mod:NewSoonAnnounce(283143, 2)

--Stage One: Aerial Unit R-21/X
--local specWarnRecalibrate			= mod:NewSpecialWarningDodge(291865, nil, nil, nil, 2, 2)
local specWarnMegaZap				= mod:NewSpecialWarningYouCount(291928, nil, nil, nil, 2, 2)
local yellMegaZap					= mod:NewCountYell(291928)
local specWarnTakeOff				= mod:NewSpecialWarningRunCount(291613, nil, nil, nil, 4, 2)
--Stage Two: Omega Buster
local specWarnMagnetoArm			= mod:NewSpecialWarningRunCount(283143, nil, nil, nil, 4, 2)
local specWarnHardMode				= mod:NewSpecialWarningCount(292750, nil, nil, nil, 3, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

--Stage One: Aerial Unit R-21/X
local timerRecalibrateCD			= mod:NewCDCountTimer("v13.4-16.3", 291865, nil, nil, nil, 3)
local timerMegaZapCD				= mod:NewCDCountTimer(15.8, 291928, nil, nil, nil, 3)
local timerTakeOffCD				= mod:NewCDCountTimer(35.2, 291613, nil, nil, nil, 6)
local timerCuttingBeam				= mod:NewCastTimer(6, 291626, nil, nil, nil, 3)
--Stage Two: Omega Buster
local timerMagnetoArmCD				= mod:NewCDCountTimer(61.9, 283143, nil, nil, nil, 2)
local timerHardModeCD				= mod:NewCDCountTimer(42.5, 292750, nil, nil, nil, 5, nil, DBM_COMMON_L.MYTHIC_ICON)--42.5-46.1

mod.vb.recalibrateCount = 0
mod.vb.zapCount = 0
mod.vb.takeOffCount = 0
mod.vb.armCount = 0
mod.vb.hardModeCount = 0
local P1RecalibrateTimers = {5.9, 12, 27.9, 15.6, 19.4, 15.5}
--All hard mode timers, do they differ if hard mode isn't active?
--5.9, 13.3, 27.9, 15.6, 20.7
--5.9, 13.3, 28.8, 17.0, 19.4
--5.9, 13.3, 31.4, 16.9, 20.7

function mod:ZapTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") and self:AntiSpam(5, 5) then
		specWarnMegaZap:Show(self.vb.zapCount)
		specWarnMegaZap:Play("runout")
		yellMegaZap:Yell(self.vb.zapCount)
	else
		warnMegaZap:Show(self.vb.zapCount, targetname)
	end
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.recalibrateCount = 0
	self.vb.zapCount = 0
	self.vb.takeOffCount = 0
	self.vb.armCount = 0
	self.vb.hardModeCount = 0
	timerRecalibrateCD:Start(5.9-delay, 1)
	timerMegaZapCD:Start(8.3-delay, 1)--8.3-9.7
	timerTakeOffCD:Start("v30.2-35.2", 1)
end

function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 291865 then
		self.vb.recalibrateCount = self.vb.recalibrateCount + 1
		warnRecalibrate:Show()
		warnRecalibrate:Play("watchorb")
		local timer = P1RecalibrateTimers[self.vb.recalibrateCount+1] or 12
		if timer and timer > 0 then
			timerRecalibrateCD:Start(timer, self.vb.recalibrateCount+1)
		end
	elseif spellId == 291928 or spellId == 292264 then--Stage 1, Stage 2
		self.vb.zapCount = self.vb.zapCount + 1
		--specWarnMegaZap:Show()
		--specWarnMegaZap:Play("watchstep")
		if spellId == 292264 then--Stage 2
			if self.vb.zapCount % 3 == 0 then
				--14.8, 3.5, 3.5, 28.6, 3.5, 3.5, 23.4, 3.5, 3.5, 23.3, 3.5, 3.5 --BFA
				--14.8, 3.5, 3.5, 28.2, 3.5, 3.5 --BFA
				--11.2, 3.5, 3.5, 27.1, 3.5, 3.5, 23.3, 3.5, 3.5" --TWW S2
				timerMegaZapCD:Start(self.vb.zapCount == 3 and 26.9 or 23.3, self.vb.zapCount+1)
			else
				timerMegaZapCD:Start(3.5, self.vb.zapCount+1)
			end
		else--Stage 1
			timerMegaZapCD:Start(15.8, self.vb.zapCount+1)--15-20, but not sequencable enough because it differs pull from pull
			--"Mega-Zap-291928-npc:150396-0000322FAF = pull:9.9, 15.4, 18.1, 16.3, 20.6, 15.5, 19.9", --TWW S2. We do timer correction with take off
		end
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ZapTarget", 0.1, 7, true)
	elseif spellId == 291613 then
		self.vb.takeOffCount = self.vb.takeOffCount + 1
		specWarnTakeOff:Show(self.vb.takeOffCount)
		specWarnTakeOff:Play("justrun")
		timerTakeOffCD:Start(nil, self.vb.takeOffCount+1)
		--Restart couple timers
		timerMegaZapCD:Stop()
		timerMegaZapCD:Start(12, self.vb.zapCount+1)
		timerRecalibrateCD:Stop()
		timerRecalibrateCD:Start("v16.5-20.3", self.vb.recalibrateCount+1)--This will either be 16.5-17 or 20.3 if boss manages to queue up a second megazap
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 291626 then
		warnCuttingBeam:Show()
		timerCuttingBeam:Start()
	elseif spellId == 283551 then
		warnMagnetoArmSoon:Show()
	elseif spellId == 283143 then
		self.vb.armCount = self.vb.armCount + 1
		specWarnMagnetoArm:Show(self.vb.armCount)
		specWarnMagnetoArm:Play("justrun")
		specWarnMagnetoArm:ScheduleVoice(1.5, "keepmove")
		timerMagnetoArmCD:Start(nil, self.vb.armCount+1)
	elseif spellId == 292750 then--H.A.R.D.M.O.D.E.
		self.vb.hardModeCount = self.vb.hardModeCount + 1
		specWarnHardMode:Show(self.vb.hardModeCount)
		specWarnHardMode:Play("stilldanger")
		timerHardModeCD:Start(nil, self.vb.hardModeCount+1)
	end
end


function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 150396 then--Aerial Unit R-21/X
		self:SetStage(2)
		warnPhase2:Show()
		warnPhase2:Play("ptwo")
		timerRecalibrateCD:Stop()
		timerMegaZapCD:Stop()
		timerTakeOffCD:Stop()
		timerCuttingBeam:Stop()
	elseif cid == 144249 then--Omega Buster
		self:SetStage(3)
		timerRecalibrateCD:Stop()
		timerMegaZapCD:Stop()
		timerMagnetoArmCD:Stop()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 296323 then--Activate Omega Buster (Needed? Stage 2 should already be started by stage 1 boss death)
		self.vb.zapCount = 0
		self.vb.recalibrateCount = 0
		self.vb.takeOffCount = 0
		self.vb.armCount = 0
		--Start P2 Timers
		timerRecalibrateCD:Start(6.7, 1)
		timerMegaZapCD:Start(11.2, 1)
		timerMagnetoArmCD:Start(30.4, 1)
	elseif spellId == 292807 then--Cancel Skull Aura (Annihilo-tron 5000 activating on pull)
		timerHardModeCD:Start(32.2, 1)
	end
end

--[[
--Used for auto acquiring of unitID and absolute fastest auto target scan using UNIT_TARGET events
function mod:UNIT_SPELLCAST_START(uId, _, spellId)
	if spellId == 291928 or spellId == 292264 then--Stage 1 Zap, Stage 2 Zap
		self:BossUnitTargetScanner(uId, "ZapTarget")
	end
end
--]]
