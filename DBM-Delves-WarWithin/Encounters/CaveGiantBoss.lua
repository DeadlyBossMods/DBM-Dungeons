local mod	= DBM:NewMod("CaveGiantBoss", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2948)
mod:SetZone()

mod:RegisterCombat("combat")
