local mod	= DBM:NewMod(2401, "DBM-Party-Shadowlands", 6, 1187)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(162317)
mod:SetEncounterID(2365)
mod:SetZone(2293)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 323515 318406",
--	"SPELL_CAST_SUCCESS 323107",
--	"SPELL_AURA_APPLIED",
	"SPELL_PERIODIC_DAMAGE 323130",
	"SPELL_PERIODIC_MISSED 323130",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--https://shadowlands.wowhead.com/npc=165260/unraveling-horror
--[[
(ability.id = 323515 or ability.id = 318406) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnMeatHooks					= mod:NewCountAnnounce(322795, 2)

local specWarnTenderizingSmash		= mod:NewSpecialWarningRunCount(318406, nil, nil, nil, 4, 2)
local specWarnHatefulStrike			= mod:NewSpecialWarningDefensive(323515, nil, nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(323130, nil, nil, nil, 1, 8)

local timerMeatHooksCD				= mod:NewCDCountTimer(20.2, 322795, nil, nil, nil, 1)--"v20.6-24.3"
local timerTenderizingSmashCD		= mod:NewCDCountTimer(19.0, 318406, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--19.4 unless delayed by another spell
local timerHatefulStrikeCD			= mod:NewCDCountTimer(14.1, 323515, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--14.6 unless delayed by other spells (up to 19.4)

mod.vb.hookCount = 0
mod.vb.smashCount = 0
mod.vb.strikeCount = 0

---@param self DBMMod
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerMeatHooksCD:GetRemaining(self.vb.hookCount+1) < ICD then
		local elapsed, total = timerMeatHooksCD:GetTime(self.vb.hookCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerMeatHooksCD extended by: "..extend, 2)
		timerMeatHooksCD:Update(elapsed, total+extend, self.vb.hookCount+1)
	end
	if timerTenderizingSmashCD:GetRemaining(self.vb.smashCount+1) < ICD then
		local elapsed, total = timerTenderizingSmashCD:GetTime(self.vb.smashCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerTenderizingSmashCD extended by: "..extend, 2)
		timerTenderizingSmashCD:Update(elapsed, total+extend, self.vb.smashCount+1)
	end
	if timerHatefulStrikeCD:GetRemaining(self.vb.strikeCount+1) < ICD then
		local elapsed, total = timerHatefulStrikeCD:GetTime(self.vb.strikeCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerHatefulStrikeCD extended by: "..extend, 2)
		timerHatefulStrikeCD:Update(elapsed, total+extend, self.vb.strikeCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.hookCount = 0
	self.vb.smashCount = 0
	self.vb.strikeCount = 0
	timerHatefulStrikeCD:Start(8.6-delay, 1)
	timerMeatHooksCD:Start(5.8-delay, 1)
	timerTenderizingSmashCD:Start(14.1-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 323515 then
		self.vb.strikeCount = self.vb.strikeCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnHatefulStrike:Show()
			specWarnHatefulStrike:Play("defensive")
		end
		timerHatefulStrikeCD:Start(nil, self.vb.strikeCount+1)
		updateAllTimers(self, 4.8)
	elseif spellId == 318406 then
		self.vb.smashCount = self.vb.smashCount + 1
		specWarnTenderizingSmash:Show(self.vb.smashCount)
		specWarnTenderizingSmash:Play("justrun")
		timerTenderizingSmashCD:Start(nil, self.vb.smashCount+1)
		updateAllTimers(self, 6)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 323130 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 322795 then--Meat Hooks
		self.vb.hookCount = self.vb.hookCount + 1
		warnMeatHooks:Show(self.vb.hookCount)
		timerMeatHooksCD:Start(nil, self.vb.hookCount+1)
	end
end
