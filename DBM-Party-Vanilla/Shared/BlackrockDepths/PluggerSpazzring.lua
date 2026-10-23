local mod	= DBM:NewMod(383, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(9499)
mod:SetEncounterID(241)
mod:SetModelID(8652)
mod:SetZone(230)

mod:RegisterCombat("combat")

