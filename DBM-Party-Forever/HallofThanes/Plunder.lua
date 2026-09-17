local mod	= DBM:NewMod("Plunder", "DBM-Party-Forever", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(11517)
mod:SetEncounterID(3494)
mod:SetZone(3065)

mod:RegisterCombat("combat")

--mod:AddAuraSoundOption(123456, true, 123456, 1, 1, "targetyou", 2, 0)
