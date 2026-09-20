local mod	= DBM:NewMod("BruegalIronknuckle", "DBM-Party-Vanilla", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(1720)
mod:SetZone(34)
mod:SetModelID(2142)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
end
