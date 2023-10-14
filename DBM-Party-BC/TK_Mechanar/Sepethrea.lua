local mod = DBM:NewMod(564, "DBM-Party-BC", 13, 258)
local L = mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(19221)
mod:SetEncounterID(1930)

if not mod:IsRetail() then
	mod:SetModelID(19166)
end

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(
--)
