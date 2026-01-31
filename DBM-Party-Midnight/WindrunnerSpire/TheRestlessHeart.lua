local mod	= DBM:NewMod(2658, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231636)
mod:SetEncounterID(3059)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1282911, true, 1282911, 1)
mod:AddPrivateAuraSoundOption(1253979, true, 1253979, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1282911, "lineyou", 17)
	self:EnablePrivateAuraSound(1253979, "movetopool", 15)
end
