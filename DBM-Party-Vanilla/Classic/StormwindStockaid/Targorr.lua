local mod	= DBM:NewMod("Targorr", "DBM-Party-Vanilla", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(1696)
mod:SetZone(34)

mod:RegisterCombat("combat")
