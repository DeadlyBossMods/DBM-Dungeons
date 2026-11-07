local mod	= DBM:NewMod("SlavecrusherGrox", "DBM-Party-Forever", 6)

mod:SetRevision("@file-date-integer@")
mod:EnableGenericTrash()
mod:SetEncounterID(3450)
mod:SetModelID(141217)
mod:SetZone(3039)

mod:RegisterCombat("combat")
