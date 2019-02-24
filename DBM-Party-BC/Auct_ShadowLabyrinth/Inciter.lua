local mod = DBM:NewMod(545, "DBM-Party-BC", 10, 253)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 643 $"):sub(12, -3))

mod:SetCreatureID(18667)
mod:SetEncounterID(1909)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 33676"
)

local warnChaos         = mod:NewSpellAnnounce(33676)

local timerChaos        = mod:NewBuffActiveTimer(15, 33676, nil, nil, nil, 2)
local timerNextChaos    = mod:NewNextTimer(70, 33676, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
    timerNextChaos:Start(15-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 33676 then
		warnChaos:Show()
		timerChaos:Start()
		timerNextChaos:Start()
	end
end