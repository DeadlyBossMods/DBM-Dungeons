local mod	= DBM:NewMod(1673, "DBM-Party-Legion", 5, 767)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(91005)
mod:SetEncounterID(1792)
mod.sendMainBossGUID = true
mod.respawnTime = 15--10-15, trying 15 for now, def not 30

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 199176 210150 205549",
	"SPELL_AURA_APPLIED 209906",
	"SPELL_AURA_REMOVED 199178",
	"SPELL_PERIODIC_DAMAGE 188494",
	"SPELL_PERIODIC_MISSED 188494",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 199176 or ability.id = 210150 or ability.id = 205549) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnFixate					= mod:NewTargetAnnounce(209906, 2, nil, false)--Could be spammy, optional
local warnSpikedTongueOver			= mod:NewEndAnnounce(199176, 1)

local specWarnAdds					= mod:NewSpecialWarningSwitchCount(199817, "-Healer", nil, 2, 1, 2)
local specWarnFixate				= mod:NewSpecialWarningYou(209906, nil, nil, nil, 1, 2)
local specWarnSpikedTongue			= mod:NewSpecialWarningRunCount(199176, nil, nil, nil, 4, 2)
local specWarnRancidMaw				= mod:NewSpecialWarningGTFO(188494, nil, nil, nil, 1, 8)

local timerSpikedTongueCD			= mod:NewNextCountTimer(55, 199176, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.DEADLY_ICON..DBM_COMMON_L.TANK_ICON)
local timerAddsCD					= mod:NewCDCountTimer(65, 199817, nil, nil, nil, 1, 226361)
local timerRancidMawCD				= mod:NewCDCountTimer(18, 205549, nil, nil, nil, 2)
local timerToxicRetchCD				= mod:NewCDCountTimer(14.3, 210150, nil, nil, nil, 3)

mod.vb.retchCount = 0
mod.vb.addsCount = 0
mod.vb.spikeCount = 0
mod.vb.mawCount = 0

function mod:OnCombatStart(delay)
	self.vb.retchCount = 0
	self.vb.addsCount = 0
	self.vb.spikeCount = 0
	self.vb.mawCount = 0
	timerAddsCD:Start(5.2-delay, 1)
	timerRancidMawCD:Start(7.3-delay, 1)
	timerToxicRetchCD:Start(12.2-delay, 1)
	timerSpikedTongueCD:Start(50.5-delay, 1)
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 209906 then
		if args:IsPlayer() and self:AntiSpam(4, 1) then
			specWarnFixate:Show()
			specWarnFixate:Play("targetyou")
		else
			warnFixate:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 199178 and self:AntiSpam(4, 2) then
		warnSpikedTongueOver:Show()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 199176 then
		self.vb.spikeCount = self.vb.spikeCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSpikedTongue:Show(self.vb.spikeCount)
			specWarnSpikedTongue:Play("runout")
			specWarnSpikedTongue:ScheduleVoice(1.5, "keepmove")
		end
		timerSpikedTongueCD:Start(nil, self.vb.spikeCount+1)
	elseif spellId == 205549 then
		self.vb.mawCount = self.vb.mawCount + 1
		timerRancidMawCD:Start(nil, self.vb.mawCount+1)
	elseif spellId == 210150 then
		self.vb.retchCount = self.vb.retchCount + 1
		timerToxicRetchCD:Start(nil, self.vb.retchCount+1)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 188494 and destGUID == UnitGUID("player") and self:AntiSpam(3, 3) then
		specWarnRancidMaw:Show(spellName)
		specWarnRancidMaw:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 199817 then--Call Minions
		self.vb.addsCount = self.vb.addsCount + 1
		specWarnAdds:Show(self.vb.addsCount)
		specWarnAdds:Play("mobsoon")
		timerAddsCD:Start(nil, self.vb.addsCount+1)
	end
end
