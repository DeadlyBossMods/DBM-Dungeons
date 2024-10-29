local mod	= DBM:NewMod(2600, "DBM-Party-WarWithin", 8, 1274)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(216320)
mod:SetEncounterID(2905)
mod:SetHotfixNoticeRev(20240818000000)
mod:SetMinSyncRevision(20240702000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 441289 438658 447146 461880 461842 441395 461989",
	"SPELL_CAST_SUCCESS 441395"
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--TODO, infoframe for corrupted coating? only if someone asks for it. Realistically i doubt anyone would use DBM for this anyways
--TODO, this boss needs fixing on normal/heroic since that stuff is hard to pull up on WCL
--[[
(ability.id = 441289 or ability.id = 438658 or ability.id = 447146 or ability.id = 461880 or ability.id = 461842 or ability.id = 461989) and type = "begincast"
 or ability.id = 441395 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnDarkPulsePreCast					= mod:NewCastAnnounce(441395, 3)

local specWarnOozingSmash					= mod:NewSpecialWarningDefensive(461842, nil, nil, nil, 1, 2)
local specWarnViscousDarkness				= mod:NewSpecialWarningCount(441216, nil, nil, nil, 2, 2)
local specWarnBloodSurge					= mod:NewSpecialWarningDodgeCount(445435, nil, nil, nil, 2, 2)
local specWarnDarkPulse						= mod:NewSpecialWarningCount(441395, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

--All attacks are energy based and energy based timers are always subject to a swing due to blizzards energy code being shitty
--(the ticks don't use realtime but rather onupdate tiks which causes desync)
--As a result, all these timers are literally 75-78 (3 second swing)
local timerOozingSmashCD					= mod:NewCDCountTimer(54.3, 461842, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--77.3-77.9 on normal still?
local timerViscousDarknessCD				= mod:NewCDCountTimer(21.8, 441216, nil, nil, nil, 5)--21.8-22.3
local timerBloodSurgeCD						= mod:NewCDCountTimer(67.9, 445435, nil, nil, nil, 3)--76.6-77.9
local timerDarkPulseCD						= mod:NewCDCountTimer(75.2, 441395, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)--~1-2 variation due to blizzards still bad energy code

mod.vb.viscousCount = 0
mod.vb.oozingCount = 0
mod.vb.surgeCount = 0
mod.vb.pulseCount = 0

function mod:OnCombatStart(delay)
	self.vb.viscousCount = 0
	self.vb.oozingCount = 0
	self.vb.surgeCount = 0
	self.vb.pulseCount = 0
	if self:IsMythic() then
		timerOozingSmashCD:Start(3-delay, 1)--3-3.7 31.6
		timerViscousDarknessCD:Start(10.6-delay, 1)
		timerBloodSurgeCD:Start(19.1-delay, 1)
		timerDarkPulseCD:Start(47.3-delay, 1)--til success not cast start, aoe damage doesn't come til the channel begins
	else
		timerViscousDarknessCD:Start(8.5-delay, 1)
		timerBloodSurgeCD:Start(20.7-delay, 1)
		timerOozingSmashCD:Start(31.6-delay, 1)
		timerDarkPulseCD:Start(71.6-delay, 1)--UNKNOWN timer for follower, died too fast
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 441289 or spellId == 447146 then
		self.vb.viscousCount = self.vb.viscousCount + 1
		specWarnViscousDarkness:Show(self.vb.viscousCount)
		specWarnViscousDarkness:Play("helpsoak")
		--11.1, 21.8, 32.8
		if spellId == 441289 then--First Cast
			timerViscousDarknessCD:Start(21.8, self.vb.viscousCount+1)
		else--Second Cast
			timerViscousDarknessCD:Start(32.8, self.vb.viscousCount+1)--Subject variation, which we correct latter at blood surge
		end
	elseif spellId == 461842 or spellId == 461989 then
		self.vb.oozingCount = self.vb.oozingCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnOozingSmash:Show()
			specWarnOozingSmash:Play("defensive")
		end
		timerOozingSmashCD:Start(spellId == 461842 and 15 or 54.3, self.vb.oozingCount+1)
	elseif spellId == 438658 or spellId == 461880 then
		self.vb.surgeCount = self.vb.surgeCount + 1
		specWarnBloodSurge:Show(self.vb.surgeCount)
		specWarnBloodSurge:Play("watchstep")
		timerBloodSurgeCD:Start(nil, self.vb.surgeCount+1)
	elseif spellId == 441395 then
		warnDarkPulsePreCast:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 441395 then
		self.vb.pulseCount = self.vb.pulseCount + 1
		specWarnDarkPulse:Show(self.vb.pulseCount)
		specWarnDarkPulse:Play("aesoon")
		timerDarkPulseCD:Start(nil, self.vb.pulseCount+1)
		--Make timers more precise with auto correction here
		if timerViscousDarknessCD:GetRemaining(self.vb.viscousCount+1) < 15.2 then
			local elapsed, total = timerViscousDarknessCD:GetTime(self.vb.viscousCount+1)
			local extend = 15.2 - (total-elapsed)
			DBM:Debug("timerViscousDarknessCD extended by: "..extend, 2)
			timerViscousDarknessCD:Update(elapsed, total+extend, self.vb.viscousCount+1)
		end
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 447402 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 447402 then

	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
