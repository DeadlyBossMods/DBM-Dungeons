local mod	= DBM:NewMod(588, "DBM-Party-WotLK", 4, 273)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(26630)
mod:SetEncounterID(369, 370, 1974)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
