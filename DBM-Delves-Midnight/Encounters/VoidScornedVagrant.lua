local mod	= DBM:NewMod("VoidScornedVagrant", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3404)
mod:SetZone()

mod:RegisterCombat("combat")
