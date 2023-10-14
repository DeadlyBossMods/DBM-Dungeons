local mod	= DBM:NewMod(568, "DBM-Party-BC", 3, 259)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(16809)
mod:SetEncounterID(1937)

if not mod:IsRetail() then
	mod:SetModelID(18031)
	mod:SetModelOffset(0, 0, -0.1)
end

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
