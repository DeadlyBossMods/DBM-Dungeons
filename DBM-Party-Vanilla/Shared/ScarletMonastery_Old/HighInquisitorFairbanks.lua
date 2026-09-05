local mod	= DBM:NewMod("Fairbanks", "DBM-Party-Vanilla", DBM:IsPostCata() and 17 or 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(4542)
mod:SetEncounterID(449)
mod:SetModelID(2605)
mod:SetZone(189)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 8282"
	)

	local warningCurseofBlood			= mod:NewTargetNoFilterAnnounce(8282, 2, nil, "RemoveCurse")

	function mod:SPELL_AURA_APPLIED(args)
		if args:IsSpell(8282) then
			warningCurseofBlood:Show(args.destName)
		end
	end
end
