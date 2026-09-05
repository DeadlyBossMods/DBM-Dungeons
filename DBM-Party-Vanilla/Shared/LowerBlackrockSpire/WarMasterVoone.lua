local mod	= DBM:NewMod(390, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9237)
mod:SetEncounterID(269)
mod:SetModelID(9733)
mod:SetZone(229)

mod:RegisterCombat("combat")

