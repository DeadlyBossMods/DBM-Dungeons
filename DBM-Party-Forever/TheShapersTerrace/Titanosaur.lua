local mod	= DBM:NewMod("Titanosaur", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3498)
mod:SetModelID(142989)
mod:SetZone(3001)

mod:RegisterCombat("combat")
