local mod	= DBM:NewMod(2813, "DBM-Party-Midnight", 8, 1316)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(241539)--Iffy, not reported as a boss
mod:SetEncounterID(3328)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2915)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1257509, true, 2)--Corespark Detonation
mod:AddCustomAlertSoundOption(1251183, true, 2)--Leyline Array
mod:AddCustomAlertSoundOption(1264048, true, 2)--Flux Collapse
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1257509, true, 3, 0)--Corespark Detonation
mod:AddCustomTimerOptions(1251785, true, 3, 0)--Reflux Charge
mod:AddCustomTimerOptions(1251183, true, 3, 0)--Leyline Array
mod:AddCustomTimerOptions(1264048, true, 3, 0)--Flux Collapse
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1251785, true, 1214089, 1, 1)--Reflux Charge
mod:AddPrivateAuraSoundOption(1264042, true, 1264042, 1, 2)--Arcane Spill

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1257509, 106, "watchstep", 2, 2)
	self:EnableAlertOptions(1251183, 108, "farfromline", 2, 3)
	self:EnableAlertOptions(1264048, 172, "watchstep", 2, 2)

	self:EnableTimelineOptions(1257509, 106)
	self:EnableTimelineOptions(1251785, 107)
	self:EnableTimelineOptions(1251183, 108)
	self:EnableTimelineOptions(1264048, 172)

	self:EnablePrivateAuraSound(1251785, "movetobeam", 19)
	self:EnablePrivateAuraSound(1264042, "watchfeet", 8)
end
