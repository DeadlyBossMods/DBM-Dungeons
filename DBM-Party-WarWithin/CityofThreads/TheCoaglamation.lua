local mod	= DBM:NewMod(2600, "DBM-Party-WarWithin", 8, 1274)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(216320)
mod:SetEncounterID(2905)
mod:SetHotfixNoticeRev(20240702000000)
mod:SetMinSyncRevision(20240702000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 441289 438658 447146 461880 461842 441395",
	"SPELL_CAST_SUCCESS 441395"
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--TODO, infoframe for corrupted coating? only if someone asks for it. Realistically i doubt anyone would use DBM for this anyways
--[[
(ability.id = 441289 or ability.id = 438658 or ability.id = 447146 or ability.id = 461880 or ability.id = 461842) and type = "begincast"
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
local timerOozingSmashCD					= mod:NewCDCountTimer(75.2, 461842, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerViscousDarknessCD				= mod:NewCDCountTimer(21.8, 441216, nil, nil, nil, 5)
local timerBloodSurgeCD						= mod:NewCDCountTimer(75.2, 445435, nil, nil, nil, 3)
local timerDarkPulseCD						= mod:NewCDCountTimer(75.2, 445435, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)--~1-2 variation due to blizzards still bad energy code

mod.vb.viscousCount = 0
mod.vb.oozingCount = 0
mod.vb.surgeCount = 0
mod.vb.pulseCount = 0

function mod:OnCombatStart(delay)
	self.vb.viscousCount = 0
	self.vb.oozingCount = 0
	self.vb.surgeCount = 0
	self.vb.pulseCount = 0
	timerOozingSmashCD:Start(3.4-delay, 1)--Is this actually mythic only? or Journal bug?
	timerViscousDarknessCD:Start(10.8-delay, 1)
	timerBloodSurgeCD:Start(47.1-delay, 1)
	timerDarkPulseCD:Start(71.6-delay, 1)--til success not cast start, aoe damage doesn't come til the channel begins
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 441289 or spellId == 447146 then
		self.vb.viscousCount = self.vb.viscousCount + 1
		specWarnViscousDarkness:Show()
		specWarnViscousDarkness:Play("helpsoak")
		if spellId == 441289  then--First Cast
			timerViscousDarknessCD:Start(21.8, self.vb.viscousCount+1)--Subject to same 2-3 second swing due to energy code
		else--Second Cast
			timerViscousDarknessCD:Start(54.6, self.vb.viscousCount+1)--Subject to same 2-3 second swing due to energy code
		end
	elseif spellId == 461842 then
		self.vb.oozingCount = self.vb.oozingCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnOozingSmash:Show()
			specWarnOozingSmash:Play("defensive")
		end
		timerOozingSmashCD:Start(nil, self.vb.oozingCount+1)
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
		timerDarkPulseCD:Start(33.9, self.vb.pulseCount+1)
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
