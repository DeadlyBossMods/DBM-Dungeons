local mod	= DBM:NewMod(2677, "DBM-Party-WarWithin", 10, 1303)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234935)
mod:SetEncounterID(3109)
mod:SetHotfixNoticeRev(20250728000000)
--mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2830)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1224793, true, 1)--Whispers of Fate
mod:AddCustomAlertSoundOption(1225174, true, 2)--Ceremonial Daggers
mod:AddCustomAlertSoundOption(1236703, true, 2)--Eternal Weave
--custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1224793, nil, 5, 0)--Whispers of Fate
mod:AddCustomTimerOptions(1225174, nil, 3, 0)--Ceremonial Daggers
mod:AddCustomTimerOptions(1225218, nil, 3, 0)--Dread of the Unknown
mod:AddCustomTimerOptions(1236703, nil, 6, 0)--Eternal Weave
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1226444, true, 1226444, 1)
mod:AddPrivateAuraSoundOption(1225221, true, 1225221, 1)

function mod:OnLimitedCombatStart()

	self:EnableAlertOptions(1224793, 544, "ghostsoon", 2)
	self:EnableAlertOptions(1225174, 546, "ghostsoon", 2)
	self:EnableAlertOptions(1236703, 548, "phasechange", 2)

	self:EnableTimelineOptions(1224793, 544)
	self:EnableTimelineOptions(1225174, 546)
	self:EnableTimelineOptions(1225218, 547)
	self:EnableTimelineOptions(1236703, 548)

	self:EnablePrivateAuraSound(1226444, "targetyou", 2)
	self:EnablePrivateAuraSound(1225221, "runout", 2)
end
