local mod	= DBM:NewMod("Lumenia", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3416)
mod:SetZone()

mod:RegisterCombat("combat")
