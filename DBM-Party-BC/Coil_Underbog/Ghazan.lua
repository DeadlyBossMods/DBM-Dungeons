local mod	= DBM:NewMod(577, "DBM-Party-BC", 5, 262)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(18105)
mod:SetEncounterID(1945)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)