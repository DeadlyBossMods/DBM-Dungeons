local mod	= DBM:NewMod(93, "DBM-Party-Cataclysm", 2, 63)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(47739)
mod:SetEncounterID(1060, 2973, 2978)
mod:SetZone(36)
mod:DisableInTimeWalking()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
