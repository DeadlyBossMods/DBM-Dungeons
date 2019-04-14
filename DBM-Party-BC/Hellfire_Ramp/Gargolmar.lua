local mod	= DBM:NewMod(527, "DBM-Party-BC", 1, 248)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(17306)
mod:SetEncounterID(1893)
mod:SetModelID(18236)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)