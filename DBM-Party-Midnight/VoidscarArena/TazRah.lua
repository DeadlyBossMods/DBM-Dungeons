local mod	= DBM:NewMod(2791, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(238887)
mod:SetEncounterID(3285)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--NOTE: https://www.wowhead.com/spell=1222098/nether-dash has an eventID but already has private aura and wouldn't have a timer
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1222085, true, 1)--Cosmic Spike
mod:AddCustomAlertSoundOption(1262901, true, 2)--Gather Shadows
mod:AddCustomAlertSoundOption(1222274, true, 2)--Dark Rift
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1222085, true, 5, 0)--Cosmic Spike
mod:AddCustomTimerOptions(1262901, true, 1, 0)--Gather Shadows
mod:AddCustomTimerOptions(1222274, true, 2, 0)--Dark Rift
mod:AddCustomTimerOptions(1225011, true, 3, 0)--Ethereal Shards
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1225011, true, 1225011, 1, 1)--Ethereal Shards
mod:AddPrivateAuraSoundOption(1222098, true, 1222098, 1, 1)--Nether Dash

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(1222085, 39, "defensive", 2, 2)
	end
	self:EnableAlertOptions(1262901, 40, "ghostsoon", 2, 2)
	self:EnableAlertOptions(1222274, 41, "pullin", 12, 2)

	self:EnableTimelineOptions(1222085, 39)
	self:EnableTimelineOptions(1262901, 40)
	self:EnableTimelineOptions(1222274, 41)
	self:EnableTimelineOptions(1225011, 42)

	self:EnablePrivateAuraSound(1225011, "debuffyou", 17)--change to "lineyou" if it uses a line
	self:EnablePrivateAuraSound(1222098, "chargemove", 2)
end
