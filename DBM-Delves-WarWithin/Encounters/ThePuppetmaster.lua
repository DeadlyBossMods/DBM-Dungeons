local mod	= DBM:NewMod("ThePuppetmaster", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3006)
mod:SetZone()

mod:RegisterCombat("combat")
