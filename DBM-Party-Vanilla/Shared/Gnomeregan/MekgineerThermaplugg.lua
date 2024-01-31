local isRetail = WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1)
local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local mod	= DBM:NewMod(422, "DBM-Party-Vanilla", isRetail and 4 or 7, 231)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7800)
mod:SetEncounterID(mod:IsClassic() and 2772 or 382)

mod:RegisterCombat("combat")

if isRetail then
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 93655",
		"SPELL_CAST_SUCCESS 74720",
		"SPELL_AURA_APPLIED 74720"
	)
elseif isClassic or isBCC then
	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 10101 11130 11518 11521 11798 11524 11526 11527"
	)
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 10101 11130"
	)
end

--Only retail, he was reworked in cataclysm, so it'll likely also apply to cataclysm classic
local warningPound, specWarnSteamBlast, timerSteamBlastCD, timerPoundCD
local warningKnockAway, timerKnockAwayCD
if isRetail then
	warningPound				= mod:NewTargetNoFilterAnnounce(32346, 2)

	specWarnSteamBlast			= mod:NewSpecialWarningInterrupt(93655, "HasInterrupt", nil, nil, 1, 2)

	timerSteamBlastCD			= mod:NewAITimer(180, 93655, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	timerPoundCD				= mod:NewAITimer(180, 74720, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
else--All Classic Flavors have this (including wrath and maybe cata?
	warningKnockAway			= mod:NewSpellAnnounce(10101, 2)

	timerKnockAwayCD			= mod:NewAITimer(180, 10101, nil, nil, nil, 2)
end

--Only vanilla and tbc have this
local warningActivateBomb
if isClassic or isBCC then
	warningActivateBomb			= mod:NewSpellAnnounce(11518, 2)
end

function mod:OnCombatStart(delay)
	if isRetail then
		timerSteamBlastCD:Start(1-delay)
		timerPoundCD:Start(1-delay)
	else
		timerKnockAwayCD:Start(1-delay)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 93655 then--Doesn't need IsSpell, its only registered on retail
		timerSteamBlastCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSteamBlast:Show(args.sourceName)
			specWarnSteamBlast:Play("kickcast")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(10101, 11130) then
		warningKnockAway:Show()
		timerKnockAwayCD:Start()
	elseif args:IsSpell(11518, 11521, 11798, 11524, 11526, 11527) and self:AntiSpam(3, 1) then
		warningActivateBomb:Show()
	elseif args:IsSpell(74720) then
		timerSteamBlastCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(74720) then
		warningPound:Show(args.destName)
		timerPoundCD:Start()
	end
end

