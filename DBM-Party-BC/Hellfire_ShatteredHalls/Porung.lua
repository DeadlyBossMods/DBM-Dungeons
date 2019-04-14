local mod	= DBM:NewMod(728, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(20923)
mod:SetEncounterID(1935)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
