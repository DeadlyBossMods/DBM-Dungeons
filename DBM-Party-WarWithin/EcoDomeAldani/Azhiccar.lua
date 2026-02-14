local mod	= DBM:NewMod(2675, "DBM-Party-WarWithin", 10, 1303)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234893)
mod:SetEncounterID(3107)
mod:SetHotfixNoticeRev(20250728000000)
--mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2830)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1217327, "Dps", 1)--Invading Shriek
mod:AddCustomAlertSoundOption(1217232, true, 2)--Devour
--custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1217327, nil, 1, 0)--Invading Shriek
mod:AddCustomTimerOptions(1227748, nil, 3, 0)--Toxic Regurgitation
mod:AddCustomTimerOptions(1217232, nil, 2, 0)--Devour
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1227748, true, 1227748, 1)--Toxic Regurgitation Target
mod:AddPrivateAuraSoundOption(1217439, true, 1217446, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	self:EnableAlertOptions(1217327, 2, "killmob", 1)
	self:EnableAlertOptions(1217232, 461, "pullin", 2)

	self:EnableTimelineOptions(1217327, 2)
	self:EnableTimelineOptions(1227748, 460)
	self:EnableTimelineOptions(1217232, 461)

	self:EnablePrivateAuraSound(1227748, "runout", 2)
	self:EnablePrivateAuraSound(1217439, "watchfeet", 8)
end
