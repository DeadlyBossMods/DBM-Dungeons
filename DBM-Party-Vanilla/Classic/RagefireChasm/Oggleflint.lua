local mod	= DBM:NewMod("Oggleflint", "DBM-Party-Vanilla", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(11517)
--mod:SetEncounterID(1443)

mod:RegisterCombat("combat")
