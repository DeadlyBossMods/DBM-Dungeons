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

mod:AddPrivateAuraSoundOption(1235405, false, 1235405, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1235405, "screwup", 18)
end
