local mod	= DBM:NewMod(407, "DBM-Party-Vanilla", DBM:IsPostCata() and 3 or 6, 230)
local L		= mod:GetLocalizedStrings()
mod:SetRevision("@file-date-integer@")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(11488)
mod:SetEncounterID(347)
mod:SetModelID(11270)
mod:SetZone(429)
mod:RegisterCombat("combat")
mod:DisableFriendlyDetection()

