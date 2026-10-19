local mod	= DBM:NewMod(386, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(9938)
mod:SetEncounterID(244)
mod:SetModelID(12162)
mod:SetZone(230)

mod:RegisterCombat("combat")

