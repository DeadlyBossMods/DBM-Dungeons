local mod	= DBM:NewMod(628, "DBM-Party-WotLK", 12, 283)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(string.sub("@file-date-integer@", 1, -5))
mod:SetCreatureID(29313)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
