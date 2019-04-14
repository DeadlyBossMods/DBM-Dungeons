local mod = DBM:NewMod(558, "DBM-Party-BC", 14, 257)
local L = mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(17976)
mod:SetEncounterID(1925)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)