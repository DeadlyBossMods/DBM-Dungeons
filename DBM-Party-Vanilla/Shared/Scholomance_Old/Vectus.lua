local mod	= DBM:NewMod("Vectus", "DBM-Party-Vanilla", DBM:IsRetail() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10432)
mod:SetEncounterID(mod:IsClassic() and 2813 or 455)
mod:SetZone(289)

mod:RegisterCombat("combat")
