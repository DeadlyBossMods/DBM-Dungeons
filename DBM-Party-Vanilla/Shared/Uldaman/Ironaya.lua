local mod	= DBM:NewMod(469, "DBM-Party-Vanilla", DBM:IsPostCata() and 13 or 18, 239)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7228)
mod:SetEncounterID(549)

mod:RegisterCombat("combat")

if DBM:IsRetail() then
	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 8374 110762 11876"
	)
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 8374 11876"
	)
end

local knockAway = DBM:GetSpellInfo(110762)
local warnKnockAway, timerKnockAwayCD
local warningArcingSmash			= mod:NewSpellAnnounce(8374, 2)
local warningWarStomp				= mod:NewSpellAnnounce(11876, 2)
if knockAway then--Not classic, only initialize these warnings/timers on retail
	warnKnockAway					= mod:NewSpellAnnounce(110762, 2)
end

local timerArcingSmashCD			= mod:NewAITimer(180, 8374, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerWarStompCD				= mod:NewAITimer(180, 11876, nil, nil, nil, 2)
if knockAway then--Not classic, only initialize these warnings/timers on retail
	timerKnockAwayCD				= mod:NewAITimer(180, 110762, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
end

function mod:OnCombatStart(delay)
	timerArcingSmashCD:Start(1-delay)
	timerWarStompCD:Start(1-delay)
	if knockAway then
		timerKnockAwayCD:Start(1-delay)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(8374) then
		warningArcingSmash:Show()
		timerArcingSmashCD:Start()
	elseif args.spellId == 110762 then
		warnKnockAway:Show()
		timerKnockAwayCD:Start()
	elseif args:IsSpell(11876) then
		warningWarStomp:Show()
		timerWarStompCD:Start()
	end
end
