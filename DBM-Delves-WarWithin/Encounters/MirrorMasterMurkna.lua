local mod	= DBM:NewMod("MirrorMasterMurkna", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2999)
mod:SetZone()

mod:RegisterCombat("combat")
