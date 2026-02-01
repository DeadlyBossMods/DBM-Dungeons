local mod	= DBM:NewMod(2769, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(243028)--Meittik only one reported as a main boss
mod:SetEncounterID(3199)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Meittik
mod:AddTimerLine(DBM:EJ_GetSectionInfo(32514))
mod:AddPrivateAuraSoundOption(1234802, true, 1234802, 1)
--Lekshi
mod:AddTimerLine(DBM:EJ_GetSectionInfo(32517))
mod:AddPrivateAuraSoundOption(1261276, true, 1261276, 1)
--Kezkitt
mod:AddTimerLine(DBM:EJ_GetSectionInfo(32520))
mod:AddPrivateAuraSoundOption(1235828, true, 1235828, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1234802, "watchfeet", 8)
	self:EnablePrivateAuraSound(1261276, "defensive", 2)
	self:EnablePrivateAuraSound(1235828, "watchfeet", 8)
end
