local mod	= DBM:NewMod(2660, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(239636)
mod:SetEncounterID(3073)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Watch for more private auras to get added post launch
mod:AddPrivateAuraSoundOption(1223958, true, 1223958, 1)
mod:AddPrivateAuraSoundOption(1224104, true, 1224104, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1223958, "runout", 2)
	self:EnablePrivateAuraSound(1224104, "watchfeet", 8)
end
