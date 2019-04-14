local mod	= DBM:NewMod(537, "DBM-Party-BC", 8, 250)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(18344)
mod:SetEncounterID(1899)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)