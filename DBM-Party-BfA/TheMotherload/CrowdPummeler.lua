local mod	= DBM:NewMod(2109, "DBM-Party-BfA", 7, 1012)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(129214)
mod:SetEncounterID(2105)
mod:SetZone(1594)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 256493",
	"SPELL_AURA_APPLIED_DOSE 256493",
	"SPELL_AURA_REFRESH 256493",
	"SPELL_CAST_START 262347 257337 271903 1217294",
	"SPELL_CAST_SUCCESS 269493 262347",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--Change Static Pulse to dodge warning if it's dodgable by all parties
--New voice, "Gather Item"?
--[[
(ability.id = 262347 or ability.id = 257337 or ability.id = 271903) and type = "begincast"
 or ability.id = 269493 and type = "cast"
 or ability.id = 256493 and not type = "damage"
--]]
local warnFootbombLauncher			= mod:NewCountAnnounce(269493, 2)
local warnCoinMagnet				= mod:NewSpellAnnounce(271903, 2)

local specWarnStaticPulse			= mod:NewSpecialWarningCount(262347, nil, nil, nil, 2, 2)
local specWarnShockingClaw			= mod:NewSpecialWarningDodgeCount(257337, nil, nil, nil, 2, 15)
local specWarnThrowCoins			= mod:NewSpecialWarningMove(271784, "Tank", nil, nil, 1, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerStaticPulseCD			= mod:NewCDCountTimer(23.1, 262347, nil, nil, nil, 2)
local timerFootbombLauncherCD		= mod:NewCDCountTimer(32.8, 269493, nil, nil, nil, 5)
local timerBlazingAzerite			= mod:NewBuffFadesTimer(15, 256493, nil, nil, nil, 5)
local timerShockingClawCD			= mod:NewCDCountTimer(21.8, 257337, nil, nil, nil, 3)--14.3, 41.3 (not sure if still true, not going to leave it ai though, 23 it is til i see lower)
local timerThrowCoinsCD				= mod:NewCDCountTimer(17.4, 271784, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON..DBM_COMMON_L.TANK_ICON)--18.8, 17.4, 25.5, 25.5

mod.vb.pulseCount = 0
mod.vb.launcherCount = 0
mod.vb.clawCount = 0
mod.vb.coinCast = 0

function mod:OnCombatStart(delay)
	self.vb.pulseCount = 0
	self.vb.launcherCount = 0
	self.vb.clawCount = 0
	self.vb.coinCast = 0
	timerStaticPulseCD:Start(5.7-delay, 1)
	timerFootbombLauncherCD:Start(9-delay, 1)
	timerShockingClawCD:Start(14.3-delay, 1)
	if not self:IsNormal() then
		timerThrowCoinsCD:Start(18-delay, 1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 256493 then--270882 for players?
		timerBlazingAzerite:Stop()
		timerBlazingAzerite:Start()
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
mod.SPELL_AURA_REFRESH = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 262347 then
		specWarnStaticPulse:Show(self.vb.pulseCount+1)--Incremented since we don't increase count til success
		specWarnStaticPulse:Play("carefly")
	elseif spellId == 257337 or spellId == 1217294 then
		self.vb.clawCount = self.vb.clawCount + 1
		specWarnShockingClaw:Show(self.vb.clawCount)
		specWarnShockingClaw:Play("frontal")
		timerShockingClawCD:Start(nil, self.vb.clawCount+1)
	elseif spellId == 271903 then
		warnCoinMagnet:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 269493 then
		self.vb.launcherCount = self.vb.launcherCount + 1
		warnFootbombLauncher:Show(self.vb.launcherCount)
		timerFootbombLauncherCD:Start(nil, self.vb.launcherCount+1)
	elseif spellId == 262347 then
		self.vb.pulseCount = self.vb.pulseCount + 1
		timerStaticPulseCD:Start(20.6, self.vb.pulseCount+1)--23.1-2.5
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 271859 then--Pay to Win
		self.vb.coinCast = self.vb.coinCast + 1
		specWarnThrowCoins:Show()
		specWarnThrowCoins:Play("moveboss")
		if self.vb.coinCast == 1 then
			timerThrowCoinsCD:Start(17, self.vb.coinCast+1)
		else
			timerThrowCoinsCD:Start(25, self.vb.coinCast+1)
		end
	end
end
