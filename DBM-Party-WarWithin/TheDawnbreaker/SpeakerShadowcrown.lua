local mod	= DBM:NewMod(2580, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(211087)
mod:SetEncounterID(2837)
mod:SetHotfixNoticeRev(20241005000000)
mod:SetMinSyncRevision(20241005000000)
mod:SetZone(2662)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(445996, true, 2)--Collapsing Darkness
mod:AddCustomAlertSoundOption(453140, true, 2)--Collapsing Night
mod:AddCustomAlertSoundOption(425264, true, 2)--Obsidian Blast
mod:AddCustomAlertSoundOption(453212, true, 2)--Obsidian Beam
mod:AddCustomAlertSoundOption(451026, true, 3)--Darkness Comes
--custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(445996, nil, 3, 0)--Collapsing Darkness
mod:AddCustomTimerOptions(453140, nil, 3, 0)--Collapsing Night
mod:AddCustomTimerOptions(426734, nil, 3, 0)--Burning Shadows
mod:AddCustomTimerOptions(425264, nil, 3, 0)--Obsidian Blast
mod:AddCustomTimerOptions(453212, nil, 3, 0)--Obsidian Beam
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(426735, true, 426734, 1)--Burning Shadows

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(445996, 617, "watchstep", 2)
	self:EnableAlertOptions(453140, 618, "watchstep", 2)
	self:EnableAlertOptions(425264, 620, "farfromline", 2)
	self:EnableAlertOptions(453212, 621, "farfromline", 2)
	self:EnableAlertOptions(451026, 631, "justrun", 2)

	self:EnableTimelineOptions(445996, 617)
	self:EnableTimelineOptions(453140, 618)
	self:EnableTimelineOptions(426734, 619)
	self:EnableTimelineOptions(425264, 620)
	self:EnableTimelineOptions(453212, 621)

	self:EnablePrivateAuraSound(426735, "targetyou", 2)
end
