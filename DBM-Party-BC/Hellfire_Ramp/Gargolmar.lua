local mod	= DBM:NewMod(527, "DBM-Party-BC", 1, 248)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 598 $"):sub(12, -3))
mod:SetCreatureID(17306)
mod:SetEncounterID(1893)
mod:SetModelID(18236)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)