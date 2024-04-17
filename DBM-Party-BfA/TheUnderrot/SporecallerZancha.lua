local mod	= DBM:NewMod(2130, "DBM-Party-BfA", 8, 1022)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(131383)
mod:SetEncounterID(2112)
mod:SetHotfixNoticeRev(20230520000000)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 259732 272457",
	"SPELL_CAST_SUCCESS 259830 259718 259732",--273285
	"SPELL_AURA_APPLIED 259718",
	"SPELL_AURA_REMOVED 259718",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, re-evalulate all timers from DF M+ logs
--[[
(ability.id = 259732 or ability.id = 272457) and type = "begincast"
 or (ability.id = 259830 or ability.id = 259718 or ability.id = 259732 or ability.id = 273285) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--local warnBoundlessrot				= mod:NewSpellAnnounce(259830, 3)--Use if too spammy as special warning
local warnUpheaval					= mod:NewTargetAnnounce(259718, 3)
local warnVolatilePods				= mod:NewSpellAnnounce(273271, 3)

local specWarnFesteringHarvest		= mod:NewSpecialWarningDodgeCount(259732, nil, nil, nil, 2, 2)
local specWarnShockwave				= mod:NewSpecialWarningSpell(272457, "Tank", nil, nil, 1, 2)
local specWarnUpheaval				= mod:NewSpecialWarningMoveAway(259718, nil, nil, nil, 1, 2)
local yellUpheaval					= mod:NewYell(259718)
local yellUpheavalFades				= mod:NewShortFadesYell(259718)

local timerFesteringHarvestCD		= mod:NewCDCountTimer(50.9, 259732, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerBoundlessRotCD			= mod:NewCDTimer(13, 259830, nil, nil, nil, 3)
local timerVolatilePodsCD			= mod:NewCDTimer(25.1, 273271, nil, nil, nil, 3)
local timerShockwaveCD				= mod:NewCDTimer(14.6, 272457, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerUpheavalCD				= mod:NewCDTimer(15.8, 259718, nil, nil, nil, 3)--15.8-20

mod.vb.festeringCount = 0

function mod:OnCombatStart(delay)
	self.vb.festeringCount = 0
	--timerBoundlessRotCD:Start(1-delay)--Immediately on pull
	timerShockwaveCD:Start(10-delay)
	timerUpheavalCD:Start(16.7-delay)
	if not self:IsNormal() then
		timerVolatilePodsCD:Start(15.7-delay)
	end
	timerFesteringHarvestCD:Start(45.8-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 259732 then
		self.vb.festeringCount = self.vb.festeringCount + 1
		specWarnFesteringHarvest:Show(self.vb.festeringCount)
		specWarnFesteringHarvest:Play("watchorb")
		timerFesteringHarvestCD:Start(nil, self.vb.festeringCount+1)
		timerShockwaveCD:Stop()
		timerUpheavalCD:Stop()
		timerBoundlessRotCD:Start(8.5)
	elseif spellId == 272457 then
		specWarnShockwave:Show()
		specWarnShockwave:Play("shockwave")
		timerShockwaveCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 259830 then
		--timerBoundlessRotCD:Start()
	elseif spellId == 259718 and self:AntiSpam(3, 1) then
		timerUpheavalCD:Start(self:IsMythicPlus() and 20.6 or 15.7)
		if timerShockwaveCD:GetRemaining() < 8.5 then
			local elapsed, total = timerShockwaveCD:GetTime()
			local extend = 8.5 - (total-elapsed)
			DBM:Debug("timerShockwaveCD extended by: "..extend, 2)
			timerShockwaveCD:Update(elapsed, total+extend)
		end
	elseif spellId == 259732 then--Festering Harvvest
		timerUpheavalCD:Start(10.5)
		timerShockwaveCD:Start(19)
--	elseif spellId == 273285 then
--		specWarnVolatilePods:Show()
--		specWarnVolatilePods:Play("watchstep")
--		timerVolatilePodsCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 259718 then
		if args:IsPlayer() then
			specWarnUpheaval:Show()
			specWarnUpheaval:Play("runout")
			yellUpheaval:Yell()
			yellUpheavalFades:Countdown(6)
		else
			warnUpheaval:CombinedShow(0.3, args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 259718 and args:IsPlayer() then
		yellUpheavalFades:Cancel()
	end
end

--Singular event, vs throttling success casts
function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 273271 then--Volatile Pods
		warnVolatilePods:Show()
		timerVolatilePodsCD:Start()
	end
end
