local mod	= DBM:NewMod(477, "DBM-Party-Vanilla", DBM:IsPostCata() and 14 or 19, 240)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(3653)
mod:SetEncounterID(587)
mod:SetModelID(5126)
mod:SetZone(43)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
end
