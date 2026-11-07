local mod	= DBM:NewMod("TidemistressCazass", "DBM-Party-Forever", 7)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3410)
mod:SetModelID(4973)
mod:SetZone(2994)

mod:RegisterCombat("combat")
