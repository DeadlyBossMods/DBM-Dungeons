local mod	= DBM:NewMod(394, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10220)
mod:SetEncounterID(274)
mod:SetModelID(9567)
mod:SetZone(229)

mod:RegisterCombat("combat")

