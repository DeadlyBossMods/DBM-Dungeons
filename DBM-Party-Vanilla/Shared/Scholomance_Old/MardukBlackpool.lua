local mod	= DBM:NewMod("MardukBlackpool", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10433)
mod:SetEncounterID(mod:IsClassic() and 2809 or 454)
mod:SetZone(289)

mod:RegisterCombat("combat")
