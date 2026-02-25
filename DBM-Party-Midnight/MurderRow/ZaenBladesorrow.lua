local mod	= DBM:NewMod(2680, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234649)
mod:SetEncounterID(3102)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, https://www.wowhead.com/spell=1218465/server and https://www.wowhead.com/spell=1218466/cleaner need to be added to trashmod somehow
--Custon Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(474765, true, 2)--Same Day Delivery
mod:AddCustomAlertSoundOption(474478, true, 2)--Killing Spree
mod:AddCustomAlertSoundOption(1222795, true, 2)--Envenom
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1214352, true, 3, 0)--Fire Bomb
mod:AddCustomTimerOptions(474765, true, 3, 0)--Same Day Delivery
mod:AddCustomTimerOptions(474545, true, 2, 0)--Murder in a Row
mod:AddCustomTimerOptions(474478, true, 2, 0)--Killing Spree
mod:AddCustomTimerOptions(1222795, true, 5, 0)--Envenom
----Midnight private aura replacements
mod:AddPrivateAuraSoundOption(474545, true, 474545, 1)--Murder in a Row
mod:AddPrivateAuraSoundOption(1214352, true, 1214352, 1)--Fire Bomb

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(474765, 124, "watchstep", 2, 2)
	self:EnableAlertOptions(474478, 127, "aesoon", 2, 2)
	self:EnableAlertOptions(1222795, 193, "defensive", 2, 3)

	self:EnableTimelineOptions(1214352, 123)
	self:EnableTimelineOptions(474765, 124)
	self:EnableTimelineOptions(474545, 125)
	self:EnableTimelineOptions(474478, 127)
	self:EnableTimelineOptions(1222795, 193)

	self:EnablePrivateAuraSound(474545, "breaklos", 12)
	self:EnablePrivateAuraSound(1214352, "bombyou", 12)
end
