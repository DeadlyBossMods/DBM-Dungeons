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

local is121 = DBM:GetTOC() == 120100

--mod:RegisterEventsInCombat(

--)
--NOTE: https://www.wowhead.com/spell=1222098/nether-dash has an eventID of 558 but already has private aura and wouldn't have a timer
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(is121 and 1297017 or 1222085, true, 1)--Cosmic Spike (12.0) / Void Blast (12.1)
mod:AddCustomAlertSoundOption(1262901, true, 2)--Gather Shadows (removed in 12.1?)
mod:AddCustomAlertSoundOption(is121 and 1300259 or 1222274, true, 2)--Dark Rift (12.0) / Black Hole (12.1)
mod:AddCustomAlertSoundOption(1296963, true, 2)--Umbral Rupture (added in 12.1)
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(is121 and 1297017 or 1222085, true, 5, 0)--Cosmic Spike (12.0) / Void Blast (12.1)
mod:AddCustomTimerOptions(1262901, true, 1, 0)--Gather Shadows (removed in 12.1?)
mod:AddCustomTimerOptions(is121 and 1300259 or 1222274, true, 2, 0)--Dark Rift (12.0) / Black Hole (12.1)
mod:AddCustomTimerOptions(1225011, true, 3, 0)--Ethereal Shards
if is121 then
	mod:AddCustomTimerOptions(1296963, true, 3, 0)--Umbral Rupture (added in 12.1)
end
--Custom Aura Sounds
mod:AddAuraSoundOption(1225011, true, 1225011, 1, 1, "debuffyou", 17)--Ethereal Shards
mod:AddAuraSoundOption(1222098, true, 1222098, 1, 1, "chargemove", 2)--Nether Dash

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(is121 and 1297017 or 1222085, 39, "defensive", 2, 2)
	end
	self:EnableAlertOptions(1262901, 40, "ghostsoon", 2, 2)
	self:EnableAlertOptions(is121 and 1300259 or 1222274, 41, "pullin", 12, 2)
	if is121 then
		self:EnableAlertOptions(1296963, 782, "watchstep", 2, 2)
	end

	self:EnableTimelineOptions(is121 and 1297017 or 1222085, 39)
	self:EnableTimelineOptions(1262901, 40)
	self:EnableTimelineOptions(is121 and 1300259 or 1222274, 41)
	self:EnableTimelineOptions(1225011, 42)
	if is121 then
		self:EnableTimelineOptions(1296963, 782)
	end
end
