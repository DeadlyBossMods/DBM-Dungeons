local mod	= DBM:NewMod("ShaofAngerEvent", "DBM-WorldEvents", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226646)
--mod:SetModelID(21435)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 456281 456112",
	"SPELL_AURA_APPLIED 456291 456112"
)
local warnGrowingAnger			= mod:NewTargetNoFilterAnnounce(456112, 4)--Mind control trigger
local warnAggressiveBehavior	= mod:NewTargetAnnounce(456291, 4)--Actual mind control targets
local warnUnleashedWrath		= mod:NewSpellAnnounce(456281, 3)

local specWarnGrowingAnger		= mod:NewSpecialWarningYou(119622, nil, nil, nil, 1, 2)
--local specWarnGTFO			= mod:NewSpecialWarningGTFO(119610, nil, nil, nil, 1, 8)

local timerGrowingAngerCD		= mod:NewAITimer(32, 456112, nil, nil, nil, 3)
local timerUnleashedWrathCD	    = mod:NewAITimer(53, 456281, nil, nil, nil, 2)
--local timerUnleashedWrath		= mod:NewBuffActiveTimer(24, 119488, nil, "Tank|Healer", nil, 5)

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 456281 then
		warnUnleashedWrath:Show()
		timerUnleashedWrathCD:Start()
	elseif spellId == 456112 then
		timerGrowingAngerCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 456112 then
		warnGrowingAnger:CombinedShow(1.2, args.destName)
		if args:IsPlayer() then
			specWarnGrowingAnger:Show()
			specWarnGrowingAnger:Play("findmc")
		end
	elseif spellId == 456291 then
		warnAggressiveBehavior:CombinedShow(2.5, args.destName)
	end
end
