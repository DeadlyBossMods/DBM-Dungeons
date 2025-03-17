local mod	= DBM:NewMod(2109, "DBM-Party-BfA", 7, 1012)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(129214)
mod:SetEncounterID(2105)
mod:SetHotfixNoticeRev(20250302000000)
mod:SetZone(1594)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 262347 257337 271903 1217294",
	"SPELL_CAST_SUCCESS 269493 262347",
	"SPELL_AURA_APPLIED 256493",
	"SPELL_AURA_APPLIED_DOSE 256493",
	"SPELL_AURA_REFRESH 256493",
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
local warnCoinMagnet				= mod:NewCountAnnounce(271903, 2)

local specWarnStaticPulse			= mod:NewSpecialWarningCount(262347, nil, nil, nil, 2, 2)
local specWarnShockingClaw			= mod:NewSpecialWarningDodgeCount(257337, nil, nil, nil, 2, 15)
local specWarnThrowCoins			= mod:NewSpecialWarningMove(271784, "Tank", nil, nil, 1, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerStaticPulseCD			= mod:NewVarCountTimer("v43.7-48.5", 262347, nil, nil, nil, 2)
local timerFootbombLauncherCD		= mod:NewVarCountTimer("v42.5-48.5", 269493, nil, nil, nil, 5)
local timerBlazingAzerite			= mod:NewBuffFadesTimer(15, 256493, nil, nil, nil, 5)
local timerShockingClawCD			= mod:NewVarCountTimer("v41.2-48.5", 257337, nil, nil, nil, 3)--time shorted by 2.5 cause we start timer at success but want it to expire at start
local timerThrowCoinsCD				= mod:NewVarCountTimer("v43.7-48.5", 271784, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON..DBM_COMMON_L.TANK_ICON)--18.8, 17.4, 25.5, 25.5
local timerCoinMagnetCD				= mod:NewCDCountTimer(43.3, 271903, nil, nil, nil, 3)--Needs more data, probably same as the rest though

mod.vb.pulseCount = 0
mod.vb.launcherCount = 0
mod.vb.clawCount = 0
mod.vb.coinCast = 0
mod.vb.magnetCount = 0

function mod:OnCombatStart(delay)
	self.vb.pulseCount = 0
	self.vb.launcherCount = 0
	self.vb.clawCount = 0
	self.vb.coinCast = 0
	self.vb.magnetCount = 0
	timerStaticPulseCD:Start(6.2-delay, 1)
	timerFootbombLauncherCD:Start(19.3-delay, 1)
	timerShockingClawCD:Start(30.4-delay, 1)
	if not self:IsNormal() then
		timerThrowCoinsCD:Start(12.2-delay, 1)
	end
	timerCoinMagnetCD:Start(40.0-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 262347 then
		specWarnStaticPulse:Show(self.vb.pulseCount+1)--Incremented since we don't increase count til success
		specWarnStaticPulse:Play("carefly")
	elseif spellId == 257337 or spellId == 1217294 then
		self.vb.clawCount = self.vb.clawCount + 1
		specWarnShockingClaw:Show(self.vb.clawCount)
		specWarnShockingClaw:Play("frontal")
		--"Shocking Claw-1217294-npc:129214-000034EF63 = pull:30.4, 48.1, 43.7
		timerShockingClawCD:Start(nil, self.vb.clawCount+1)
	elseif spellId == 271903 then
		self.vb.magnetCount = self.vb.magnetCount + 1
		warnCoinMagnet:Show(self.vb.magnetCount)
		--"Coin Magnet-271903-npc:129214-000034EF63 = pull:41.3, 43.3",
		timerCoinMagnetCD:Start(43.3, self.vb.magnetCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 269493 then
		self.vb.launcherCount = self.vb.launcherCount + 1
		warnFootbombLauncher:Show(self.vb.launcherCount)
		--"Footbomb Launcher-269493-npc:129214-000034EF63 = pull:19.5, 48.1, 42.5",
		timerFootbombLauncherCD:Start(nil, self.vb.launcherCount+1)
	elseif spellId == 262347 then
		self.vb.pulseCount = self.vb.pulseCount + 1
		--"Static Pulse-262347-npc:129214-000034EF63 = pull:6.2, 48.1, 43.7"
		timerStaticPulseCD:Start(nil, self.vb.pulseCount+1)
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

--"Pay to Win-271859-npc:129214-000034EF63 = pull:12.2, 48.1, 43.7",
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 271859 then--Pay to Win
		self.vb.coinCast = self.vb.coinCast + 1
		specWarnThrowCoins:Show()
		specWarnThrowCoins:Play("moveboss")
		timerThrowCoinsCD:Start(nil, self.vb.coinCast+1)
		--if self.vb.coinCast == 1 then
		--	timerThrowCoinsCD:Start(17, self.vb.coinCast+1)
		--else
		--	timerThrowCoinsCD:Start(25, self.vb.coinCast+1)
		--end
	end
end
