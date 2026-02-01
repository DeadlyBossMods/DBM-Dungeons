local mod	= DBM:NewMod(2791, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(238887)
mod:SetEncounterID(3285)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

mod:AddPrivateAuraSoundOption(1225011, true, 1225011, 1)
mod:AddPrivateAuraSoundOption(1222098, true, 1222098, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1225011, "debuffyou", 17)--change to "lineyou" if it uses a line
	self:EnablePrivateAuraSound(1222098, "chargemove", 2)
end
