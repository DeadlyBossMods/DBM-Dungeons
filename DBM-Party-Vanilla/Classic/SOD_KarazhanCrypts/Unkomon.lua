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
	"SPELL_CAST_SUCCESS 1221577"
)

-- Shadow Bolt Volley
-- Seems rather random
-- "Shadow Bolt Volley-1220515-npc:238678-00001BE675 = pull:14.1, 14.6, 27.5, 16.2, 13.0, 11.3",

-- Doom
-- Decursable DoT, timer seems too random
-- "Doom-1221577-npc:238678-00001BE675 = pull:20.6, 30.7, 37.2",

-- Demonic Frenzy
-- Frenzy that can stack! Triggers rather often, so only triggering special warning every 2 stacks
-- "Demonic Frenzy-1221576-npc:238678-00001BE675 = pull:14.1, 6.5, 6.4, 8.1, 16.2, 9.7, 16.2, 11.4, 6.5, 8.1",

local warnFrenzy	= mod:NewStackAnnounce(1221576, 2, nil, "Tank|Healer|RemoveEnrage")
local warnDoom		= mod:NewAnnounce("WarnDoom", 1, 1221577, "RemoveCurse|Healer")

local specWarnFrenzy = mod:NewSpecialWarningDispel(1221576, "RemoveEnrage", nil, nil, 1, 2)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(1221576) then
		local amount = args.amount or 1
		-- I guess Tranq shot just removes one stack? So people will still see that every trigger and never go below 1? :D
		-- Need to test that. FWIW did this with a pug that had no clue this mechanic existed, ended up with 13 stacks, still easy kill on first attempt
		if amount % 2 == 0 then
			specWarnFrenzy:Show(args.destName)
			specWarnFrenzy:Play("trannow")
		end
		warnFrenzy:Show(args.destName, amount)
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(1221577) then
		warnDoom:Show()
	end
end
