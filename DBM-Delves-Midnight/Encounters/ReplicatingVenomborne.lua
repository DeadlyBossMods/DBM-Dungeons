local mod	= DBM:NewMod("ReplicatingVenomborne", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3461, 3529, 3557, 3595)
mod:SetZone()

mod:RegisterCombat("combat")
