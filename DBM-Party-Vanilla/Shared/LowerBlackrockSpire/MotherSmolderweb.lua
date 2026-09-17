local mod	= DBM:NewMod(391, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10596)
mod:SetEncounterID(270)
mod:SetZone(229)

mod:RegisterCombat("combat")

