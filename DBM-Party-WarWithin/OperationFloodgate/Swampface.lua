local mod	= DBM:NewMod(2650, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226396)
mod:SetEncounterID(3053)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(469478, true, 1)
mod:AddCustomAlertSoundOption(473114, true, 2)
mod:AddCustomAlertSoundOption(473070, true, 2)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(470039, true, 3, 0)
mod:AddCustomTimerOptions(469478, true, 5, 0)
mod:AddCustomTimerOptions(473114, true, 3, 0)
mod:AddCustomTimerOptions(473070, true, 3, 0)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(470038, true, 470038, 1)

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(469478, 508, "defensive", 2)
	self:EnableAlertOptions(473114, 509, "frontal", 15)
	self:EnableAlertOptions(473070, 510, "watchwave", 2)

	self:EnableTimelineOptions(470039, 507)
	self:EnableTimelineOptions(469478, 508)
	self:EnableTimelineOptions(473114, 509)
	self:EnableTimelineOptions(473070, 510)

	self:EnablePrivateAuraSound(470038, "linegather", 2)
end
