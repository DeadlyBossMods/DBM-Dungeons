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

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(473898, true, 1)--Legion Strike
mod:AddCustomAlertSoundOption(474197, true, 2)--Demonic Rage
mod:AddCustomAlertSoundOption(1214663, true, 1)--Axe Toss
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(473898, true, 5, 0)--Legion Strike
mod:AddCustomTimerOptions(474197, true, 2, 0)--Demonic Rage
mod:AddCustomTimerOptions(1214663, true, 3, 0)--Axe Toss
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(474234, true, 474234, 1)--Burning Steps
--mod:AddPrivateAuraSoundOption(1218203, true, 1218203, 1)--Fingers of Gul'dan

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(473898, 30, "defensive", 2, 2)
	end
	self:EnableAlertOptions(474197, 32, "aesoon", 2, 2)
	self:EnableAlertOptions(1214663, 559, "watchstep", 1, 2)

	self:EnableTimelineOptions(473898, 30)
	self:EnableTimelineOptions(474197, 32)
	self:EnableTimelineOptions(1214663, 559)

	self:EnablePrivateAuraSound(474234, "watchfeet", 8)
--	self:EnablePrivateAuraSound(1218203, "runout", 2)
end
