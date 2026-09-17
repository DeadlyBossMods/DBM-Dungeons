local mod	= DBM:NewMod("LordAlexeiBarov", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10504)
mod:SetEncounterID(mod:IsClassic() and 2807 or 461)
mod:SetZone(289)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 17820"
	)

	local warningVeilofShadow			= mod:NewTargetNoFilterAnnounce(17820, 2, nil, "RemoveCurse")

	function mod:SPELL_AURA_APPLIED(args)
		if args:IsSpell(17820) then
			warningVeilofShadow:CombinedShow(0.5, args.destName)
		end
	end
end
