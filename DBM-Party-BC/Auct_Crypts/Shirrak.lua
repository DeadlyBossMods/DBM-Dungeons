local mod	= DBM:NewMod(523, "DBM-Party-BC", 7, 247)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(18371)
mod:SetEncounterID(1890)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
