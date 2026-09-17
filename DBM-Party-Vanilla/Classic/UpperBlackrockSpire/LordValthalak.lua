local mod	= DBM:NewMod("LordValthalak", "DBM-Party-Vanilla", DBM:IsCata() and 18 or 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:DisableHardcodedOptions()
mod:SetCreatureID(16042)
mod:SetZone(229)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
else

	mod:RegisterEventsInCombat(
		"SPELL_CAST_SUCCESS 27249"
	)

	local warnSummonAssassin		= mod:NewSpellAnnounce(27249, 2)

	local timerSummonAssassinCD		= mod:NewAITimer(180, 27249, nil, nil, nil, 1)

	function mod:OnCombatStart(delay)
		timerSummonAssassinCD:Start(1-delay)
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args:IsSpell(27249) then
			warnSummonAssassin:Show()
			timerSummonAssassinCD:Start()
	    end
	end
end
