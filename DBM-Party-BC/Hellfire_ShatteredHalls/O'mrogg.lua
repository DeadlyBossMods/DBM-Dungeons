local mod	= DBM:NewMod(568, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(16809)
mod:SetEncounterID(1937)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
