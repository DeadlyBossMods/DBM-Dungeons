local mod	= DBM:NewMod(2778, "DBM-Party-Midnight", 5, 1311)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID()--TOO many IDs to guess
mod:SetEncounterID(3209)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2825)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1242869, true, 1242869, 1)
mod:AddPrivateAuraSoundOption(1261781, true, 1261781, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1242869, "scatter", 2)
	self:EnablePrivateAuraSound(1261781, "safenow", 2)
end
