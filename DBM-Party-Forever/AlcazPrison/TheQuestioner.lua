local mod	= DBM:NewMod("TheQuestioner", "DBM-Party-Forever", 7)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3415)
mod:SetModelID(140092)
mod:SetZone(2994)

mod:RegisterCombat("combat")
