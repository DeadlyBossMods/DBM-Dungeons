local mod	= DBM:NewMod(92, "DBM-Party-Cataclysm", 2, 63)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(47626)
mod:SetEncounterID(1062, 2974, 2979)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)