local mod	= DBM:NewMod(424, "DBM-Party-Vanilla", DBM:IsPostCata() and 6 or 8, 232)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(12258)
mod:SetEncounterID(423)
mod:SetZone(349)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
end
