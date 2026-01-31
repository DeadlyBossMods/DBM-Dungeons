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

--Note: Stygian Ichor is missing PA sound for GTFO but should probably have one
mod:AddPrivateAuraSoundOption(1215897, true, 1215897, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1215897, "scatter", 2)
end
