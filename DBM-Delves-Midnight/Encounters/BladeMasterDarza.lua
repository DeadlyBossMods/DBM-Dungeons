local mod	= DBM:NewMod("BladeMasterDarza", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3360)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterSafeEventsInCombat(
	"UNIT_SPELLCAST_START target"
)

--NOTE: This boss doesn't have boss1 unit ID so it will break if either condition is true:
--1. You have a target that isn't the boss
--2. You do not target the boss during any cast
local specWarnShadeCleave		= mod:NewSpecialWarningDodgeCount(1267227, nil, nil, nil, 2, 15)
local specWarnBaskInTwilight	= mod:NewSpecialWarningDodgeCount(1268950, nil, nil, nil, 2, 2)

local timerShadeCleaveCD		= mod:NewCDCountTimer(17, 1267227, nil, nil, nil, 3)
local timerBaskInTwilightCD		= mod:NewCDCountTimer(42.4, 1268950, nil, nil, nil, 1)

mod.vb.channelCount = 0
mod.vb.baskCount = 0
mod.vb.shadeCount = 0

function mod:OnLimitedCombatStart()
	self.vb.channelCount = 0
	self.vb.baskCount = 0
	self.vb.shadeCount = 0
	timerShadeCleaveCD:Start(6, 1)
	timerBaskInTwilightCD:Start(32.7, 1)
	DBM:AddMsg("This module will only work if the boss is kept as your current target and no other enemy is targeted during any cast")
end

function mod:UNIT_SPELLCAST_START()
	--SC, SC, SC, BT, SC, SC, SC, BT (unknown after that, continued pattern assumed)
	self.vb.channelCount = self.vb.channelCount + 1
	if self.vb.channelCount % 4 == 0 then--Bask in Twilight
		specWarnBaskInTwilight:Show(self.vb.baskCount)
		specWarnBaskInTwilight:Play("watchstep")
		timerBaskInTwilightCD:Start(33.8, self.vb.baskCount+1)
	else--Shade Cleave
		self.vb.shadeCount = self.vb.shadeCount + 1
		specWarnShadeCleave:Show(self.vb.shadeCount)
		specWarnShadeCleave:Play("frontal")
		timerShadeCleaveCD:Start(10.9, self.vb.shadeCount+1)
	end
end
