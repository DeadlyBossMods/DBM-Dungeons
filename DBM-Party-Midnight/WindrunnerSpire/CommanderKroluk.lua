local mod	= DBM:NewMod(2657, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231631)
mod:SetEncounterID(3058)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--https://www.wowhead.com/beta/spell=467620/rampage has a private aura but we should use the boss mod api to register defensive sound on cast begin instead
mod:AddPrivateAuraSoundOption(470966, true, 470966, 4)
mod:AddPrivateAuraSoundOption(468924, true, 468924, 1)
mod:AddPrivateAuraSoundOption(1283247, true, 1283247, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(470966, "justrun", 2)
	self:EnablePrivateAuraSound(468924, "watchfeet", 8)
	self:EnablePrivateAuraSound(1283247, "targetyou", 2)
end
