local mod	= DBM:NewMod("InfiltratorGarand", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3405)
mod:SetZone()

mod:RegisterCombat("combat")
