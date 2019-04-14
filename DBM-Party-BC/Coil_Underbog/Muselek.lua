local mod	= DBM:NewMod(578, "DBM-Party-BC", 5, 262)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(17826)
mod:SetEncounterID(1947)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)