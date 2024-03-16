local mod	= DBM:NewMod("DoctorTheolenKrastinov", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(11261)
mod:SetEncounterID(mod:IsClassic() and 2802 or 458)
mod:SetZone(289)

mod:RegisterCombat("combat")
