local mod	= DBM:NewMod(2676, "DBM-Party-WarWithin", 10, 1303)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234933, 237514) -- Taah'bat and Awazj
mod:SetEncounterID(3108)
mod:SetHotfixNoticeRev(20250728000000)
--mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2830)
--mod.respawnTime = 29
--mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1219482, true, 1)--Rift Claws
mod:AddCustomAlertSoundOption(1219700, true, 2)--Arcane Blitz
--custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1219482, nil, 5, 0)--Rift Claws
mod:AddCustomTimerOptions(1236126, nil, 3, 0)--Binding Javelin
mod:AddCustomTimerOptions(1220427, nil, 3, 0)--Warp Strike
mod:AddCustomTimerOptions(1219700, nil, 6, 0)--Arcane Blitz
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1220427, true, 1220427, 1)--Warp Strike
mod:AddPrivateAuraSoundOption(1236126, true, 1236126, 1)--Binding Javelin

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(1219482, 484, "defensive", 2)
	end
	self:EnableAlertOptions(1219700, 487, "specialsoon", 2)

	self:EnableTimelineOptions(1219482, 484)
	self:EnableTimelineOptions(1236126, 485)
	self:EnableTimelineOptions(1220427, {486, 491})
	self:EnableTimelineOptions(1219700, 487)

	self:EnablePrivateAuraSound({1220427,1227142}, "lineyou", 17)
	self:EnablePrivateAuraSound(1236126, "targetyou", 2)
end
