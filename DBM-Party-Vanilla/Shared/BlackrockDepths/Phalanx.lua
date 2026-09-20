local mod	= DBM:NewMod(381, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9502)
mod:SetEncounterID(239)
mod:SetModelID(8177)
mod:SetZone(230)

mod:RegisterCombat("combat")

