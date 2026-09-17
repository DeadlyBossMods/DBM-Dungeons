local mod	= DBM:NewMod(377, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9016)
mod:SetEncounterID(235)
mod:SetZone(230)

mod:RegisterCombat("combat")

