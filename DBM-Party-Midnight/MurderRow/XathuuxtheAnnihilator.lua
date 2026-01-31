local mod	= DBM:NewMod(2681, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234647)
mod:SetEncounterID(3103)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(474234, true, 474234, 1)
mod:AddPrivateAuraSoundOption(1218203, true, 1218203, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(474234, "watchfeet", 8)
	self:EnablePrivateAuraSound(1218203, "runout", 2)
end
