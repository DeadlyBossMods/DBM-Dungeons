local mod	= DBM:NewMod("Spinshroom", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2831, 3363)--Appears in 2 different delves
mod:SetZone()

mod:RegisterCombat("combat")
