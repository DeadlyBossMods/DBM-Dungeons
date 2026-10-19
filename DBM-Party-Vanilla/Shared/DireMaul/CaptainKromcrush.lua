local mod	= DBM:NewMod(415, "DBM-Party-Vanilla", DBM:IsPostCata() and 3 or 6, 230)
local L		= mod:GetLocalizedStrings()
mod:SetRevision("@file-date-integer@")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(14325)
mod:SetEncounterID(366)
mod:SetModelID(11564)
mod:SetZone(429)
mod:RegisterCombat("combat")
mod:DisableFriendlyDetection()

