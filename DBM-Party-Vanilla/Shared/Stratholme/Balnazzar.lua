local mod	= DBM:NewMod(449, "DBM-Party-Vanilla", DBM:IsRetail() and 10 or 16, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
if DBM:IsRetail() then
	mod:SetCreatureID(10813)--10812 Grand Crusader Dathrohan (stage 1 classic, on live the boss starts out as Balnazzar)
else
	mod:SetCreatureID(10812, 10813)
	mod:SetBossHPInfoToHighest()
end
mod:SetEncounterID(478)

mod:RegisterCombat("combat")

if DBM:IsRetail() then
	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 17405 66290 13704",
		"SPELL_AURA_APPLIED 17405 66290"
	)
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 17405 13704",
		"SPELL_AURA_APPLIED 17405",
		"UNIT_DIED"
	)
end

local warningDomination					= mod:NewTargetNoFilterAnnounce(17405, 4)
local warningPsychicScream				= mod:NewSpellAnnounce(13704, 3)

local timerDominationCD					= mod:NewAITimer(180, 17405, nil, nil, nil, 3)
local timerPsychicScreamCD				= mod:NewAITimer(180, 13704, nil, nil, nil, 2, nil, DBM_COMMON_L.MAGIC_ICON)
local warningSleep, timerSleepCD
if DBM:IsRetail() then
	warningSleep						= mod:NewTargetNoFilterAnnounce(66290, 3)
	timerSleepCD						= mod:NewAITimer(180, 66290, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
end

function mod:OnCombatStart(delay)
	--Balnazzar timers start on pull on retail, in classic you have to beat up a human first
	if self:IsRetail() then
		timerDominationCD:Start(1-delay)
		timerSleepCD:Start(1-delay)
		timerPsychicScreamCD:Start(1-delay)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(17405) then
		timerDominationCD:Start()
	elseif args.spellId == 66290 then--Retail only so no need to run it through wrapper
		timerSleepCD:Start()
	elseif args:IsSpell(13704) then
		warningPsychicScream:Show()
		timerPsychicScreamCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(17405) then
		warningDomination:Show(args.destName)
	elseif args.spellId == 66290 then
		warningSleep:Show(args.destName)
	end
end

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 10813 then
		DBM:EndCombat(self)
	end
end
