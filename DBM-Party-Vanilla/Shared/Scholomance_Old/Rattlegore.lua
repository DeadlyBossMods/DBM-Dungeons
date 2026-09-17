local mod	= DBM:NewMod("Rattlegore", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(11622)
mod:SetEncounterID(mod:IsClassic() and 2811 or 453)
mod:SetZone(289)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
end
