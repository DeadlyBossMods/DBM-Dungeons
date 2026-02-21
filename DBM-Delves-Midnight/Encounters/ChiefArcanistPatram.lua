local mod	= DBM:NewMod("ChiefArcanistPatram", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3365)
mod:SetZone()

mod:RegisterCombat("combat")
