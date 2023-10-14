local mod	= DBM:NewMod(576, "DBM-Party-BC", 5, 262)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17770)
mod:SetEncounterID(1946)

if not mod:IsRetail() then
	mod:SetModelID(17228)
	mod:SetModelOffset(-2, 0.4, -1)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 31673"
)

local warnFoulSpores  = mod:NewSpellAnnounce(31673, 2)--Iffy, this may not work. Dry-coded off wowhead.

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 31673 then
		warnFoulSpores:Show()
	end
end
