local mod	= DBM:NewMod(2581, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(211089)
mod:SetEncounterID(2838)
mod:SetHotfixNoticeRev(20240706000000)
mod:SetZone(2662)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(426787, true, 2)--Shadowy Decay
mod:AddCustomAlertSoundOption(427001, true, 3)--Terrifying Slam
--custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(426787, nil, 2, 0)--Shadowy Decay
mod:AddCustomTimerOptions(426860, nil, 3, 0)--Dark Orb
mod:AddCustomTimerOptions(427001, nil, 5, 0)--Terrifying Slam
mod:AddCustomTimerOptions(452127, nil, 1, 0)--Animate Shadows
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(426865, true, 426860, 1)--Dark Orb target

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	self:EnableAlertOptions(426787, 622, "aesoon", 2)
	if self:IsTank() then
		self:EnableAlertOptions(427001, 624, "carefly", 2)
	else
		self:EnableAlertOptions(427001, 624, "justrun", 2)
	end

	self:EnableTimelineOptions(426787, 622)
	self:EnableTimelineOptions(426860, 623)
	self:EnableTimelineOptions(427001, 624)
	self:EnableTimelineOptions(452127, 625)

	self:EnablePrivateAuraSound({426865, 450855}, "targetyou", 2)--Dark Orb
end
