local mod	= DBM:NewMod(2570, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207939)
mod:SetEncounterID(2835)
mod:SetHotfixNoticeRev(20250303000000)
mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2649)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(422969, false, 1)
mod:AddCustomAlertSoundOption(423051, "HasInterrupt", 1)
mod:AddCustomAlertSoundOption(423062, true, 2)
mod:AddCustomAlertSoundOption(446403, true, 2)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(422969, true, 6, 0)
mod:AddCustomTimerOptions(423015, true, 3, 0)
mod:AddCustomTimerOptions(423051, true, 4, 0)
mod:AddCustomTimerOptions(423062, true, 3, 0)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1238782, true, 1238782, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(422969, 528, "specialsoon", 2)
	self:EnableAlertOptions(423051, 530, "kickcast", 2)
	self:EnableAlertOptions(423062, 529, "watchstep", 2)
	self:EnableAlertOptions(446403, 532, "helpsoak", 2)

	self:EnableTimelineOptions(422969, 528)
	self:EnableTimelineOptions(423015, 529)
	self:EnableTimelineOptions(423051, 530)
	self:EnableTimelineOptions(423062, 531)
	self:EnableTimelineOptions(446403, 532)

	self:EnablePrivateAuraSound(1238782, "watchfeet", 8)
end
