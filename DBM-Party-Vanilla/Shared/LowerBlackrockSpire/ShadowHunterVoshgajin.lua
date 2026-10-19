local mod	= DBM:NewMod(389, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(9236)
mod:SetEncounterID(268)
mod:SetModelID(9732)
mod:SetZone(229)

mod:RegisterCombat("combat")

