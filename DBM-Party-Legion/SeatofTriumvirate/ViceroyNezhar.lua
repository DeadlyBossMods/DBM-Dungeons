local mod	= DBM:NewMod(1981, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(124874)
mod:SetEncounterID(2067)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--NOTE: https://www.wowhead.com/spell=244750/mind-blast is spammed so no sound alert or timer
	--NOTE: Repulse might be spammy, i think blizzard meant to hook event up to parent ability Collapsing Void
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(1263538, true, 1)--Hentai
	mod:AddCustomAlertSoundOption(1263528, true, 2)--Repulse
	mod:AddCustomAlertSoundOption(1277358, true, 2)--Gates of teh Abyss
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(1263542, true, 5, 0)
	mod:AddCustomTimerOptions(1263538, true, 1, 0)
	mod:AddCustomTimerOptions(1263528, true, 2, 0)
	mod:AddCustomTimerOptions(1263542, true, 3, 0)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1263542, false, 1263542, 1)--Mass Void Infusion (just minor rot damage, off by default)
	mod:AddPrivateAuraSoundOption(1263532, true, 1263532, 1)--Void Storm (GTFO)

	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()
		self:EnableAlertOptions(1263538, 246, "mobsoon", 1)
		self:EnableAlertOptions(1263528, 247, "carefly", 2)
		self:EnableAlertOptions(1277358, 376, "watchwave", 2)

		self:EnableTimelineOptions(1263542, 245)
		self:EnableTimelineOptions(1263538, 246)
		self:EnableTimelineOptions(1263528, 247)
		self:EnableTimelineOptions(1277358, 376)

		self:EnablePrivateAuraSound(1263542, "debuffyou", 17)
		self:EnablePrivateAuraSound(1263532, "watchfeet", 8)
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 244751 248736",
		"SPELL_CAST_SUCCESS 246324",
		"SPELL_AURA_APPLIED 248804",
		"SPELL_AURA_REMOVED 248804",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, power gain rate consistent?
	--TODO, special warning to switch to tentacles once know for sure how to tell empowered apart from non empowered?
	--TODO, More work on guard timers, with an english log that's actually captured properly (stared and stopped between pulls)
	local warnEternalTwilight				= mod:NewCastAnnounce(248736, 4)
	local warnAddsLeft						= mod:NewAddsLeftAnnounce(-16424, 2)
	local warnTentacles						= mod:NewSpellAnnounce(244769, 2)

	local specWarnHowlingDark				= mod:NewSpecialWarningInterrupt(244751, "HasInterrupt", nil, nil, 1, 2)
	local specWarnEntropicForce				= mod:NewSpecialWarningSpell(246324, nil, nil, nil, 1, 2)
	local specWarnAdds						= mod:NewSpecialWarningAdds(249336, "-Healer", nil, nil, 1, 2)

	local timerUmbralTentaclesCD			= mod:NewCDTimer(30.4, 244769, nil, nil, nil, 1)
	local timerHowlingDarkCD				= mod:NewCDTimer(28.0, 244751, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	local timerEntropicForceCD				= mod:NewCDTimer(28.0, 246324, nil, nil, nil, 2)--28-38
	local timerEternalTwilight				= mod:NewCastTimer(10, 248736, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON, nil, 2, 4)
	local timerAddsCD						= mod:NewAddsTimer(61.9, 249336, nil, "-Healer")

	mod.vb.guardsActive = 0

	function mod:OnCombatStart(delay)
		self.vb.guardsActive = 0
		timerUmbralTentaclesCD:Start(11.8-delay)
		timerHowlingDarkCD:Start(15.5-delay)
		timerEntropicForceCD:Start(35-delay)
		if self:IsHard() then
			timerAddsCD:Start(53-delay)
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 244751 then
			timerHowlingDarkCD:Start()
			specWarnHowlingDark:Show(args.sourceName)
			specWarnHowlingDark:Play("kickcast")
		elseif spellId == 248736 and self:AntiSpam(3, 1) then
			warnEternalTwilight:Show()
			timerEternalTwilight:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 246324 then
			specWarnEntropicForce:Show()
			specWarnEntropicForce:Play("keepmove")
			timerEntropicForceCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 248804 then
			self.vb.guardsActive = self.vb.guardsActive + 1
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 248804 then
			self.vb.guardsActive = self.vb.guardsActive - 1
			if self.vb.guardsActive >= 1 then
				warnAddsLeft:Show(self.vb.guardsActive)
			--else
				--Start timer for next guard here if more accurate
			end
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 245038 then
			warnTentacles:Show()
			timerUmbralTentaclesCD:Start()
		elseif spellId == 249336 then--or 249335
			specWarnAdds:Show()
			specWarnAdds:Play("killmob")
			timerAddsCD:Start()
		end
	end
end
