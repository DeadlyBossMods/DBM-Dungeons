local mod	= DBM:NewMod(2770, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(244887)
mod:SetEncounterID(3200)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1237091, true, 1237091, 4)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1237091, "justrun", 2)
end
