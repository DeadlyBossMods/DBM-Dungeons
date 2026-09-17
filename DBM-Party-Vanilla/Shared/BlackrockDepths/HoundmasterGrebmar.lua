local mod	= DBM:NewMod(371, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9319)
mod:SetEncounterID(229)
mod:SetZone(230)

mod:RegisterCombat("combat")

