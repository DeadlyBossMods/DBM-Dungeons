local mod	= DBM:NewMod("SpiritflayerJinma", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3433)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterSafeEventsInCombat(
	"UNIT_SPELLCAST_CHANNEL_START boss1"
)

local warnClaimSpirits			= mod:NewCountAnnounce(1266337, 3)

local specWarnRagingSpirits		= mod:NewSpecialWarningCount(1265958, nil, nil, nil, 2, 2)

local timerRagingSpiritsCD		= mod:NewCDCountTimer(17, 1265958, nil, nil, nil, 5)
local timerClaimSpiritsCD		= mod:NewCDCountTimer(42.4, 1266337, nil, nil, nil, 1)

mod.vb.channelCount = 0

function mod:OnLimitedCombatStart()
	self.vb.channelCount = 0
	--Timers sync to initial cast start, not channel start like we have to use for detection
	timerRagingSpiritsCD:Start(10.6, 1)
	timerClaimSpiritsCD:Start(33.7, 1)
end

--UNIT_SPELLCAST_START is 1.5 seconds sooner, but harder to disambiguate due to it also being used by filler casts
function mod:UNIT_SPELLCAST_CHANNEL_START(_, _, spellId)
	--RS, RS, CS, RS, RS, CS (unknown after that, continued pattern assumed)
	self.vb.channelCount = self.vb.channelCount + 1
	if self.vb.channelCount % 3 == 0 then--Claim Spirits
		warnClaimSpirits:Show(self.vb.channelCount/3)
		--Timers adjusted -4 to account for channel start vs cast start
		timerClaimSpiritsCD:Start(38.4, self.vb.channelCount/3+1)
	else--Raging Spirits
		specWarnRagingSpirits:Show(self.vb.channelCount%3)
		specWarnRagingSpirits:Play("ghostsoon")
		--Timers adjusted -1.5 to account for channel start vs cast start
		if self.vb.channelCount%3 == 1 then--First RS of the set, 17 seconds until next one
			timerRagingSpiritsCD:Start(15.5, self.vb.channelCount%3)
		else--Second RS of the set, 25.4 seconds until next one
			timerRagingSpiritsCD:Start(23.9, self.vb.channelCount%3)
		end
	end
end
