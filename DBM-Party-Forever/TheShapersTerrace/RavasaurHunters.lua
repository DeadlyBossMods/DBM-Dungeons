local mod	= DBM:NewMod("RavasaurHunters", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3499)
mod:SetZone(3001)

mod:RegisterCombat("combat")
