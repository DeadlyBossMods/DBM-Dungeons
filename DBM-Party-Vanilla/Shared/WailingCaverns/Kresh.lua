local mod	= DBM:NewMod(477, "DBM-Party-Vanilla", DBM:IsRetail() and 14 or 19, 240)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3653)
mod:SetEncounterID(587)

mod:RegisterCombat("combat")
