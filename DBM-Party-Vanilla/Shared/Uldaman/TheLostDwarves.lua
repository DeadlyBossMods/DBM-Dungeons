if UnitFactionGroup("player") == "Alliance" then return end
local mod	= DBM:NewMod(468, "DBM-Party-Vanilla", DBM:IsPostCata() and 13 or 18, 239)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(6906, 6907, 6908)
mod:SetEncounterID(548)
mod:SetBossHPInfoToHighest()
mod:SetZone(70)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
end
