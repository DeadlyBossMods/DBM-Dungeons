local mod	= DBM:NewMod(2793, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248015)
mod:SetEncounterID(3287)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--TODO, void cascade has two private auras, but neitehr appear to be pre target aura and rather ones you just get if in beam
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1227264, true, 2)--Cosmic Blast
mod:AddCustomAlertSoundOption(1222758, true, 2)--Void Cascade
mod:AddCustomAlertSoundOption(1263982, true, 2)--Gravity Orbs
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1282770, true, 3, 0)--Unstable Singularity
mod:AddCustomTimerOptions(1227264, true, 2, 0)--Cosmic Blast
mod:AddCustomTimerOptions(1263982, true, 3, 0)--Gravity Orbs
mod:AddCustomTimerOptions(1222758, true, 3, 0)--Void Cascade
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1263983, true, 1263982, 4, 1)--Condensed Mass
mod:AddPrivateAuraSoundOption(1282770, true, 1282770, 1, 1)--Unstable Singularity Pre debuff
mod:AddPrivateAuraSoundOption(1248130, true, 1282770, 1, 2)--GTFO

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1227264, 57, "carefly", 2, 2)
	self:EnableAlertOptions(1263982, 58, "specialsoon", 2, 2, 0)
	self:EnableAlertOptions(1222758, 171, "watchstep", 2, 2)--Review

	self:EnableTimelineOptions(1282770, 56)
	self:EnableTimelineOptions(1227264, 57)
	self:EnableTimelineOptions(1263982, 58)
	self:EnableTimelineOptions(1222758, 171)

	self:EnablePrivateAuraSound(1263983, "orbrun", 2)
	self:EnablePrivateAuraSound(1282770, "runout", 2)
	self:EnablePrivateAuraSound(1248130, "watchfeet", 8)
	DBM:Debug("check void cascade private aura")
end
