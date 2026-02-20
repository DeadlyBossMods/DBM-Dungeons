local mod	= DBM:NewMod("FacelessOne", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2949)
mod:SetZone()

mod:RegisterCombat("combat")
