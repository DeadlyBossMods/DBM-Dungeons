local mod	= DBM:NewMod("HoundmasterLoksey", "DBM-Party-Vanilla", DBM:IsPostCata() and 17 or 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(3974)
mod:SetEncounterID(446)
mod:SetModelID(2040)
mod:SetZone(189)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 6742"
	)

	local warningBloodLust		= mod:NewTargetNoFilterAnnounce(6742, 2)

	function mod:SPELL_AURA_APPLIED(args)
		if args:IsSpell(6742) and args:IsDestTypeHostile() then
			warningBloodLust:Show(args.destName)
		end
	end
end
