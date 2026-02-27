local mod	= DBM:NewMod(2815, "DBM-Party-Midnight", 8, 1316)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(241546)
mod:SetEncounterID(3333)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2915)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1255503, true, 2)--Brilliant Dispersion
mod:AddCustomAlertSoundOption(1257567, true, 2)--Divine Guile
mod:AddCustomAlertSoundOption(1255335, true, 1)--Searing Rend
mod:AddCustomAlertSoundOption(1255531, true, 2)--Flicker
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1255503, true, 3, 0)--Brilliant Dispersion
mod:AddCustomTimerOptions(1257567, true, 6, 0)--Divine Guile
mod:AddCustomTimerOptions(1255335, true, 5, 0)--Searing Rend
mod:AddCustomTimerOptions(1255531, true, 3, 0)--Flicker
--Private Auras
mod:AddPrivateAuraSoundOption(1255503, true, 1255503, 1, 1)--Brilliant Dispersion
--mod:AddPrivateAuraSoundOption(1255335, false, 1255335, 1, 1)--Searing Rend
mod:AddPrivateAuraSoundOption(1255310, true, 1255310, 1, 2)--Radiant Scar
--mod:AddPrivateAuraSoundOption(1271956, false, 1271956, 1, 1)--Mirrored Rend

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(1255503, 109, "scattersoon", 2)--Pre spread
	self:EnableAlertOptions(1257567, 110, "phasechange", 2)
	if self:IsTank() then
		self:EnableAlertOptions(1255335, 111, "defensive", 2)
	end
	self:EnableAlertOptions(1255531, 112, "watchstep", 2)

	self:EnableTimelineOptions(1255503, 109)
	self:EnableTimelineOptions(1257567, 110)
	self:EnableTimelineOptions(1255335, 111)
	self:EnableTimelineOptions(1255531, 112)

	self:EnablePrivateAuraSound(1255503, "poolyou", 18)--Run out to place images?
--	self:EnablePrivateAuraSound(1255335, "poolyou", 18)
	self:EnablePrivateAuraSound(1255310, "watchfeet", 8)
--	self:EnablePrivateAuraSound(1271956, "poolyou", 18)
end
