local mod	= DBM:NewMod("CraggleFritzbrains", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3095)
mod:SetZone()

mod:RegisterCombat("combat")
