local mod	= DBM:NewMod("BlackmawBehemoth", "DBM-Party-Forever", 8)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3323)
mod:SetZone(2974)

mod:RegisterCombat("combat")
