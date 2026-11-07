local mod	= DBM:NewMod("Venomridge", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3501)
mod:SetModelID(144511)
mod:SetZone(3001)

mod:RegisterCombat("combat")
