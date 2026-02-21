local mod	= DBM:NewMod(2648, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226398)
mod:SetEncounterID(3020)
mod:SetUsedIcons(8, 7, 6, 5)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(473351, true, 1)
mod:AddCustomAlertSoundOption(1214780, false, 1)--Spammy add interrupt warning because we do not have the permission from blizzard to filter it to only play smartly
mod:AddCustomAlertSoundOption(460156, true, 1)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(473351, "Tank|Healer", 5, 0)
mod:AddCustomTimerOptions(473220, true, 3, 0)
mod:AddCustomTimerOptions(1214780, true, 4, 0)--I highly doubt it actually has a timer event, but just in case lets color it anyways
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(473354, true, 473220, 1)--Sonic Boom
mod:AddPrivateAuraSoundOption(473287, true, 473287, 1)--GTFO

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(473351, 462, "defensive", 2)
	end
	self:EnableAlertOptions(1214780, 464, "kickcast", 2)
	self:EnableAlertOptions(460156, 468, "dpshard", 2)

	self:EnableTimelineOptions(473351, 462)
	self:EnableTimelineOptions(473220, 463)
	self:EnableTimelineOptions(1214780, 464)

	self:EnablePrivateAuraSound(473354, "runout", 2)
	self:EnablePrivateAuraSound(473287, "watchfeet", 8)
end
