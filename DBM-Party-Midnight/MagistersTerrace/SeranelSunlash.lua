local mod	= DBM:NewMod(2661, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231863)
mod:SetEncounterID(3072)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1225792, true, 1225792, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1225792, "debuffyou", 17)
end
