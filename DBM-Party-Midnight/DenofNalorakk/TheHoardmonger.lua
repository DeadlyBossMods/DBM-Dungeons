local mod	= DBM:NewMod(2776, "DBM-Party-Midnight", 5, 1311)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248710)
mod:SetEncounterID(3207)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2825)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, resourceful measures is missing eventID, all sub events are too but likely use same IDs as unempowered versions
--but no timer for empowerment change sadly
-- Custon Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1234233, true, 2)--Spoiled Supplies
mod:AddCustomAlertSoundOption(1253268, true, 2)--Earthshatter Slam
mod:AddCustomAlertSoundOption(1235118, true, 2)--Ravenous Bellow
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1234233, true, 5, 0)--Spoiled Supplies
mod:AddCustomTimerOptions(1253268, true, 3, 0)--Earthshatter Slam
mod:AddCustomTimerOptions(1235118, true, 2, 0)--Ravenous Bellow
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1235405, true, 1235405, 1, 2)--Bonespiked
mod:AddPrivateAuraSoundOption(1234846, false, 1234846, 1, 1)--Toxic Spores (off by default, i don't think it needs a sound, since we can't alert stacks, the PA anchor will handle it

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1234233, 86, "greenmushroomcoming", 12, 2)
	self:EnableAlertOptions(1253268, 87, "frontal", 15, 2)
	self:EnableAlertOptions(1235118, 88, "aesoon", 2, 2)

	self:EnableTimelineOptions(1234233, 86)
	self:EnableTimelineOptions(1253268, 87)
	self:EnableTimelineOptions(1235118, 88)

	self:EnablePrivateAuraSound(1235405, "watchfeet", 8)
	self:EnablePrivateAuraSound(1234846, "toxic", 2)
end
