local mod	= DBM:NewMod(2649, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226403, 226402)
mod:SetEncounterID(3019)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(459799, true, 1)
mod:AddCustomAlertSoundOption(1217653, true, 2)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(459799, "Tank|Healer", 5, 0)
mod:AddCustomTimerOptions(459779, true, 3, 0)
mod:AddCustomTimerOptions(460867, true, 5, 0)
mod:AddCustomTimerOptions(1217653, true, 3, 0)
mod:AddCustomTimerOptions(473690, true, 3, 0)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(473713, true, 473690, 1)--Debuff
mod:AddPrivateAuraSoundOption(470022, true, 459779, 1)--Charge

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	if self:IsTank() then
		self:EnableAlertOptions(459799, 469, "defensive", 2)
	end
	self:EnableAlertOptions(1217653, 472, "frontal", 2)

	self:EnableTimelineOptions(459799, 469)
	self:EnableTimelineOptions(459779, 470)
	self:EnableTimelineOptions(460867, 471)
	self:EnableTimelineOptions(1217653, 472)
	self:EnableTimelineOptions(473690, 473)

	self:EnablePrivateAuraSound(473713, "targetyou", 2)
	self:EnablePrivateAuraSound(470022, "chargemove", 2)
end
