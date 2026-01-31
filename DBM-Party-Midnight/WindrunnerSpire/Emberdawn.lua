local mod	= DBM:NewMod(2655, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231606)
mod:SetEncounterID(3056)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--https://www.wowhead.com/beta/spell=1253907/fire-breath is a private aura but it's hidden but keep an eye on it
--https://www.wowhead.com/beta/spell=470212/flaming-twisters is a private aura but it's impractical to add a sound for
--TODO, fix privaet aura GTFO sound defaults if assumption is wrong
mod:AddPrivateAuraSoundOption(466559, true, 466559, 1)
mod:AddPrivateAuraSoundOption(472118, false, 472118, 1)--GTFO that's off by default because under certain conditions you do not want to avoid it

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(466559, "runout", 2)
	self:EnablePrivateAuraSound(472118, "watchfeet", 8)
end
