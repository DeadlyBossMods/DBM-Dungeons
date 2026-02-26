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
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1222371, true, 1)--Provoke Creeper
mod:AddCustomAlertSoundOption(1222642, true, 1)--Hulking Claw
mod:AddCustomAlertSoundOption(1263977, true, 2)--Noxious Breath
mod:AddCustomAlertSoundOption(1226120, true, 2)--Poison Splash
mod:AddCustomAlertSoundOption(1262497, true, 2)--Monstrous Stomp
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1222371, true, 1, 0)--Provoke Creeper
mod:AddCustomTimerOptions(1222642, true, 5, 0)--Hulking Claw
mod:AddCustomTimerOptions(1263977, true, 3, 0)--Noxious Breath
mod:AddCustomTimerOptions(1226120, true, 3, 0)--Poison Splash
mod:AddCustomTimerOptions(1262497, true, 2, 0)--Monstrous Stomp
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1283506, true, 1283506, 4, 1)--Fixate
mod:AddPrivateAuraSoundOption(1222484, true, 1222484, 1, 2)--Poison Pool

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1222371, 46, "bigmob", 2, 2)
	self:EnableAlertOptions(1222642, 47, "defensive", 2, 2)
	self:EnableAlertOptions(1263977, 54, "frontal", 15, 3)
	self:EnableAlertOptions(1226120, 55, "watchstep", 2, 2)
	self:EnableAlertOptions(1262497, 297, "carefly", 2, 3)

	self:EnableTimelineOptions(1222371, 46)
	self:EnableTimelineOptions(1222642, 47)
	self:EnableTimelineOptions(1263977, 54)
	self:EnableTimelineOptions(1226120, 55)
	self:EnableTimelineOptions(1262497, 297)

	self:EnablePrivateAuraSound(1283506, "fixateyou", 19)
	self:EnablePrivateAuraSound(1222484, "watchfeet", 8)
end
