local mod	= DBM:NewMod(2661, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231863)
mod:SetEncounterID(3072)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--TODO, does mod need both runic mark private aura IDs? or does it result in a double announce?
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1224903, true, 2)--Suppression Zone
mod:AddCustomAlertSoundOption(1248689, "MagicDispeller", 1)--Hastening Ward
mod:AddCustomAlertSoundOption(1225193, true, 2)--Wave of Silence
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1224903, true, 3, 0)--Suppression Zone
mod:AddCustomTimerOptions(1248689, true, 5, 0)--Hastening Ward
mod:AddCustomTimerOptions(1225787, true, 3, 0)--Runic Mark
mod:AddCustomTimerOptions(1225193, true, 2, 0)--Wave of Silence
-- Midnights private aura replacements
mod:AddPrivateAuraSoundOption(1225787, true, 1225787, 1, 1)--Runic Mark

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1224903, 93, "watchstep", 2)
	self:EnableAlertOptions(1248689, 94, "dispelboss", 2)
	self:EnableAlertOptions(1225193, 96, "movetopool", 15)--Maybe "findshield" instead

	self:EnableTimelineOptions(1224903, 93)
	self:EnableTimelineOptions(1248689, 94)
	self:EnableTimelineOptions(1225787, 95, 513)
	self:EnableTimelineOptions(1225193, 96)

	self:EnablePrivateAuraSound({1225787,1225792}, "debuffyou", 17)
end
