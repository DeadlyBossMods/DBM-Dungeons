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
--]]
local warnMeatHooks					= mod:NewCountAnnounce(322795, 2)

local specWarnTenderizingSmash		= mod:NewSpecialWarningRunCount(318406, nil, nil, nil, 4, 2)
local specWarnHatefulStrike			= mod:NewSpecialWarningDefensive(323515, nil, nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(323130, nil, nil, nil, 1, 8)

local timerMeatHooksCD				= mod:NewNextCountTimer(20.6, 322795, nil, nil, nil, 1)
local timerTenderizingSmashCD		= mod:NewCDCountTimer(19.4, 318406, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerHatefulStrikeCD			= mod:NewCDCountTimer(14.6, 323515, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod.vb.hookCount = 0
mod.vb.smashCount = 0
mod.vb.strikeCount = 0

function mod:OnCombatStart(delay)
	self.vb.hookCount = 0
	self.vb.smashCount = 0
	self.vb.strikeCount = 0
	timerHatefulStrikeCD:Start(9.7-delay, 1)
	timerMeatHooksCD:Start(5.8-delay, 1)
	timerTenderizingSmashCD:Start(14.5-delay, 1)
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
	elseif spellId == 318406 then
		self.vb.smashCount = self.vb.smashCount + 1
		specWarnTenderizingSmash:Show(self.vb.smashCount)
		specWarnTenderizingSmash:Play("justrun")
		timerTenderizingSmashCD:Start(nil, self.vb.smashCount+1)
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
