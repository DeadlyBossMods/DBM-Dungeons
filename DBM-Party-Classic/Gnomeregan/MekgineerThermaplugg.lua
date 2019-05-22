local mod	= DBM:NewMod(422, "DBM-Party-Classic", 5, 231)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7800)
mod:SetEncounterID(382)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 93655",
	"SPELL_CAST_SUCCESS 74720",
	"SPELL_AURA_APPLIED 74720"
)

--local warningSoul	= mod:NewTargetAnnounce(32346, 2)
local wowTOC = DBM:GetTOC()
local specWarnSteamBlast, timerSteamBlastCD
local warningPound, timerPoundCD
if wowTOC >= 20000 then--Not classic, only initialize these warnings/timers on retail
	warningPound				= mod:NewTargetAnnounce(32346, 2)

	specWarnSteamBlast			= mod:NewSpecialWarningInterrupt(93655, "HasInterrupt", nil, nil, 1, 2)

	timerSteamBlastCD			= mod:NewAITimer(180, 93655, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
	timerPoundCD				= mod:NewAITimer(180, 74720, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
end

function mod:OnCombatStart(delay)
	if timerSteamBlastCD then
		timerSteamBlastCD:Start(1-delay)
		timerPoundCD:Start(1-delay)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 93655 then
		timerSteamBlastCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSteamBlast:Show(args.sourceName)
			specWarnSteamBlast:Play("kickcast")
		end
	end
end

function mod:SPELL_CAST_SUCESS(args)
	if args.spellId == 74720 then
		timerSteamBlastCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 74720 then
		warningPound:Show(args.destName)
	end
end
