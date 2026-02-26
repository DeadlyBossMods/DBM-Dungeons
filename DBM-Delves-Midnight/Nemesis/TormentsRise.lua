local mod	= DBM:NewMod("Nullaeus", "DBM-Delves-Midnight", 1)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(244752)--Not known which 2 are nemesis boss yet and which 2 are random spawns
mod:SetEncounterID(3372, 3430)
mod:SetHotfixNoticeRev(20250220000000)
mod:SetMinSyncRevision(20250220000000)
mod:SetZone(2966)

mod:RegisterCombat("combat")

--NOTES:
--https://www.wowhead.com/beta/spell=1255886/oblivion-shell is a private aura for a boss ability. Seems iffy to use as a PA sound though
--Despite adding 3 abilities, it's unclear what any of them actually do. Sounds will likely need tweaking.
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1256358, true, 1)--Devouring Essence
mod:AddCustomAlertSoundOption(1256355, true, 1)--Imploding Strike
mod:AddCustomAlertSoundOption(1256351, true, 2)--Emptiness of the Void
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1256358, nil, 3, 0)
mod:AddCustomTimerOptions(1256355, nil, 5, 0)
mod:AddCustomTimerOptions(1256351, nil, 2, 0)
function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1256358, {390,395}, "debuffyou", 17)
	self:EnableAlertOptions(1256355, {391,394}, "defensive", 2)
	self:EnableAlertOptions(1256351, {392,393}, "aesoon", 2)

	self:EnableTimelineOptions(1256358, {390, 395})
	self:EnableTimelineOptions(1256355, {391, 394})
	self:EnableTimelineOptions(1256351, {392, 393})

	--if self:IsMythic() then
	--	self:SetCreatureID(244753)
	--else
	--	self:SetCreatureID(244752)
	--end
end
