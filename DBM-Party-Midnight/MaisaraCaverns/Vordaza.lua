local mod	= DBM:NewMod(2811, "DBM-Party-Midnight", 7, 1315)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248595)
mod:SetEncounterID(3213)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2874)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, EncounterEvent tracks an ability NOT in journal (Deaths Embrace)
--NOTE, final pursuit has TWO eventIDs even though it's an add fixate. maybe it has a timer?
--NOTE, whispering miasma has no event ID, but might be a persistent effect entire encounter and not need one
--NOTE, https://www.wowhead.com/spell=1251813/lingering-dread has a private aura but it doesn't need an alert, just anchor tracking
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1251554, true, 1)--Drain Soul
mod:AddCustomAlertSoundOption(1252054, true, 2)--Unmake
mod:AddCustomAlertSoundOption(1251996, true, 2)--Deaths' Embrace
mod:AddCustomAlertSoundOption(1252130, true, 2)--Wrest Phantoms
mod:AddCustomAlertSoundOption(1250708, true, 2)--Necrotic Convergence
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1251554, "Tank|Healer", 5, 0)--Drain Soul
mod:AddCustomTimerOptions(1252054, true, 3, 0)--Unmake
mod:AddCustomTimerOptions(1251996, true, 3, 0)--Deaths' Embrace
mod:AddCustomTimerOptions(1252130, true, 1, 0)--Wrest Phantoms
mod:AddCustomTimerOptions(1250708, true, 4, 0)--Necrotic Convergence
--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1252130, true, 1252130, 1, 2)--Unmake damage
mod:AddPrivateAuraSoundOption(1251775, true, 1251775, 1, 2)--Final Pursuit

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(1251554, 16, "defensive", 2, 3)
	end
	self:EnableAlertOptions(1252054, 17, "frontal", 15, 3)
	self:EnableAlertOptions(1251996, 18, "ghostsoon", 8, 2)
	self:EnableAlertOptions(1252130, 19, "mobsoon", 2, 2)
	self:EnableAlertOptions(1250708, 20, "attackshield", 2, 2)

	self:EnableTimelineOptions(1251554, 16)
	self:EnableTimelineOptions(1252054, 17)
	self:EnableTimelineOptions(1251996, 18)
	self:EnableTimelineOptions(1252130, 19)
	self:EnableTimelineOptions(1250708, 20)

	self:EnablePrivateAuraSound(1252130, "watchfeet", 8)--Change or remove if wrong
	self:EnablePrivateAuraSound(1251775, "fixateyou", 19)
end
