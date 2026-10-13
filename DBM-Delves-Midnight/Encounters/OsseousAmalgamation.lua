local mod	= DBM:NewMod("OsseousAmalgamation", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3560)
mod:SetZone()

mod:RegisterCombat("combat")
