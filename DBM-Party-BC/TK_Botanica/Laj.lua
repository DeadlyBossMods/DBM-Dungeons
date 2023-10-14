local mod = DBM:NewMod(561, "DBM-Party-BC", 14, 257)
local L = mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(17980)
mod:SetEncounterID(1927)

if not mod:IsRetail() then
	mod:SetModelID(13109)
	mod:SetModelScale(0.8)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 34697",
	"SPELL_AURA_REMOVED 34697"
)

local warnAllergic       = mod:NewTargetNoFilterAnnounce(34697, 2)

local timerAllergic      = mod:NewTargetTimer(18, 34697, nil, nil, nil, 3)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 34697 then
		warnAllergic:Show(args.destName)
		timerAllergic:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 34697 then
		timerAllergic:Stop(args.destName)
	end
end
