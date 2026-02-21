local mod	= DBM:NewMod("OverseerKaskel", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2990)
mod:SetZone()

mod:RegisterCombat("combat")
