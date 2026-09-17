local mod	= DBM:NewMod(373, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9024)
mod:SetEncounterID(231)
mod:SetZone(230)

mod:RegisterCombat("combat")

