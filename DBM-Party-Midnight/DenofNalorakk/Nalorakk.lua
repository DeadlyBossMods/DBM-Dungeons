local mod	= DBM:NewMod(2778, "DBM-Party-Midnight", 5, 1311)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID()--TOO many IDs to guess
mod:SetEncounterID(3209)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2825)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, https://www.wowhead.com/spell=1262846/spirit-thrash seems to be older version of fury of the war god
--Custon Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1255385, true, 2)--Forceful Roar
mod:AddCustomAlertSoundOption(1243011, true, 2)--Fury of the War God
mod:AddCustomAlertSoundOption(1243569, true, 1)--Overwhelming Onslaught
mod:AddCustomAlertSoundOption(1262846, true, 2)--Spirit Thrash (probably not used anymore)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1255385, true, 2, 0)--Forceful Roar
mod:AddCustomTimerOptions(1242869, true, 3, 0)--Echoing Maul
mod:AddCustomTimerOptions(1243011, true, 5, 0)--Fury of the War God
mod:AddCustomTimerOptions(1243569, "Tank|Healer", 5, 0)--Overwhelming Onslaught
mod:AddCustomTimerOptions(1262846, true, 5, 0)--Spirit Thrash (probably not used anymore)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1242869, true, 1242869, 1, 1)--Echoing Maul
mod:AddPrivateAuraSoundOption(1261781, true, 1261781, 1, 1)--Defensive Stance

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1255385, 89, "pushbackincoming", 13, 2)
	self:EnableAlertOptions(1243011, 91, "specialsoon", 2, 3)
	if self:IsTank() then
		self:EnableAlertOptions(1243569, 92, "findshield", 2, 2)
	end
	self:EnableAlertOptions(1262846, 163, "specialsoon", 2, 3)

	self:EnableTimelineOptions(1255385, 89)
	self:EnableTimelineOptions(1242869, 90)
	self:EnableTimelineOptions(1243011, 91)
	self:EnableTimelineOptions(1243569, 92)
	self:EnableTimelineOptions(1262846, 163)

	self:EnablePrivateAuraSound(1242869, "scatter", 2)
	self:EnablePrivateAuraSound(1261781, "safenow", 2)
end
