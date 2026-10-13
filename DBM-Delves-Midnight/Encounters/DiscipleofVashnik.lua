local mod	= DBM:NewMod("DiscipleofVashnik", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3522, 3537, 3559, 3563)
mod:SetZone()

mod:RegisterCombat("combat")
