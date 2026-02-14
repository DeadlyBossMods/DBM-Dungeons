local mod	= DBM:NewMod(2593, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213937)
mod:SetEncounterID(2839)
mod:SetHotfixNoticeRev(20240706000000)
mod:SetMinSyncRevision(20240706000000)
mod:SetZone(2662)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(448888, true, 2)--Erosive Spray
mod:AddCustomAlertSoundOption(448213, true, 2)--Expel Webs
mod:AddCustomAlertSoundOption(434655, false, 1)--Bomb
--custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(448888, nil, 2, 0)--Erosive Spray
mod:AddCustomTimerOptions(434407, nil, 3, 0)--Rolling Acid
mod:AddCustomTimerOptions(448213, nil, 3, 0)--Expel Webs
mod:AddCustomTimerOptions(434089, nil, 3, 0)--Spinneret's Strands
mod:AddCustomTimerOptions(434655, nil, 5, 0)--Bomb
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(434406, true, 434407, 1)--Rolling Acid target
mod:AddPrivateAuraSoundOption(439783, true, 434089, 1)--Spineret's Strands target
mod:AddPrivateAuraSoundOption(438957, true, 438957, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	self:EnableAlertOptions(448888, 626, "aesoon", 2)
	self:EnableAlertOptions(448213, 628, "watchstep", 2)
	self:EnableAlertOptions(434655, 630, "bombsoon", 2)

	self:EnableTimelineOptions(448888, 626)
	self:EnableTimelineOptions(434407, 627)
	self:EnableTimelineOptions(448213, 628)
	self:EnableTimelineOptions(434089, 629)
	self:EnableTimelineOptions(434655, 630)

	self:EnablePrivateAuraSound({434406,439790}, "targetyou", 2)--Rolling Acid (dungeon and raid versions since I don't know which is which)
	self:EnablePrivateAuraSound({439783,434090}, "runout", 12)--Spinneret's Strands (dungeon and raid versions since I don't know which is which)
	self:EnablePrivateAuraSound(438957, "watchfeet", 8)--Acidic Pools ground effect
end
