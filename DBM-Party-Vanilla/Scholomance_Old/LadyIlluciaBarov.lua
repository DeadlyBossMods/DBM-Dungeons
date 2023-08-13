local mod	= DBM:NewMod("LadyIlluciaBarov", "DBM-Party-Vanilla", 16)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10502)

mod:RegisterCombat("combat")
