local mod	= DBM:NewMod("DeathlessGuardians", "DBM-Party-Forever", 5)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3478)
mod:SetModelID(142268)
mod:SetZone(2970)

mod:RegisterCombat("combat")
