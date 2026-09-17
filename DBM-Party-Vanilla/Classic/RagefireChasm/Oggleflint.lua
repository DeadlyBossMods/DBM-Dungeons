local mod	= DBM:NewMod("Oggleflint", "DBM-Party-Vanilla", 9)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(11517)
--mod:SetEncounterID(1443)
mod:SetZone(389)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
end
