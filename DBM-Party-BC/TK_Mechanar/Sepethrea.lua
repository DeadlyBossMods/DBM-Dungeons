local mod = DBM:NewMod(564, "DBM-Party-BC", 13, 258)
local L = mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(19221)
mod:SetEncounterID(1930)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)