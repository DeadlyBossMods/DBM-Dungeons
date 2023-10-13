local mod	= DBM:NewMod("TheBeast", "DBM-Party-Vanilla", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10430)

mod:RegisterCombat("combat")
