local mod	= DBM:NewMod(2682, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(237415)
mod:SetEncounterID(3105)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--TODO, add https://www.wowhead.com/beta/spell=1218203/fingers-of-guldan if it's targeting private aura
--NOTE, need to find private aura for Infernal Fixate
--NOTE, https://www.wowhead.com/beta/spell=1217262/seed-of-corruption has a private aura but not in journal
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1218203, true, 2)--Fingers off Guldan
mod:AddCustomAlertSoundOption(474408, true, 1)--Summon Vilefiend
mod:AddCustomAlertSoundOption(1224478, true, 2)--Malefic Wave
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1218203, true, 1, 0)--Fingers off Guldan
mod:AddCustomTimerOptions(474408, true, 1, 0)--Summon Vilefiend
mod:AddCustomTimerOptions(1224478, true, 6, 0)--Malefic Wave
--Midnight private aura replacements

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1218203, 37, "watchstep", 2, 2)--Or change to mobssoon?
	self:EnableAlertOptions(474408, 38, "bigmob", 1, 2)
	self:EnableAlertOptions(1224478, 207, "specialsoon", 2, 2)--Has no timer or text warning?

	self:EnableTimelineOptions(1218203, 37)
	self:EnableTimelineOptions(474408, 38)
	self:EnableTimelineOptions(1224478, 207)

	--self:EnablePrivateAuraSound(, "safenow", 2)
end
