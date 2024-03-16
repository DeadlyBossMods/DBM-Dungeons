local mod	= DBM:NewMod("TheRavenian", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10507)
mod:SetEncounterID(mod:IsClassic() and 2812 or 460)
mod:SetZone(289)

mod:RegisterCombat("combat")
