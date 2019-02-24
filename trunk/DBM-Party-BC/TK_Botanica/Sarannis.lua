local mod = DBM:NewMod(558, "DBM-Party-BC", 14, 257)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 598 $"):sub(12, -3))

mod:SetCreatureID(17976)
mod:SetEncounterID(1925)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)