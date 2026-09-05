local mod	= DBM:NewMod(370, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9025)
mod:SetEncounterID(228)
mod:SetModelID(5781)
mod:SetZone(230)

mod:RegisterCombat("combat")

