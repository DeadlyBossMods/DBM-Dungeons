local mod	= DBM:NewMod(376, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9056)
mod:SetEncounterID(234)
mod:SetModelID(8704)
mod:SetZone(230)

mod:RegisterCombat("combat")

