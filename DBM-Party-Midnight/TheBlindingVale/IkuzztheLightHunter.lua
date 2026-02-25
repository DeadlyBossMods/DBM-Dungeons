local mod	= DBM:NewMod(2770, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(244887)
mod:SetEncounterID(3200)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1236746, true, 2)--Verdant Stomp
mod:AddCustomAlertSoundOption(1236709, true, 2)--Thorncaller Roar
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1236746, true, 2, 0)--Verdant Stomp
mod:AddCustomTimerOptions(1236709, true, 2, 0)--Thorncaller Roar
mod:AddCustomTimerOptions(1237091, true, 1, 0)--Bloodthirsty Gaze
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1237091, true, 1237091, 4, 1)--Bloodthirsty Gaze
mod:AddPrivateAuraSoundOption(1272290, true, 1272290, 1, 1)--Crunched

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1236746, 178, "carefly", 2, 2)
	self:EnableAlertOptions(1236709, 179, "watchstep", 2, 2)

	self:EnableTimelineOptions(1236746, 178)
	self:EnableTimelineOptions(1236709, 179)
	self:EnableTimelineOptions(1237091, 180)

	self:EnablePrivateAuraSound(1237091, "fixateyou", 19)
	self:EnablePrivateAuraSound(1272290, "stunyou", 19)
end
