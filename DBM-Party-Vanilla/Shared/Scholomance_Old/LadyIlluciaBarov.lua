local mod	= DBM:NewMod("LadyIlluciaBarov", "DBM-Party-Vanilla", DBM:IsRetail() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10502)
mod:SetEncounterID(mod:IsClassic() and 2806 or 462)
mod:SetZone(289)

mod:RegisterCombat("combat")
