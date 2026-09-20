local mod	= DBM:NewMod(480, "DBM-Party-Vanilla", DBM:IsPostCata() and 14 or 19, 240)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(5775)
mod:SetEncounterID(591)
mod:SetModelID(4256)
mod:SetZone(43)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 8142"
	)

	local warnVines			= mod:NewSpellSourceAnnounce(8142, 2)

	local timerVinesCD		= mod:NewAITimer(180, 8142, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

	function mod:OnCombatStart(delay)
		timerVinesCD:Start(1-delay)
	end

	function mod:SPELL_CAST_START(args)
		if args:IsSpell(8142) and args:IsDestTypePlayer() then
			warnVines:Show(args.sourceName)
			timerVinesCD:Start()
		end
	end
end
