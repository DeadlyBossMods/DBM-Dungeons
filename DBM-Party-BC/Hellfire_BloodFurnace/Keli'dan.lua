local mod	= DBM:NewMod(557, "DBM-Party-BC", 2, 256)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17377)--17377 is boss, 17653 are channelers that just pull with him.
mod:SetEncounterID(1923)

if not mod:IsRetail() then
	mod:SetModelID(17153)
	mod:SetModelOffset(0, 0, -0.1)
end

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
