local mod	= DBM:NewMod("DirehornMatriarch", "DBM-Party-Forever", 9)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3507)
mod:SetZone(3001)

mod:RegisterCombat("combat")
