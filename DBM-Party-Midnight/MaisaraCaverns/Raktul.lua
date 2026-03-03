local mod	= DBM:NewMod(2812, "DBM-Party-Midnight", 7, 1315)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248605)
mod:SetEncounterID(3214)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2874)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, Deathgorged Vessel lacks an eventID (or it's one of 0's and needs to be located)
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1251023, true, 1)--Spiritbreaker
mod:AddCustomAlertSoundOption(1253788, true, 2)--Soulrending roar
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1251023, true, 5, 0)--Spiritbreaker
mod:AddCustomTimerOptions(1252675, true, 3, 0)--Crush Souls
mod:AddCustomTimerOptions(1253788, true, 6, 0)--Soulrending roar
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1252675, true, 1252675, 1, 1)--Crush Souls
mod:AddPrivateAuraSoundOption(1253779, true, 1253779, 1, 2)--Spectral Decay

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(1251023, 156, "defensive", 2, 3)
	end
	self:EnableAlertOptions(1253788, 158, "phasechange", 2, 2)--change when things are much clearer

	self:EnableTimelineOptions(1251023, 156)
	self:EnableTimelineOptions(1252675, 157)
	self:EnableTimelineOptions(1253788, 158)

	self:EnablePrivateAuraSound(1252675, "leapyou", 19)
	self:EnablePrivateAuraSound(1253779, "watchfeet", 8)
end
