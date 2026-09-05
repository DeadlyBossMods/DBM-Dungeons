local mod	= DBM:NewMod("DeathswornCaptain", "DBM-Party-Vanilla", 14)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(3872)
mod:SetZone(33)
mod:SetModelID(3224)

mod:RegisterCombat("combat")
