local mod	= DBM:NewMod(396, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9568)
mod:SetEncounterID(275)
mod:SetZone(229)

mod:RegisterCombat("combat")

