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

mod:AddPrivateAuraSoundOption(474545, true, 474545, 1)
mod:AddPrivateAuraSoundOption(1214352, true, 1214352, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(474545, "breaklos", 12)
	self:EnablePrivateAuraSound(1214352, "runout", 2)
end
