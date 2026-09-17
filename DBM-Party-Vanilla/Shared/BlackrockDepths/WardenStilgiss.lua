local mod	= DBM:NewMod(375, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9041)
mod:SetEncounterID(233)
mod:SetZone(230)

mod:RegisterCombat("combat")

