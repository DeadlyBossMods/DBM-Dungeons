local mod	= DBM:NewMod(2095, "DBM-Party-BfA", 2, 1001)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(126983)
mod:SetEncounterID(2096)
mod:SetHotfixNoticeRev(20230505000000)
mod:SetZone(1754)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 257402 257458 413145 413147 413131 413136",
	"SPELL_CAST_SUCCESS 257316",--257278
	"SPELL_AURA_APPLIED 257314 257305",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 257402 or ability.id = 257458 or ability.id = 413145 or ability.id = 413147 or ability.id = 413131 or ability.id = 413136) and type = "begincast"
 or (ability.id = 257316 or ability.id = 257278 or ability.id = 257453 or ability.id = 257304) and type = "cast"
 or (ability.id = 257305 or ability.id = 257314) and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --]]
local warnPhase						= mod:NewPhaseChangeAnnounce(2, nil, nil, nil, nil, nil, nil, 2)
local warnBlackPowder				= mod:NewTargetAnnounce(257314, 4)
local warnCannonBarrage				= mod:NewTargetAnnounce(257305, 3)
local warnWhirlingDagger			= mod:NewCountAnnounce(413131, 3)

local specWarnBlackPowder			= mod:NewSpecialWarningRun(257314, nil, nil, nil, 4, 2)
local yellBlackPowder				= mod:NewYell(257314)
local specWarnSwiftwindSaber		= mod:NewSpecialWarningDodge(257278, nil, nil, nil, 2, 2)
local specWarnCannonBarrage			= mod:NewSpecialWarningDodge(257305, nil, nil, nil, 3, 2)
local yellCannonBarrage				= mod:NewYell(257305)

local timerAvastyeCD				= mod:NewCDTimer(13, 257316, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerSwiftwindSaberCD			= mod:NewCDTimer(15.8, 257278, nil, nil, nil, 3)--Swap option key to 413147 if non M+ version also is changed
local timerCannonBarrageCD			= mod:NewCDTimer(17.4, 257305, nil, nil, nil, 3)
local timerWhirlingDaggerCD			= mod:NewCDCountTimer(18.8, 413131, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.BLEED_ICON)

mod.vb.daggerCount = 0

function mod:OnCombatStart(delay)
	self.vb.daggerCount = 0
	self:SetStage(1)
	timerSwiftwindSaberCD:Start(10-delay)
	timerCannonBarrageCD:Start(20-delay)
	timerAvastyeCD:Start(31.2-delay)
	if self:IsMythicPlus() then
		timerWhirlingDaggerCD:Start(12.9-delay, 1)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 257402 then--All Hands
		self:SetStage(2)
		warnPhase:Show(DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.stage:format(2))
		warnPhase:Play("ptwo")
		timerSwiftwindSaberCD:Stop()
		timerAvastyeCD:Stop()
		timerCannonBarrageCD:Stop()
		timerWhirlingDaggerCD:Stop()
		timerSwiftwindSaberCD:Start(10.9)
		timerCannonBarrageCD:Start(15.7)
		timerAvastyeCD:Start(21.8)
		if self:IsMythicPlus() then
			timerWhirlingDaggerCD:Start(13.3, self.vb.daggerCount+1)
		end
	elseif spellId == 257458 then--ManOWar
		self:SetStage(3)
		warnPhase:Show(DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.stage:format(3))
		warnPhase:Play("pthree")
		timerSwiftwindSaberCD:Stop()
		timerAvastyeCD:Stop()
		timerCannonBarrageCD:Stop()
		timerWhirlingDaggerCD:Stop()
		timerSwiftwindSaberCD:Start(10.5)
		timerCannonBarrageCD:Start(15.7)
		timerAvastyeCD:Start(21.8)
		if self:IsMythicPlus() then
			timerWhirlingDaggerCD:Start(13.3, self.vb.daggerCount+1)
		end
	elseif spellId == 413145 or spellId == 413147 then--Shadowlands S2 version
		specWarnSwiftwindSaber:Show()
		specWarnSwiftwindSaber:Play("watchwave")
		if self:GetStage(3) then
			timerSwiftwindSaberCD:Start(12.5)--12.5-14
		else
			timerSwiftwindSaberCD:Start(18)--18-20
		end
	elseif spellId == 413131 or spellId == 413136 then
		self.vb.daggerCount = self.vb.daggerCount + 1
		warnWhirlingDagger:Show(self.vb.daggerCount)
		if self:GetStage(3) then
			timerWhirlingDaggerCD:Start(11.7, self.vb.daggerCount+1)--11.7-15
		else
			timerWhirlingDaggerCD:Start(17.6, self.vb.daggerCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 257316 then
		if self:GetStage(3) then
			timerAvastyeCD:Start(20.6)--20.6-23.1
		else
			timerAvastyeCD:Start(25.5)--25.5--27
		end
--	elseif spellId == 257278 then--Legacy version
--		specWarnSwiftwindSaber:Show()
--		specWarnSwiftwindSaber:Play("watchwave")
--		timerSwiftwindSaberCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 257314 and args:IsDestTypePlayer() then
		warnBlackPowder:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnBlackPowder:Show()
			specWarnBlackPowder:Play("justrun")
			yellBlackPowder:Yell()
		end
	elseif spellId == 257305 then
		if self:GetStage(2, 2) then--Multiple targets
			warnCannonBarrage:CombinedShow(0.3, args.destName)
		end
		if args:IsPlayer() then
			specWarnCannonBarrage:Show()
			specWarnCannonBarrage:Play("watchstep")
			--specWarnCannonBarrage:ScheduleVoice(1.5, "keepmove")
			yellCannonBarrage:Yell()
		else
			if self:GetStage(1) then--Only one target
				warnCannonBarrage:Show(args.destName)
			end
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453 or spellId == 257304 then--Cannon Barrage (Stage 1), Cannon Barrage (Stage 2/3)
		if self:GetStage(3) then
			timerCannonBarrageCD:Start(15.5)
		else
			timerCannonBarrageCD:Start(25)
		end
	end
end
