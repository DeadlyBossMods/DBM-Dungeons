local mod	= DBM:NewMod("Nanaya", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3502)
mod:SetModelID(143832)
mod:SetZone(3001)

mod:RegisterCombat("combat")
