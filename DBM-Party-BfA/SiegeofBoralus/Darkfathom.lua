local mod	= DBM:NewMod(2134, "DBM-Party-BfA", 5, 1023)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(128651)
mod:SetEncounterID(2099)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 257882 276068",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

local specWarnCrashingTide			= mod:NewSpecialWarningDodgeCount(261563, nil, nil, 2, 1, 2)
local specWarnBreakWater			= mod:NewSpecialWarningDodgeCount(257882, nil, nil, nil, 2, 2)
local specWarnTidalSurge			= mod:NewSpecialWarningMoveTo(276068, nil, nil, nil, 3, 2)

local timerCrashingTideCD			= mod:NewCDCountTimer(15.8, 261563, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerBreakWaterCD				= mod:NewCDCountTimer(30, 257882, nil, nil, nil, 3)
local timerTidalSurgeCD				= mod:NewCDCountTimer(49.8, 276068, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)

mod.vb.crashingTideCount = 0
mod.vb.breakwaterCount = 0
mod.vb.tidalSurgeCount = 0

function mod:OnCombatStart(delay)
	self.vb.crashingTideCount = 0
	self.vb.breakwaterCount = 0
	self.vb.tidalSurgeCount = 0
	timerBreakWaterCD:Start(7.1-delay, 1)
	timerCrashingTideCD:Start(13.1-delay, 1)
	timerTidalSurgeCD:Start(24.1-delay, 1)
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
		timerTidalSurgeCD:Start(nil, self.vb.tidalSurgeCount+1)
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 257861 then--Crashing Tide
		self.vb.crashingTideCount = self.vb.crashingTideCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnCrashingTide:Show(self.vb.crashingTideCount)
			specWarnCrashingTide:Play("shockwave")
		end
		timerCrashingTideCD:Start(nil, self.vb.crashingTideCount+1)
	end
end
