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
mod:AddCustomAlertSoundOption(1234753, true, 1)--Bedrock Slam
mod:AddCustomTimerOptions(1234753, true, 5, 0)--Bedrock Slam
mod:AddPrivateAuraSoundOption(1234802, true, 1234802, 1, 2)--Fertile Loam
--Lekshi
mod:AddTimerLine(DBM:EJ_GetSectionInfo(32517))
mod:AddCustomAlertSoundOption(1234850, true, 2)--Lightsower Dash
mod:AddCustomTimerOptions(1234850, true, 3, 0)--Lightsower Dash
mod:AddCustomTimerOptions(1261276, true, 3, 0)--Thornblade
mod:AddPrivateAuraSoundOption(1261276, true, 1261276, 1, 1)--Thornblade
--Kezkitt
mod:AddTimerLine(DBM:EJ_GetSectionInfo(32520))
mod:AddCustomAlertSoundOption(1235564, true, 1)--Lightblossom Beam
mod:AddCustomTimerOptions(1235564, true, 5, 0)--Lightblossom Beam
mod:AddPrivateAuraSoundOption(1235828, true, 1235828, 1, 2)--Light-Scorched Earth

function mod:OnLimitedCombatStart()
	if self:IsTank() then
		self:EnableAlertOptions(1234753, 173, "defensive", 2, 3)
	end
	self:EnableAlertOptions(1234850, 174, "chargemove", 2, 2)
	self:EnableAlertOptions(1235564, 177, "soakbeam", 17, 2)

	self:EnableTimelineOptions(1234753, 173)
	self:EnableTimelineOptions(1234850, 174)
	self:EnableTimelineOptions(1261276, 175, 176)
	self:EnableTimelineOptions(1235564, 177)

	self:EnablePrivateAuraSound(1234802, "watchfeet", 8)
	self:EnablePrivateAuraSound(1261276, "defensive", 2)
	self:EnablePrivateAuraSound(1235828, "watchfeet", 8)
end
