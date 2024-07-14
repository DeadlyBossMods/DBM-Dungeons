local mod	= DBM:NewMod("Diathorus", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3024)
--mod:SetCreatureID(4275)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 460755",
	"SPELL_AURA_APPLIED 460759"
)

local specWarnGTFO 			= mod:NewSpecialWarningGTFO(460759, nil, nil, nil, 1, 8)
local specWarnVeilOfShadow	= mod:NewSpecialWarningInterrupt(460755, "HasInterrupt", nil, nil, 1, 2)

-- Shadow Bolts can be kicked, but they are cast a lot, warnings would be very spammy
-- "Shadow Bolt-460749-npc:227019-000012D5C6 = pull:42.6, 1.7, 2.0, 3.2, 11.3, 7.0, 2.7, 1.6, 1.6, 9.7, 1.6, 4.8, 1.6, 1.6, 1.7",

-- Wowhead says to not stand in 460764, but I can't see that in my logs as a fire effect? Seems like a normal boss buff?


function mod:SPELL_CAST_START(args)
	if args:IsSpell(460755) then
		specWarnVeilOfShadow:Play("kickcast")
		specWarnVeilOfShadow:Show(args.sourceName)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(460759) and args:IsPlayer() and self:AntiSpam(2.5, 1) then
		specWarnGTFO:Play("watchfeet")
		specWarnGTFO:Show(args.spellName)
	end
end
