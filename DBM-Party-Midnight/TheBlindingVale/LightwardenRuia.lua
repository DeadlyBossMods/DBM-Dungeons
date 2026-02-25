local mod	= DBM:NewMod(2771, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(245912)
mod:SetEncounterID(3201)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1240098, true, 2)--Lightfall
mod:AddCustomAlertSoundOption(1241058, "Healer", 2)--Grievous Thrash
mod:AddCustomAlertSoundOption(1239885, true, 1)--Bear Form
mod:AddCustomAlertSoundOption(1239882, true, 1)--Moonkin Form
mod:AddCustomAlertSoundOption(1239883, true, 1)--Haranir Form
mod:AddCustomAlertSoundOption(1241067, true, 2)--Spirits of The Vale
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1239825, true, 3, 0)--Lightfire
mod:AddCustomTimerOptions(1240098, true, 3, 0)--Lightfall
mod:AddCustomTimerOptions(1240222, true, 3, 0)--Pulverizing Strikes
mod:AddCustomTimerOptions(1241058, true, 5, 0)--Grievous Thrash
mod:AddCustomTimerOptions(1239885, true, 6, 0)--Bear Form
mod:AddCustomTimerOptions(1239882, true, 6, 0)--Moonkin Form
mod:AddCustomTimerOptions(1239883, true, 6, 0)--Haranir Form
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1239825, true, 1239825, 1, 1)--Lightfire
mod:AddPrivateAuraSoundOption(1240222, true, 1240222, 1, 1)--Pulverizing Strikes

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1240098, 182, "watchstep", 2, 3)
	self:EnableAlertOptions(1241058, 184, "healfull", 2, 3)
	self:EnableAlertOptions(1239885, 185, "phasechange", 2, 2)
	self:EnableAlertOptions(1239882, 186, "phasechange", 2, 2)
	self:EnableAlertOptions(1239883, 187, "phasechange", 2, 2)
	self:EnableAlertOptions(1241067, 188, "specialsoon", 2, 4, 0)--Health based, so using warning trigger not timer

	self:EnableTimelineOptions(1239825, 181)
	self:EnableTimelineOptions(1240098, 182)
	self:EnableTimelineOptions(1240222, 183)
	self:EnableTimelineOptions(1241058, 184)
	self:EnableTimelineOptions(1239885, 185)
	self:EnableTimelineOptions(1239882, 186)
	self:EnableTimelineOptions(1239883, 187)

	self:EnablePrivateAuraSound(1239825, "runout", 2)
	self:EnablePrivateAuraSound(1240222, "lineyou", 17)--Change sound later if incorrect
end
