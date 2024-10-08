local mod	= DBM:NewMod(2134, "DBM-Party-BfA", 5, 1023)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(128651)
mod:SetEncounterID(2099)
--mod:SetHotfixNoticeRev(20230516000000)
--mod:SetMinSyncRevision(20211203000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 257882 276068 257862",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 257882 or ability.id = 276068 or ability.id = 257862) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local specWarnCrashingTide			= mod:NewSpecialWarningDodgeCount(261563, nil, nil, 2, 1, 15)
local specWarnBreakWater			= mod:NewSpecialWarningDodgeCount(257882, nil, nil, nil, 2, 2)
local specWarnTidalSurge			= mod:NewSpecialWarningMoveTo(276068, nil, nil, nil, 3, 2)

local timerCrashingTideCD			= mod:NewCDCountTimer(23, 261563, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--15.8 before
local timerBreakWaterCD				= mod:NewCDCountTimer(20.6, 257882, nil, nil, nil, 3)--30 before
local timerTidalSurgeCD				= mod:NewCDCountTimer(48.5, 276068, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)--Still the same

mod.vb.crashingTideCount = 0
mod.vb.breakwaterCount = 0
mod.vb.tidalSurgeCount = 0

function mod:OnCombatStart(delay)
	self.vb.crashingTideCount = 0
	self.vb.breakwaterCount = 0
	self.vb.tidalSurgeCount = 0
	timerBreakWaterCD:Start(7.1-delay, 1)
	timerCrashingTideCD:Start(12.1-delay, 1)
	timerTidalSurgeCD:Start(23.1-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 257882 then
		self.vb.breakwaterCount = self.vb.breakwaterCount + 1
		specWarnBreakWater:Show(self.vb.breakwaterCount)
		specWarnBreakWater:Play("watchstep")
		timerBreakWaterCD:Start(nil, self.vb.breakwaterCount+1)
	elseif spellId == 276068 then
		self.vb.tidalSurgeCount = self.vb.tidalSurgeCount + 1
		specWarnTidalSurge:Show(DBM_COMMON_L.BREAK_LOS)
		specWarnTidalSurge:Play("findshelter")
		--"Break Water-257882-npc:128651-00007B64C4 = pull:7.2, 29.1, 20.6, 29.2",
		--https://www.warcraftlogs.com/reports/14taVJYZ3KHRm9n6#fight=56&pins=2%24Off%24%23244F4B%24expression%24ability.id%20%3D%20257882%20and%20type%20%3D%20%22begincast%22&view=events
		timerTidalSurgeCD:Start(self.vb.tidalSurgeCount % 2 == 0 and 20.6 or 29.1, self.vb.tidalSurgeCount+1)
	elseif spellId == 257862 and self:AntiSpam(5, 1) then--TWW has it in combat log now
		self.vb.crashingTideCount = self.vb.crashingTideCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnCrashingTide:Show(self.vb.crashingTideCount)
			specWarnCrashingTide:Play("frontal")
		end
		timerCrashingTideCD:Start(nil, self.vb.crashingTideCount+1)
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 257861 and self:AntiSpam(5, 1) then--Crashing Tide (Legacy)
		self.vb.crashingTideCount = self.vb.crashingTideCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnCrashingTide:Show(self.vb.crashingTideCount)
			specWarnCrashingTide:Play("frontal")
		end
		timerCrashingTideCD:Start(nil, self.vb.crashingTideCount+1)
	end
end
