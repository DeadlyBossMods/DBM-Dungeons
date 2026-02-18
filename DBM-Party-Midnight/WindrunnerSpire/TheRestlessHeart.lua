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
--NOTE. maybe also add a Bolt Gale general cast sound if the cone is large
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(468429, true, 1)--Bullseye Windblast
mod:AddCustomAlertSoundOption(472556, true, 2)--Arrow Rain
mod:AddCustomAlertSoundOption(472662, true, 3)--Tempest Slash
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(468429, true, 3, 0)
mod:AddCustomTimerOptions(474528, true, 1, 0)--Bolt Gale
mod:AddCustomTimerOptions(472556, true, 3, 0)--Arrow Rain
mod:AddCustomTimerOptions(472662, true, 5, 0)--Tempest Slash
mod:AddCustomTimerOptions(1253979, true, 3, 0)--Gust Shot
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1282911, true, 474528, 1, 1)--Bolt Gale
mod:AddPrivateAuraSoundOption(1253979, true, 1253979, 1, 1)--Gust Shot
mod:AddPrivateAuraSoundOption(472662, true, 472662, 1, 1)--Tempest Slash
mod:AddPrivateAuraSoundOption(1216042, true, 1216042, 1, 1)--Squall Leap

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	self:EnableAlertOptions(468429, 21, "watchstep", 2)
	self:EnableAlertOptions(472556, 23, "specialsoon", 2)
	if self:IsTank() then
		self:EnableAlertOptions(472662, 24, "defensive", 2)
	end

	self:EnableTimelineOptions(468429, 21)
	self:EnableTimelineOptions(474528, 22)
	self:EnableTimelineOptions(472556, 23)
	self:EnableTimelineOptions(472662, 24)
	self:EnableTimelineOptions(1253979, 538)

	self:EnablePrivateAuraSound(1282911, "lineyou", 17)
	self:EnablePrivateAuraSound(1253979, "movetopool", 15)
	self:EnablePrivateAuraSound(472662, "movetoarrow", 19)
	self:EnablePrivateAuraSound(1216042, "movetoarrow", 19)
end
