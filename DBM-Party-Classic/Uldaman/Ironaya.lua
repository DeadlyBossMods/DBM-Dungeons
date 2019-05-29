local mod	= DBM:NewMod(469, "DBM-Party-Classic", 12, 239)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7228)
mod:SetEncounterID(549)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 8374 110762 11876"
)

local wowTOC = DBM:GetTOC()
local warnKnockAway, timerKnockAwayCD
local warningArcingSmash			= mod:NewSpellAnnounce(8374, 2)
local warningWarStomp				= mod:NewSpellAnnounce(11876, 2)
if wowTOC >= 20000 then--Not classic, only initialize these warnings/timers on retail
	warnKnockAway					= mod:NewSpellAnnounce(110762, 2)
end

local timerArcingSmashCD			= mod:NewAITimer(180, 8374, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerWarStompCD				= mod:NewAITimer(180, 11876, nil, nil, nil, 2)
if wowTOC >= 20000 then--Not classic, only initialize these warnings/timers on retail
	timerKnockAwayCD				= mod:NewAITimer(180, 110762, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
end

function mod:OnCombatStart(delay)
	timerArcingSmashCD:Start(1-delay)
	timerWarStompCD:Start(1-delay)
	if timerKnockAwayCD then
		timerKnockAwayCD:Start(1-delay)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 8374 then
		warningArcingSmash:Show()
		timerArcingSmashCD:Start()
	elseif args.spellId == 110762 then
		warnKnockAway:Show()
		timerKnockAwayCD:Start()
	elseif args.spellId == 11876 then
		warningWarStomp:Show()
		timerWarStompCD:Start()
	end
end
