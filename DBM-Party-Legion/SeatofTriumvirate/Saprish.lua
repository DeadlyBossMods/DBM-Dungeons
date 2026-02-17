local mod	= DBM:NewMod(1980, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(124872)
mod:SetEncounterID(2066)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(247175, true, 1)--Void Bomb
	mod:AddCustomAlertSoundOption(248831, true, 2)--Dread Screech
	mod:AddCustomAlertSoundOption(1263523, true, 2)--Overload
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(247175, true, 3, 0)
	mod:AddCustomTimerOptions(1280064, true, 3, 0)
	mod:AddCustomTimerOptions(248831, true, 2, 0)
	mod:AddCustomTimerOptions(245738, true, 3, 0)
	mod:AddCustomTimerOptions(1263523, true, 2, 0)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1280064, true, 1280064, 1)--Phase Dash
	mod:AddPrivateAuraSoundOption(245742, true, 245742, 2)--Shadow Pounce

	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()
		self:EnableAlertOptions(247175, 234, "bombsoon", 2)
		if self:IsSpellCaster() then
			self:EnableAlertOptions(248831, 236, "stopcast", 2)
		else
			self:EnableAlertOptions(248831, 236, "aesoon", 2)
		end
		self:EnableAlertOptions(1263523, 243, "aesoon", 2)


		self:EnableTimelineOptions(247175, 234)
		self:EnableTimelineOptions(1280064, 235)
		self:EnableTimelineOptions(248831, 236)
		self:EnableTimelineOptions(245738, 237)
		self:EnableTimelineOptions(1263523, 243)

		self:EnablePrivateAuraSound(1280064, "lineyou", 17)
		self:EnablePrivateAuraSound(245742, "targetyou", 2)
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 245802 248831",
		"SPELL_CAST_SUCCESS 247245",
		"SPELL_AURA_APPLIED 247245",
	--	"SPELL_AURA_REMOVED 247245",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, see if swoop/screech target can be identified
	--Void Hunter
	local warnUmbralFlanking				= mod:NewTargetAnnounce(247245, 3)
	local warnVoidTrap						= mod:NewSpellAnnounce(246026, 3, nil, nil, nil, nil, nil, 2)
	--local warnDreadScreech					= mod:NewCastAnnounce(248831, 2)

	--local specWarnHuntersRush				= mod:NewSpecialWarningDefensive(247145, nil, nil, nil, 1, 2)
	local specWarnOverloadTrap				= mod:NewSpecialWarningDodge(247206, nil, nil, nil, 2, 2)
	local specWarnUmbralFlanking			= mod:NewSpecialWarningMoveAway(247245, nil, nil, nil, 1, 2)
	local yellUmbralFlanking				= mod:NewYell(247245)
	local specWarnRavagingDarkness			= mod:NewSpecialWarningDodge(245802, nil, nil, nil, 2, 2)
	local specWarnDreadScreech				= mod:NewSpecialWarningInterrupt(248831, "HasInterrupt", nil, nil, 1, 2)

	local timerVoidTrapCD					= mod:NewCDTimer(15.8, 246026, nil, nil, nil, 3)
	local timerOverloadTrapCD				= mod:NewCDTimer(20.6, 247206, nil, nil, nil, 3)
	local timerRavagingDarknessCD			= mod:NewCDTimer(8.8, 245802, nil, nil, nil, 3)
	local timerUmbralFlankingCD				= mod:NewCDTimer(35.2, 247245, nil, nil, nil, 3)
	local timerScreechCD					= mod:NewCDTimer(15.4, 248831, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON)

	function mod:OnCombatStart(delay)
		timerRavagingDarknessCD:Start(5.5-delay)
		timerVoidTrapCD:Start(8.8-delay)
		timerOverloadTrapCD:Start(12.5-delay)
		timerUmbralFlankingCD:Start(20.4-delay)
		if self:IsHard() then
			--Stuff
			timerScreechCD:Start(6.2-delay)
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 245802 then
			specWarnRavagingDarkness:Show()
			specWarnRavagingDarkness:Play("watchstep")
			timerRavagingDarknessCD:Start()
		elseif spellId == 248831 then
			specWarnDreadScreech:Show(args.sourceName)
			specWarnDreadScreech:Play("kickcast")
			timerScreechCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 247245 then
			timerUmbralFlankingCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 247245 then
			warnUmbralFlanking:CombinedShow(0.3, args.destName)
			if args:IsPlayer() then
				specWarnUmbralFlanking:Show()
				specWarnUmbralFlanking:Play("scatter")
				yellUmbralFlanking:Yell()
			end
	--	elseif spellId == 247145 then
	--		if self:IsTanking("player", "boss1", nil, true) then
	--			specWarnHuntersRush:Show()
	--			specWarnHuntersRush:Play("defensive")
	--		end
		end
	end

	--[[
	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 247245 then

		end
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find("inv_misc_monsterhorn_03") then

		end
	end
	--]]

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 247175 then--Void Trap
			warnVoidTrap:Show()
			warnVoidTrap:Play("watchstep")
			timerVoidTrapCD:Start()
		elseif spellId == 247206 then--Overload Trap
			specWarnOverloadTrap:Show()
			specWarnOverloadTrap:Play("watchstep")
			timerOverloadTrapCD:Start()
		end
	end
end
