local mod	= DBM:NewMod("SpeakerXanventh", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2947)
mod:SetZone()

mod:RegisterCombat("combat")
