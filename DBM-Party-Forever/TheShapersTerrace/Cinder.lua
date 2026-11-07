local mod	= DBM:NewMod("Cinder", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3503)
mod:SetZone(3001)

mod:RegisterCombat("combat")
