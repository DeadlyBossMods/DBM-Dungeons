local mod	= DBM:NewMod("TwilightCommanderZarmok", "DBM-Party-Forever", 6)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3452)
mod:SetModelID(141219)
mod:SetZone(3039)

mod:RegisterCombat("combat")
