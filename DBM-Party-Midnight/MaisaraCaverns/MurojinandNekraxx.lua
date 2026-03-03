local mod	= DBM:NewMod(2810, "DBM-Party-Midnight", 7, 1315)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(247570)--Muro, Nekraxx is 247572
mod:SetEncounterID(3212)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2874)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1266480, true, 1)--Flanking Spear
mod:AddCustomAlertSoundOption(1243900, true, 2)--Fetid Quillstorm
mod:AddCustomAlertSoundOption(1243741, true, 2)--Freezing Trap Cast
mod:AddCustomAlertSoundOption(1246666, "RemoveDisease", 1)--Infected Pinions
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1266480, true, 5, 0)--Flanking Spear
mod:AddCustomTimerOptions(1243900, true, 3, 0)--Fetid Quillstorm
mod:AddCustomTimerOptions(1243741, true, 1, 0)--Freezing Trap Cast
mod:AddCustomTimerOptions(1260643, true, 3, 0)--Barrage
mod:AddCustomTimerOptions(1246666, "RemoveDisease", 5, 0)--Infected Pinions
mod:AddCustomTimerOptions(1249478, true, 3, 0)--Carrion Swoop
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1243741, true, 1243741, 1, 1)--Freezing Trap Stun
mod:AddPrivateAuraSoundOption(1260643, true, 1260643, 1, 1)--Barrage
mod:AddPrivateAuraSoundOption(1249478, true, 1249478, 1, 1)--Carrion Swoop

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(1266480, 150, "defensive", 2, 3)
	end
	self:EnableAlertOptions(1243900, 151, "watchstep", 2, 2)
	self:EnableAlertOptions(1243741, 152, "trapsincoming", 19, 2)--has a severity, so type 0 might work
	self:EnableAlertOptions(1260643, 154, "helpdispel", 2, 3)

	self:EnableTimelineOptions(1266480, 150)
	self:EnableTimelineOptions(1243900, 151)
	self:EnableTimelineOptions(1243741, 152)
	self:EnableTimelineOptions(1260643, 153)
	self:EnableTimelineOptions(1246666, 154)
	self:EnableTimelineOptions(1249478, 155)

	self:EnablePrivateAuraSound(1243741, "stunyou", 19)
	self:EnablePrivateAuraSound(1260643, "frontalyou", 19)
	self:EnablePrivateAuraSound(1249478, "behindice", 19)
end
