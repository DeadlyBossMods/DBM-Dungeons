local mod	= DBM:NewMod("TorqueClanfire", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3106, 3140)--Appears in 2 different delves
mod:SetZone()

mod:RegisterCombat("combat")
