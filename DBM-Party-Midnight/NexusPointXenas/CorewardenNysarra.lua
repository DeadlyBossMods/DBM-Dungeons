local mod	= DBM:NewMod(2814, "DBM-Party-Midnight", 8, 1316)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(254227)
mod:SetEncounterID(3332)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2915)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1264439, true, 2)--Lightscare Flare
mod:AddCustomAlertSoundOption(1247937, true, 1)--Umbral Lash
mod:AddCustomAlertSoundOption(1252703, true, 1)--Null Vanguard
mod:AddCustomAlertSoundOption(1271684, true, 2)--Devour the Unworthy
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1249020, true, 3, 0)--Eclipsing Step
mod:AddCustomTimerOptions(1264439, true, 5, 0)--Lightscare Flare
mod:AddCustomTimerOptions(1247937, true, 5, 0)--Umbral Lash
mod:AddCustomTimerOptions(1252703, true, 1, 0)--Null Vanguard
mod:AddCustomTimerOptions(1271684, true, 2, 0)--Devour the Unworthy
--Private Auras
mod:AddPrivateAuraSoundOption(1249020, true, 1249020, 1, 1)--Eclipsing Step
mod:AddPrivateAuraSoundOption(1282678, true, 1282678, 1, 1)--Flailstorm

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1264439, 34, "watchstep", 2)
	if self:IsTank() then
		self:EnableAlertOptions(1247937, 35, "carefly", 2)
	end
	self:EnableAlertOptions(1252703, 36, "mobsoon", 2)
	self:EnableAlertOptions(1271684, 37, "aesoon", 2)

	self:EnableTimelineOptions(1249020, 33)
	self:EnableTimelineOptions(1264439, 34)
	self:EnableTimelineOptions(1247937, 35)
	self:EnableTimelineOptions(1252703, 36)
	self:EnableTimelineOptions(1271684, 37)

	self:EnablePrivateAuraSound(1249020, "scatter", 2)
	self:EnablePrivateAuraSound(1282678, "justrun", 2)
end
