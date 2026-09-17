local mod	= DBM:NewMod(387, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9019)--Moira 8929
mod:SetEncounterID(245)
mod:SetZone(230)

mod:RegisterCombat("combat")

