local mod	= DBM:NewMod(386, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9938)
mod:SetEncounterID(244)
mod:SetZone(230)

mod:RegisterCombat("combat")

