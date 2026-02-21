local mod	= DBM:NewMod(2659, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231861)--Iffy, doesn't report as instance boss
mod:SetEncounterID(3071)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(474345, true, 2)--Refueling Protocol
mod:AddCustomAlertSoundOption(474496, true, 1)--Repulsing Slam
mod:AddCustomAlertSoundOption(1214081, true, 2)--Arcane Expulsion
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(474345, true, 5, 0)
mod:AddCustomTimerOptions(474496, true, 5, 0)
mod:AddCustomTimerOptions(474496, true, 3, 0)
mod:AddCustomTimerOptions(474496, true, 2, 0)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1214089, true, 1214089, 1, 2)--Arcane Residue (GTFO)
mod:AddPrivateAuraSoundOption(1214038, true, 1214038, 1, 1)--Ethereal Shackles

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(474345, 281, "catchballs", 12)
	if self:IsTank() then
		self:EnableAlertOptions(474496, 286, "carefly", 2)
	end
	self:EnableAlertOptions(474496, 288, "carefly", 2)

	self:EnableTimelineOptions(474345, 281)
	self:EnableTimelineOptions(474496, 286)
	self:EnableTimelineOptions(474496, 287)
	self:EnableTimelineOptions(474496, 288)

	self:EnablePrivateAuraSound(1214089, "watchfeet", 8)
	self:EnablePrivateAuraSound(1214038, "debuffyou", 17)
end
