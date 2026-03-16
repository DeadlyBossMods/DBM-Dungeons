local mod	= DBM:NewMod("LeviathanCaller", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3002)
mod:SetZone()

mod:RegisterCombat("combat")

