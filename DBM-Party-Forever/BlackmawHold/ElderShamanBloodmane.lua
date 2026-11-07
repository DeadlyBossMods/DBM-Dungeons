local mod	= DBM:NewMod("ElderShamanBloodmane", "DBM-Party-Forever", 8)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3327)
mod:SetModelID(130440)
mod:SetZone(2974)

mod:RegisterCombat("combat")
