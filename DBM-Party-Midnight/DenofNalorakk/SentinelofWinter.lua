local mod	= DBM:NewMod(2777, "DBM-Party-Midnight", 5, 1311)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(244100)
mod:SetEncounterID(3208)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2825)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

-- Custon Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1235548, "Healer", 2)--Glacial Torment
mod:AddCustomAlertSoundOption(1235623, true, 2)--Raging Squall
mod:AddCustomAlertSoundOption(1235783, true, 1)--Shattering Frostspike
mod:AddCustomAlertSoundOption(1235656, true, 2)--Eternal Winter
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1235548, true, 5, 0)--Glacial Torment
mod:AddCustomTimerOptions(1235623, true, 3, 0)--Raging Squall
mod:AddCustomTimerOptions(1235783, true, 1, 0)--Shattering Frostspike
mod:AddCustomTimerOptions(1235656, true, 2, 0)--Eternal Winter
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1235641, true, 1235641, 1, 2)--Raging Squall

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1235548, 67, "helpdispel", 2, 3)
	self:EnableAlertOptions(1235623, 68, "watchstep", 2, 2)
	self:EnableAlertOptions(1235783, 69, "mobsoon", 2, 1)
	self:EnableAlertOptions(1235656, 70, "pushbackincoming", 13, 3)

	self:EnableTimelineOptions(1235548, 67)
	self:EnableTimelineOptions(1235623, 68)
	self:EnableTimelineOptions(1235783, 69)
	self:EnableTimelineOptions(1235656, 70)

	self:EnablePrivateAuraSound(1235641, "watchfeet", 8)
end
