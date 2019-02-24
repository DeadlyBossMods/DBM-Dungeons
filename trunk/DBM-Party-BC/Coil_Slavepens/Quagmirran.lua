local mod	= DBM:NewMod(572, "DBM-Party-BC", 4, 260)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 598 $"):sub(12, -3))
mod:SetCreatureID(17942)
mod:SetEncounterID(1940)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)