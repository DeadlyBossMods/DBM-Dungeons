local mod	= DBM:NewMod(2585, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(215407)
mod:SetEncounterID(2901)
mod:SetHotfixNoticeRev(20240818000000)
mod:SetMinSyncRevision(20240818000000)
mod:SetZone(2660)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--NOTE: Blizzard forgot to assign Venom Volley an event ID (432227)
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(432117, true, 3)--Cosmic Singularity
mod:AddCustomAlertSoundOption(432130, true, 2)--Erupting Webs
--custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(432117, nil, 5, 0)--Cosmic Singularity
mod:AddCustomTimerOptions(432130, nil, 3, 0)--Erupting Webs
mod:AddCustomTimerOptions(461487, nil, 5, 0)--Cultivated Poisons (might also be used for volley?)
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(432119, true, 432119, 1)--Screwing up Cosmic Singularity (Faded)

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(432117, 552, "movetopool", 15)
	self:EnableAlertOptions(432130, 553, "watchstep", 2)

	self:EnableTimelineOptions(432117, 552)
	self:EnableTimelineOptions(432130, 553)
	self:EnableTimelineOptions(461487, 554)

	self:EnablePrivateAuraSound(432119, "defensive", 2)
end
