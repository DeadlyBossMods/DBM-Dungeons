local mod	= DBM:NewMod(2656, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231626)--Kalis flagged as main boss, Latch (231629) is secondary
mod:SetEncounterID(3057)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(472888, true, 1)--Bone Hack
mod:AddCustomAlertSoundOption(472736, true, 2)--Debilitating shriek
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(472888, true, 2, 0)
mod:AddCustomTimerOptions(474105, true, 1, 0)--Curse of Darkness
mod:AddCustomTimerOptions(472736, true, 2, 0)
mod:AddCustomTimerOptions(472777, true, 3, 0)--Splattering Spew
mod:AddCustomTimerOptions(472795, true, 3, 0)--Heaving Yank
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1253834, true, 474105, 4, 1)--Curse of Darkness
mod:AddPrivateAuraSoundOption(472793, true, 472795, 1, 1)--Heaving Yank
mod:AddPrivateAuraSoundOption(474129, true, 472745, 1, 1)--Splattering Spew
mod:AddPrivateAuraSoundOption(472777, true, 472777, 4, 2)--Gunk Splatter GTFO

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	if self:IsTank() then
		self:EnableAlertOptions(472888, 25, "defensive", 2)
	end
	self:EnableAlertOptions(472736, 27, "aesoon", 2)

	self:EnableTimelineOptions(472888, 25)
	self:EnableTimelineOptions(474105, 26)
	self:EnableTimelineOptions(472736, 27)
	self:EnableTimelineOptions(472777, 28)
	self:EnableTimelineOptions(472795, 29)

	self:EnablePrivateAuraSound({1253834,1215803}, "justrun", 2)
	self:EnablePrivateAuraSound(472793, "behindboss", 2)
	self:EnablePrivateAuraSound(474129, "targetyou", 2)
	self:EnablePrivateAuraSound(472777, "watchfeet", 8)
end
