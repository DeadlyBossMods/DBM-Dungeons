local mod	= DBM:NewMod(2772, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(247676)
mod:SetEncounterID(3202)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1253690, true, 1253690, 1)--FIX ME if not pre positioned spell
mod:AddPrivateAuraSoundOption(1246751, true, 1246751, 1)
mod:AddPrivateAuraSoundOption(1246753, true, 1246753, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1253690, "movetomobs", 14)
	self:EnablePrivateAuraSound(1246751, "watchfeet", 8)
	self:EnablePrivateAuraSound(1246753, "watchfeet", 8)
end
