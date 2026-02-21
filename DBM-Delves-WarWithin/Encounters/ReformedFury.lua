local mod	= DBM:NewMod("ReformedFury", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2998)
mod:SetZone()

mod:RegisterCombat("combat")
