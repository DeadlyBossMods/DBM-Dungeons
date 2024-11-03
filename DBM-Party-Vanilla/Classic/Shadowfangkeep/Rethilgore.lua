local mod	= DBM:NewMod("Rethilgore", "DBM-Party-Vanilla", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3914)
mod:SetZone(33)

mod:RegisterCombat("combat")
