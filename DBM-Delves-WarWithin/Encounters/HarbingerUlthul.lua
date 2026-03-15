local mod	= DBM:NewMod("HarbingerUlthul", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3096)
mod:SetZone()

mod:RegisterCombat("combat")
