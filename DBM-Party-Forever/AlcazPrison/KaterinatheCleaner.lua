local mod	= DBM:NewMod("KaterinatheCleaner", "DBM-Party-Forever", 7)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3418)
mod:SetZone(2994)

mod:RegisterCombat("combat")
