local mod	= DBM:NewMod("Rathmael", "DBM-Party-Forever", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(11517)
mod:SetEncounterID(3354)
mod:SetZone(2999)

mod:RegisterCombat("combat")

--mod:AddAuraSoundOption(123456, true, 123456, 1, 1, "targetyou", 2, 0)
