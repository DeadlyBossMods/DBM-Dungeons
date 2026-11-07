local mod	= DBM:NewMod("KingOp", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3504)
mod:SetZone(3001)

mod:RegisterCombat("combat")
