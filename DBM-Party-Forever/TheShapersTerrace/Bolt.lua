local mod	= DBM:NewMod("Bolt", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3505)
mod:SetZone(3001)

mod:RegisterCombat("combat")
