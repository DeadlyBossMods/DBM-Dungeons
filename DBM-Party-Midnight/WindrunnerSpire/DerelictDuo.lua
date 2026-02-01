local mod	= DBM:NewMod(2656, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231626)--Kalis flagged as main boss, Latch (231629) is secondary
mod:SetEncounterID(3057)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1253834, true, 1253834, 4)
mod:AddPrivateAuraSoundOption(472793, true, 472793, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1253834, "justrun", 2)
	self:EnablePrivateAuraSound(1215803, "justrun", 2, 1253834)
	self:EnablePrivateAuraSound(472793, "behindboss", 2)
end
