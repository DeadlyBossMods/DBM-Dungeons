local mod	= DBM:NewMod(388, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9196)
mod:SetEncounterID(267)
mod:SetModelID(11565)
mod:SetZone(229)

mod:RegisterCombat("combat")

