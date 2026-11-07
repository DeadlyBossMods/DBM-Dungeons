local mod	= DBM:NewMod("Thunderhoof", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3500)
mod:SetModelID(144514)
mod:SetZone(3001)

mod:RegisterCombat("combat")
