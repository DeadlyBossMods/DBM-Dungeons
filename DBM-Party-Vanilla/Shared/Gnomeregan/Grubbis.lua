local mod	= DBM:NewMod(419, "DBM-Party-Vanilla", DBM:IsRetail() and 4 or 7, 231)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7361)
mod:SetEncounterID(379)

mod:RegisterCombat("combat")
