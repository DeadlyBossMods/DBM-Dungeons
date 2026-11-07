local mod	= DBM:NewMod("Snowtalon", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3597)
mod:SetModelID(143122)
mod:SetZone(3001)

mod:RegisterCombat("combat")
