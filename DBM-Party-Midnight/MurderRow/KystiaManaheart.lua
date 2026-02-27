local mod	= DBM:NewMod(2679, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(252458)
mod:SetEncounterID(3101)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--NOTE: Chaos Barrage has no event ID, but some wierd spell called "escape" (https://www.wowhead.com/spell=1248184/escape) does
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1264095, true, 1)--Mirror Images
mod:AddCustomAlertSoundOption(1253813, true, 2)--Fel Spray
mod:AddCustomAlertSoundOption(474240, true, 2)--Fel Nova
mod:AddCustomAlertSoundOption(1230304, true, 2)--Light Infusion
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1264095, true, 1, 0)--Mirror Images
mod:AddCustomTimerOptions(1253813, true, 3, 0)--Fel Spray
mod:AddCustomTimerOptions(474240, true, 3, 0)--Fel Nova
mod:AddCustomTimerOptions(1230304, true, 5, 0)--Light Infusion
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1253813, true, 1253813, 1, 2)--Fel Spray

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1264095, 120, "mobsoon", 2, 2)--Change when I can access AWS again
	self:EnableAlertOptions(1253813, 122, "frontal", 15, 2)
	self:EnableAlertOptions(474240, 202, "watchstep", 2, 3)--Change audio to carefly?
	self:EnableAlertOptions(1230304, 610, "targetchange", 2, 1, 0)--No timer, text warning only, override sound type 0

	self:EnableTimelineOptions(1264095, 120)
	self:EnableTimelineOptions(1253813, 122)
	self:EnableTimelineOptions(474240, 202)
	self:EnableTimelineOptions(1230304, 610)

	self:EnablePrivateAuraSound(1253813, "watchfeet", 8)
end
