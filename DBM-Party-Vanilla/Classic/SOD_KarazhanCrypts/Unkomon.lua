if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("Unkomon", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3152)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 1221576",
	"SPELL_AURA_APPLIED_DOSE 1221576",
	"SPELL_CAST_SUCCESS 1221577",
	"SPELL_CAST_START 1220515"
)

-- Shadow Bolt Volley
-- Seems rather random
-- "Shadow Bolt Volley-1220515-npc:238678-00001BE675 = pull:14.1, 14.6, 27.5, 16.2, 13.0, 11.3",

-- Doom
-- Decursable DoT, timer seems too random
-- "Doom-1221577-npc:238678-00001BE675 = pull:20.6, 30.7, 37.2",

-- Demonic Frenzy
-- Frenzy that can stack! Triggers rather often, so only triggering special warning every 2 stacks
-- Allegedly can't be dispelled by tranq shot despite the buff flags saying so?
-- "Demonic Frenzy-1221576-npc:238678-00001BE675 = pull:14.1, 6.5, 6.4, 8.1, 16.2, 9.7, 16.2, 11.4, 6.5, 8.1",

local warnFrenzy	= mod:NewStackAnnounce(1221576, 2, nil, "Tank|Healer|RemoveEnrage")
local warnDoom		= mod:NewAnnounce("WarnDoom", 1, 1221577, "RemoveCurse|Healer")

local specWarnInterrupt = mod:NewSpecialWarningInterrupt(1220515, "HasInterrupt", nil, nil, 1, 2)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(1221576) then
		local amount = args.amount or 1
		warnFrenzy:Show(args.destName, amount)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(1221577) then
		warnDoom:Show()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(1220515) and self:CheckInterruptFilter(args.sourceGUID, true, false) then
		specWarnInterrupt:Show(args.sourceName)
		specWarnInterrupt:Play("kickcast")
	end
end
