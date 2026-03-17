local mod	= DBM:NewMod("UnderLordViktis", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2989)
mod:SetZone()

mod:RegisterCombat("combat")
