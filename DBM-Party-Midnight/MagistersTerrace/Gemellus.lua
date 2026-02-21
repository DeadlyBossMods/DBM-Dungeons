local mod	= DBM:NewMod(2660, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(239636)
mod:SetEncounterID(3073)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1223847, false, 2)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1253709, true, 3, 0)
mod:AddCustomTimerOptions(1224299, true, 3, 0)
mod:AddCustomTimerOptions(1224104, true, 3, 0)
mod:AddCustomTimerOptions(1223958, true, 3, 0)
-- Midnights private aura replacements
mod:AddPrivateAuraSoundOption(1223958, true, 1223958, 1, 1)--Cosmic Sting
mod:AddPrivateAuraSoundOption(1224104, true, 1224104, 1, 2)--Void Secretions
mod:AddPrivateAuraSoundOption(1253709, true, 1253709, 1, 1)--Neural Link
mod:AddPrivateAuraSoundOption(1224299, true, 1224299, 1, 1)--Astral Grasp

function mod:OnLimitedCombatStart()

	self:EnableAlertOptions(1223847, 635, "specialsoon", 2)

	self:EnableTimelineOptions(1253709, 97)
	self:EnableTimelineOptions(1224299, 98)
	self:EnableTimelineOptions(1224104, 99)
	self:EnableTimelineOptions(1223958, 100)

	self:EnablePrivateAuraSound(1223958, "runout", 2)
	self:EnablePrivateAuraSound(1224104, "watchfeet", 8)
	self:EnablePrivateAuraSound(1253709, "linegather", 2)
	self:EnablePrivateAuraSound(1224299, "pullin", 12)
end
