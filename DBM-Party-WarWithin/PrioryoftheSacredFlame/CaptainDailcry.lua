local mod	= DBM:NewMod(2571, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207946)
mod:SetEncounterID(2847)
mod:SetHotfixNoticeRev(20250303000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2649)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--NOTE: Hurl Spear(447270)/Earthshattering Spear(1238780) has no event ID
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(424414, true, 1)
mod:AddCustomAlertSoundOption(424419, "HasInterrupt", 1)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(424414, true, 5, 0)
mod:AddCustomTimerOptions(424419, true, 4, 0)
mod:AddCustomTimerOptions(447439, true, 3, 0)
--Private Auras
mod:AddPrivateAuraSoundOption(447439, true, 447439, 1)

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()

	if self:IsTank() then
		self:EnableAlertOptions(424414, 525, "defensive", 2)
	end
	self:EnableAlertOptions(424419, 526, "kickcast", 2)

	self:EnableTimelineOptions(424414, 525)
	self:EnableTimelineOptions(424419, 526)
	self:EnableTimelineOptions(447439, 527)

	self:EnablePrivateAuraSound(447439, "defensive", 2)
end
