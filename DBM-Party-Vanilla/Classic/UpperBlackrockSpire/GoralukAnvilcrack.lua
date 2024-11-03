local mod	= DBM:NewMod("GoralukAnvilcrack", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10899)
mod:SetZone(229)

mod:RegisterCombat("combat")
