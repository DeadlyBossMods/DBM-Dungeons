local mod	= DBM:NewMod("CommanderSpringvale", "DBM-Party-Vanilla", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(4278)
mod:SetZone(33)

mod:RegisterCombat("combat")
