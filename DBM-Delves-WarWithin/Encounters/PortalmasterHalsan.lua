local mod	= DBM:NewMod("PortalmasterHalsan", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3329)
mod:SetZone()

mod:RegisterCombat("combat")
