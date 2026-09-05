local mod	= DBM:NewMod(378, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9033)
mod:SetEncounterID(236)
mod:SetModelID(8756)
mod:SetZone(230)

mod:RegisterCombat("combat")

