local mod	= DBM:NewMod(596, "DBM-Party-WotLK", 5, 274)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(29306)
mod:SetEncounterID(1981)
mod:SetModelID(27061)
--
mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
