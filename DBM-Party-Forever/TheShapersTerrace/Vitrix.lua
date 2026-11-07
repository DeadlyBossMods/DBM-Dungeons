local mod	= DBM:NewMod("Vitrix", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3600)
mod:SetZone(3001)

mod:RegisterCombat("combat")
