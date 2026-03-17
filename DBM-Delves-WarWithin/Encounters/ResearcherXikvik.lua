local mod	= DBM:NewMod("ResearcherXikvik", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2992)
mod:SetZone()

mod:RegisterCombat("combat")
