local mod	= DBM:NewMod("TombRaiderDrywhisker", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2878)
mod:SetZone()

mod:RegisterCombat("combat")
