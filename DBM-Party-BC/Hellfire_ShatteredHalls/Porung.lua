local mod	= DBM:NewMod(728, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(20923)
mod:SetEncounterID(1935)

if not mod:IsRetail() then
	mod:SetModelID(17725)
	mod:SetModelOffset(0, 0, -0.1)
end

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
