local mod	= DBM:NewMod("OverseerMugg", "DBM-Party-Forever", 6)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3451)
mod:SetZone(3039)

mod:RegisterCombat("combat")
