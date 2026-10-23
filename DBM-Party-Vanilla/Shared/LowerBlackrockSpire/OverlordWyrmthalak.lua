local mod	= DBM:NewMod(396, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(9568)
mod:SetEncounterID(275)
mod:SetModelID(8711)
mod:SetZone(229)

mod:RegisterCombat("combat")

