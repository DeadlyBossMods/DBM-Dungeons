local mod = DBM:NewMod(564, "DBM-Party-BC", 13, 258)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 598 $"):sub(12, -3))

mod:SetCreatureID(19221)
mod:SetEncounterID(1930)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)