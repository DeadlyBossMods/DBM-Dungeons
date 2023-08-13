local mod	= DBM:NewMod("JandiceBarov", "DBM-Party-Vanilla", 16)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10503)

mod:RegisterCombat("combat")
