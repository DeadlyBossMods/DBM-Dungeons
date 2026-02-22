local mod	= DBM:NewMod(2657, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231631)
mod:SetEncounterID(3058)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, intimidating shout has two spellid and two encounter event IDs, determine if they should be combined or separated
--Same with reckless Leap and rampage
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(467620, true, 1)--Rampage
mod:AddCustomAlertSoundOption(1253026, true, 2)--Intimidating Shout (also 1253272)
mod:AddCustomAlertSoundOption(472043, true, 2)--Rallying Bellow
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(467620, true, 5, 0)--Rampage
mod:AddCustomTimerOptions(1253026, true, 2, 0)--Intimidating Shout
mod:AddCustomTimerOptions(1283247, true, 3, 0)--Reckless Leap
mod:AddCustomTimerOptions(472043, true, 1, 0)--Rallying Bellow
mod:AddCustomTimerOptions(470966, true, 2, 0)--Bladestorm
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(470966, true, 470966, 4, 1)--Bladestorm target
mod:AddPrivateAuraSoundOption(468924, true, 470966, 1, 2)--Bladestorm GTFO
mod:AddPrivateAuraSoundOption(1283247, true, 1283247, 1, 1)--Reckless Leap target

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(467620, {210,556}, "defensive", 2)
	end
	self:EnableAlertOptions(1253026, {211,213}, "gathershare", 2)
	self:EnableAlertOptions(472043, 215, "mobsoon", 2)

	self:EnableTimelineOptions(467620, 210, 556)
	self:EnableTimelineOptions(1253026, 211, 213)
	self:EnableTimelineOptions(1283247, 212, 214)
	self:EnableTimelineOptions(472043, 215)
	self:EnableTimelineOptions(470966, 216)

	self:EnablePrivateAuraSound(470966, "justrun", 2)
	self:EnablePrivateAuraSound(468924, "watchfeet", 8)
	self:EnablePrivateAuraSound(1283247, "runout", 2)
end
