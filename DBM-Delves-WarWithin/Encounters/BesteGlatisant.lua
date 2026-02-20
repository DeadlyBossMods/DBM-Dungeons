local mod	= DBM:NewMod("BesteGlatisant", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3210)
mod:SetZone()

mod:RegisterCombat("combat")
