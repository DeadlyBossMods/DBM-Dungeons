local mod	= DBM:NewMod("BlindHunter", "DBM-Party-Vanilla", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(4425)
--mod:SetEncounterID(438)
mod:SetZone(47)

mod:RegisterCombat("combat")

--Just a stats module, nothing more, boss doesn't really do anything, this just tracks your kills
