local mod	= DBM:NewMod("VindleSnapcrank", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3173, 3124)
mod:SetZone()

mod:RegisterCombat("combat")
