local mod	= DBM:NewMod("AgathelostheRaging", "DBM-Party-Vanilla", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(4422)
--mod:SetEncounterID(438)
mod:SetZone(47)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 8269"
	)

	--https://classic.wowhead.com/spell=8555/left-for-dead nani? is wowhead tripping? no mention of this in comments or guides
	local warningEnrage				= mod:NewTargetNoFilterAnnounce(8269, 2)

	function mod:SPELL_AURA_APPLIED(args)
		if args:IsSpell(8269) and args:IsDestTypeHostile() then
			warningEnrage:Show(args.destName)
		end
	end
end
