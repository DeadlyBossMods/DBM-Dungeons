local mod	= DBM:NewMod(2793, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248015)
mod:SetEncounterID(3287)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1263983, true, 1263983, 4)
mod:AddPrivateAuraSoundOption(1282770, true, 1282770, 1)--Pre debuff
mod:AddPrivateAuraSoundOption(1248130, true, 1282770, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1263983, "orbrun", 2)
	self:EnablePrivateAuraSound(1282770, "runout", 2)
	self:EnablePrivateAuraSound(1282770, "watchfeet", 8)
end
