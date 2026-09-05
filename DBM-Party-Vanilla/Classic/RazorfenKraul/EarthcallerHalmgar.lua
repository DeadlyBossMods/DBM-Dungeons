local mod	= DBM:NewMod("EarthcallerHalmgar", "DBM-Party-Vanilla", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(4842)
--mod:SetEncounterID(438)
mod:SetModelID(6102)
mod:SetZone(47)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 8270"
	)

	--Guide mentions a totem, but no data for it in wowhead
	--Rumbler spawned on engage
	local warningSummonEarthRumbler		= mod:NewSpellAnnounce(8270, 2)

	function mod:SPELL_CAST_SUCCESS(args)
		if args:IsSpell(8270) then
			warningSummonEarthRumbler:Show()
		end
	end
end
