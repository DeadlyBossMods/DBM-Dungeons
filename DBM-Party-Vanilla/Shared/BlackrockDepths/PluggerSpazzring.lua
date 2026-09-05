local mod	= DBM:NewMod(383, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9499)
mod:SetEncounterID(241)
mod:SetModelID(8658)
mod:SetZone(230)

mod:RegisterCombat("combat")

