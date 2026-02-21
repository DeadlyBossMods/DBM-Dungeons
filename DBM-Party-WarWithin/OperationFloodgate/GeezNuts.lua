local mod	= DBM:NewMod(2651, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(236950)
mod:SetEncounterID(3054)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Note, dam has no announce sound because it can't be antispammed and blizzard likely hooked event to a multi cast script
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(465463, true, 2)
mod:AddCustomAlertSoundOption(466190, true, 1)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(465463, true, 2, 0)
mod:AddCustomTimerOptions(468276, true, 3, 0)
mod:AddCustomTimerOptions(468812, true, 3, 0)
mod:AddCustomTimerOptions(466190, true, 5, 0)
mod:AddCustomTimerOptions(468841, true, 3, 0)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(468811, true, 468812, 1)--Gigazap
mod:AddPrivateAuraSoundOption(468723, true, 468723, 1)
mod:AddPrivateAuraSoundOption(468616, true, 468616, 1)

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(465463, 515, "farfromline", 2)
	self:EnableAlertOptions(466190, 519, "carefly", 2)

	self:EnableTimelineOptions(465463, 515)
	self:EnableTimelineOptions(468276, 517)
	self:EnableTimelineOptions(468812, 518)
	self:EnableTimelineOptions(466190, 519)
	self:EnableTimelineOptions(468841, 520)

	self:EnablePrivateAuraSound(468811, "defensive", 2)--Gigazap
	self:EnablePrivateAuraSound(468723, "watchfeet", 8)--GTFO
	self:EnablePrivateAuraSound(468616, "sparktowater", 18)--Leaping Spark Fixate
end
