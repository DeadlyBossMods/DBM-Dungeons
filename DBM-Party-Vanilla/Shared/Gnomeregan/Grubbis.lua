local mod	= DBM:NewMod(419, "DBM-Party-Vanilla", DBM:IsPostCata() and 4 or 7, 231)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7361)
mod:SetEncounterID(mod:IsClassic() and 2768 or 379)

mod:RegisterCombat("combat")
