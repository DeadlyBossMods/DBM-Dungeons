local mod	= DBM:NewMod(2792, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(239008)
mod:SetEncounterID(3286)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1283506, true, 1283506, 4)
mod:AddPrivateAuraSoundOption(1222484, true, 1222484, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1283506, "justrun", 2)
	self:EnablePrivateAuraSound(1222484, "watchfeet", 8)
end
