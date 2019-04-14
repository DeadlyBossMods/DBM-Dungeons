local mod	= DBM:NewMod(572, "DBM-Party-BC", 4, 260)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(17942)
mod:SetEncounterID(1940)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)