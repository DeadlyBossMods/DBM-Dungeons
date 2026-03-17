local mod	= DBM:NewMod("Spinshroom", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2831)--TWW Version
mod:SetZone()

mod:RegisterCombat("combat")
