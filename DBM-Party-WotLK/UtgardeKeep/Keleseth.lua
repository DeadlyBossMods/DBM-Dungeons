local mod	= DBM:NewMod(638, "DBM-Party-WotLK", 10, 285)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(23953)
mod:SetEncounterID(2026)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 48400",
	"SPELL_AURA_REMOVED 48400"
)

local warningTomb	= mod:NewTargetNoFilterAnnounce(48400, 4)
local timerTomb		= mod:NewTargetTimer(10, 48400, nil, nil, nil, 3)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 48400 then
		warningTomb:Show(args.destName)
		timerTomb:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 48400 then
		timerTomb:Cancel()
	end
end
