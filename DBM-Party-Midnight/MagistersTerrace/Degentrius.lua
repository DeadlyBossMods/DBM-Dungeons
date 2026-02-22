local mod	= DBM:NewMod(2662, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231865)
mod:SetEncounterID(3074)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE: Boss encounter events are out of date with journal. Blizzard probably forgot to update boss mod after a redesign
--Note: Stygian Ichor is missing PA sound for GTFO but should probably have one
--Custom Sounds on cast/cooldown expiring
--mod:AddCustomAlertSoundOption(1269668, true, 2)--WARNING: This ability is no longer in encounter journal (Umbral Eruption)
mod:AddCustomAlertSoundOption(1215087, true, 2)--Unstable Void Essence
mod:AddCustomAlertSoundOption(1280113, true, 1)--Hulking Fragment
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1215897, true, 3, 0)--Devouring Entropy
mod:AddCustomTimerOptions(1215087, true, 5, 0)--Unstable Void Essence
mod:AddCustomTimerOptions(1280113, true, 5, 0)--Hulking Fragment
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1215897, true, 1215897, 1, 1)--Devouring Entropy

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1215087, 292, "catchballs", 12)
	if self:IsTank() then
		self:EnableAlertOptions(1280113, 420, "defensive", 2)
	end

	self:EnableTimelineOptions(1215897, 290)
	self:EnableTimelineOptions(1215087, 292)
	self:EnableTimelineOptions(1280113, 420)

	self:EnablePrivateAuraSound(1215897, "scatter", 2)
end
