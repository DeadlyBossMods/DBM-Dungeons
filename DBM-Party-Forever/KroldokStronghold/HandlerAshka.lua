local mod	= DBM:NewMod("HandlerAshka", "DBM-Party-Forever", 6)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3453)
mod:SetZone(3039)

mod:RegisterCombat("combat")
