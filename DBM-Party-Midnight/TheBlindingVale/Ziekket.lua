local mod	= DBM:NewMod(2772, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(247676)
mod:SetEncounterID(3202)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--TODO, lightbeam spell figured out
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1246372, true, 2)--Awaken the Lightbloom
mod:AddCustomAlertSoundOption(1247685, true, 1)--Thornspike
mod:AddCustomAlertSoundOption(1246858, true, 2)--Lightbloom's Essence
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1246372, true, 1, 0)--Awaken the Lightbloom
mod:AddCustomTimerOptions(1247685, true, 5, 0)--Thornspike
mod:AddCustomTimerOptions(1253690, true, 3, 0)--Concentrated Lightbeam
mod:AddCustomTimerOptions(1246858, true, 5, 0)--Lightbloom's Essence
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1253690, true, 1253690, 1, 1)--Concentrated Lightbeam, FIX ME if not pre positioned spell
mod:AddPrivateAuraSoundOption(1246751, true, 1246751, 1, 2)--Concentrated Lightbeam
mod:AddPrivateAuraSoundOption(1246753, true, 1246753, 1, 2)--Lightsap

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1246372, 189, "mobsoon", 2, 3)
	if self:IsTank() then
		self:EnableAlertOptions(1247685, 190, "defensive", 1, 2)
	end
	self:EnableAlertOptions(1246858, 192, "catchballs", 12, 3)

	self:EnableTimelineOptions(1246372, 189)
	self:EnableTimelineOptions(1247685, 190)
	self:EnableTimelineOptions(1253690, 191)
	self:EnableTimelineOptions(1246858, 192)

	self:EnablePrivateAuraSound(1253690, "movetomobs", 14)
	self:EnablePrivateAuraSound(1246751, "watchfeet", 8)
	self:EnablePrivateAuraSound(1246753, "watchfeet", 8)

	DBM:Debug("FIGURE OUT LIGHTBEAM")
end
