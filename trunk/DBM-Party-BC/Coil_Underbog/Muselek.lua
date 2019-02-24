local mod	= DBM:NewMod(578, "DBM-Party-BC", 5, 262)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 598 $"):sub(12, -3))
mod:SetCreatureID(17826)
mod:SetEncounterID(1947)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)