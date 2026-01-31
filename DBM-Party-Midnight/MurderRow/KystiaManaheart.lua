local mod	= DBM:NewMod(2679, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(252458)
mod:SetEncounterID(3101)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1253813, true, 1253813, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1253813, "watchfeet", 8)
end
