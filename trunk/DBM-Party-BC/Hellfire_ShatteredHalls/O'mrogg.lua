local mod	= DBM:NewMod(568, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 598 $"):sub(12, -3))
mod:SetCreatureID(16809)
mod:SetEncounterID(1937)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
