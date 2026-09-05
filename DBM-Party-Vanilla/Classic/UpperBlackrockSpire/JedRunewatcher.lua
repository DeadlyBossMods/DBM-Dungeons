local mod	= DBM:NewMod("JedRunewatcher", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10509)
mod:SetZone(229)
mod:SetModelID(9686)

mod:RegisterCombat("combat")
