local mod	= DBM:NewMod(556, "DBM-Party-BC", 2, 256)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker,duos"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17380)
mod:SetEncounterID(1924)
mod:SetZone(256, 2769)--Blood Furnace, Duos

if not mod:IsRetail() then
	mod:SetModelID(19372)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
)
