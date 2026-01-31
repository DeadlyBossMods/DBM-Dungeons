local mod	= DBM:NewMod(2659, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231861)--Iffy, doesn't report as instance boss
mod:SetEncounterID(3071)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1214089, true, 1214089, 1)
mod:AddPrivateAuraSoundOption(1214038, true, 1214038, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1214089, "watchfeet", 8)
	self:EnablePrivateAuraSound(1214038, "debuffyou", 17)
end
