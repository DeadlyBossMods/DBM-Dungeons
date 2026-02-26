local mod	= DBM:NewMod(2584, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(215405)
mod:SetEncounterID(2906)
mod:SetHotfixNoticeRev(20240817000000)
mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2660)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(433425, true, 2)--Impale
mod:AddCustomAlertSoundOption(439506, true, 2)--Burrow Charge
mod:AddCustomAlertSoundOption(1283246, true, 1)--Summon Web Mage
mod:AddCustomAlertSoundOption(433766, true, 2)--Eye of the Storm
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(433425, nil, 3, 0)
mod:AddCustomTimerOptions(439506, nil, 3, 0)
mod:AddCustomTimerOptions(433740, nil, 3, 0)--Infestation
mod:AddCustomTimerOptions(1283246, nil, 1, 0)--Summon Web Mage
mod:AddCustomTimerOptions(433766, nil, 6, 0)--Eye of the Storm
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(433740, true, 433740, 1)
mod:AddPrivateAuraSoundOption(450969, true, 450969, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(433425, {542,551}, "frontal", 15)
	self:EnableAlertOptions(439506, 543, "watchstep", 2)
	self:EnableAlertOptions(1283246, 549, "mobsoon", 2)
	self:EnableAlertOptions(433766, 550, "movetoboss", 14)

	self:EnableTimelineOptions(433425, {542, 551})
	self:EnableTimelineOptions(439506, 543)
	self:EnableTimelineOptions(433740, 545)
	self:EnableTimelineOptions(1283246, 549)
	self:EnableTimelineOptions(433766, 550)

	self:EnablePrivateAuraSound(433740, "runout", 2)
	self:EnablePrivateAuraSound(450969, "watchfeet", 8)
end
