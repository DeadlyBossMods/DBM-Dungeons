local mod	= DBM:NewMod(395, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10268)
mod:SetEncounterID(273)
mod:SetZone(229)

mod:RegisterCombat("combat")

