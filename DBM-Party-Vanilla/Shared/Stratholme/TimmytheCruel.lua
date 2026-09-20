local mod	= DBM:NewMod(445, "DBM-Party-Vanilla", DBM:IsPostCata() and 10 or 16, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10808)
mod:SetEncounterID(474)
mod:SetModelID(571)
mod:SetZone(329)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 8599"
	)

	local warningEnrage		= mod:NewTargetNoFilterAnnounce(8599, 2)

	function mod:SPELL_AURA_APPLIED(args)
		if args:IsSpell(8599) then
			warningEnrage:Show(args.destName)
		end
	end
end
