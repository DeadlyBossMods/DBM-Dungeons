local mod	= DBM:NewMod(2771, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(245912)
mod:SetEncounterID(3201)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1239825, true, 1239825, 1)
mod:AddPrivateAuraSoundOption(1240222, true, 1240222, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1239825, "runout", 2)
	self:EnablePrivateAuraSound(1240222, "lineyou", 17)--Change sound later if incorrect
end
