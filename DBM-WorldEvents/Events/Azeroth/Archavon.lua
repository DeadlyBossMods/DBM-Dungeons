local mod	= DBM:NewMod("ArchavonEvent", "DBM-WorldEvents", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(227257)
--mod:SetModelID(21435)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 458670 458672",
	"SPELL_CAST_SUCCESS 458676"
--	"SPELL_AURA_APPLIED"
)

local warnShards			= mod:NewSpellAnnounce(58678, 2)
local warnStomp				= mod:NewSpellAnnounce(458670, 3)
local warnLeap				= mod:NewSpellAnnounce(458676, 3)

local timerRockShards		= mod:NewAITimer(45, 458672, nil, nil, nil, 3)
local timerNextStomp		= mod:NewAITimer(45, 458670, nil, nil, nil, 2)
local timerLeap				= mod:NewAITimer(45, 458676, nil, nil, nil, 3)

function mod:SPELL_CAST_START(args)
	if args.spellId == 458670 then
		warnStomp:Show()
		timerNextStomp:Start()
	elseif args.spellId == 458672 then
		warnShards:Show()
		timerRockShards:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 458676 then
		  warnLeap:Show()
		  timerLeap:Start()
	  end
  end
