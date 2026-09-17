local mod	= DBM:NewMod(380, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9537)
mod:SetEncounterID(238)
mod:SetZone(230)

mod:RegisterCombat("combat")

