local mod	= DBM:NewMod(1210, "DBM-Party-WoD", 5, 556)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

if (wowToc >= 100200) then
	mod.upgradedMPlus = true
	mod.sendMainBossGUID = true
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(83846)
mod:SetEncounterID(1756)
mod:SetHotfixNoticeRev(20231021000000)
mod:SetMinSyncRevision(20231021000000)

mod:RegisterCombat("combat")

if (wowToc >= 100200) then
	--Patch 10.2 or later
	mod:SetUsedIcons(8)
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 169179 169613 428823 173563 169929",
		"SPELL_AURA_APPLIED 428948 428746",
	--	"SPELL_PERIODIC_DAMAGE",
	--	"SPELL_PERIODIC_MISSED",
		"UNIT_DIED"
	)
	--[[
	(ability.id = 169179 or ability.id = 169613 or ability.id = 428823 or ability.id = 173563 or ability.id = 169929) and type = "begincast"
	 or ability.id = 428948 and type = "applybuff"
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	 --]]
	 --NOTE: This mod was made from old log, people apparently suck at everbloom and aren't getting to last boss this most recent test weekend
	local warnBrushfire									= mod:NewTargetNoFilterAnnounce(428746, 1)

	local specWarnColossalBlow							= mod:NewSpecialWarningDodge(169179, nil, nil, nil, 2, 2)--Still random direction or now only toward tank?
	local specWarnVerdantEruption						= mod:NewSpecialWarningSwitchCount(428823, "-Healer", nil, nil, 1, 2)
	local specWarnLumberingSwipe						= mod:NewSpecialWarningDodge(169929, nil, nil, nil, 2, 2)
	local specWarnGenesis								= mod:NewSpecialWarningCount(169613, nil, nil, nil, 1, 12)
	local specWarnLasherVenom							= mod:NewSpecialWarningInterrupt(173563, "HasInterrupt", nil, nil, 1, 2)
	--local specWarnGTFO								= mod:NewSpecialWarningGTFO(409058, nil, nil, nil, 1, 8)

	local timerBrushfireCD								= mod:NewNextTimer(15.4, 428746, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)--For buff going back up on boss, DPS can time burst CDs
	local timerColossalBlowCD							= mod:NewCDTimer(15.3, 169179, nil, nil, nil, 3, nil, DBM_COMMON_L.TANK_ICON)
	local timerVerdantEruptionCD						= mod:NewCDCountTimer(53.1, 428823, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerLumberingSwipeCD							= mod:NewCDNPTimer(11.8, 169929, nil, nil, nil, 3)
	local timerGenesis									= mod:NewCastTimer(14, 169613, nil, nil, nil, 5)
	local timerGenesisCD								= mod:NewCDCountTimer(53.1, 169613, nil, nil, nil, 6)

	mod:AddSetIconOption("SetIconOnAncient", -10537, true, 5, {8})

	mod.vb.eruptionCount = 0
	mod.vb.GenesisCount = 0

	function mod:OnCombatStart(delay)
		self.vb.eruptionCount = 0
		self.vb.GenesisCount = 0
		timerColossalBlowCD:Start(2.4-delay)
		timerBrushfireCD:Start(4-delay)
		timerVerdantEruptionCD:Start(22.9-delay, 1)
		timerGenesisCD:Start(40-delay, 1)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 169179 then
			if self:AntiSpam(3, 2) then
				specWarnColossalBlow:Show()
				specWarnColossalBlow:Play("shockwave")
			end
			timerColossalBlowCD:Start()
		elseif spellId == 169613 then
			self.vb.GenesisCount = self.vb.GenesisCount + 1
			specWarnGenesis:Show(self.vb.GenesisCount)
			specWarnGenesis:Play("runoverflowers")
			timerGenesis:Start()
			timerGenesisCD:Start(nil, self.vb.GenesisCount+1)
		elseif spellId == 428823 then
			self.vb.eruptionCount = self.vb.eruptionCount + 1
			specWarnVerdantEruption:Show(self.vb.eruptionCount)
			specWarnVerdantEruption:Play("killmob")
			timerVerdantEruptionCD:Start(nil, self.vb.eruptionCount+1)
		elseif spellId == 173563 then
			if self:CheckInterruptFilter(args.sourceGUID, false, true) then
				specWarnLasherVenom:Show(args.sourceName)
				specWarnLasherVenom:Play("kickcast")
			end
		elseif spellId == 169929 then
			if self:AntiSpam(3, 2) then
				specWarnLumberingSwipe:Show()
				specWarnLumberingSwipe:Play("shockwave")
			end
			--timerLumberingSwipeCD:Start(nil, args.sourceGUID)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 428948 and self:AntiSpam(3, 1) then--Vibrant Flourish (fires twice, we want to filter one)
			timerLumberingSwipeCD:Start(5.5, args.destGUID)
			timerBrushfireCD:Start()--Add dispels brushfire soon as Vibrant Flourish goes up on it
			if self.Options.SetIconOnAncient then
				self:ScanForMobs(args.destGUID, 2, 8, 1, nil, 12, "SetIconOnAncient")
			end
		elseif spellId == 428746 then
			warnBrushfire:Show(args.destName)
		end
	end

	--[[
	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 409058 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
	--]]

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 84400 then--Flourishing Ancient
			timerLumberingSwipeCD:Stop(args.destGUID)
		end
	end
else
	--10.1.7 on retail, and classic if it happens (if it doesn't happen old version of mod will be retired)
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 169179 169613",
		"SPELL_CAST_SUCCESS 169251",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	local warnFontofLife			= mod:NewSpellAnnounce(169120, 3)--Does this need a switch warning too?

	local specWarnColossalBlow		= mod:NewSpecialWarningDodge(169179, nil, nil, nil, 2, 2)
	local specWarnEntanglement		= mod:NewSpecialWarningSwitch(169251, "Dps", nil, nil, 1, 2)
	local specWarnGenesis			= mod:NewSpecialWarningSpell(169613, nil, nil, nil, 1, 12)--Everyone. "Switch" is closest generic to "run around stomping flowers"

	--Only timers that were consistent, others are all over the place.
	local timerFontOfLife			= mod:NewNextTimer(15, 169120, nil, nil, nil, 1)
	local timerGenesis				= mod:NewCastTimer(17, 169613, nil, nil, nil, 5)
	local timerGenesisCD			= mod:NewNextTimer(60.5, 169613, nil, nil, nil, 6)

	function mod:OnCombatStart(delay)
		--timerFontOfLife:Start(-delay)
		--timerGenesisCD:Start(25-delay)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 169179 then
			specWarnColossalBlow:Show()
			specWarnColossalBlow:Play("shockwave")
		elseif spellId == 169613 then
			specWarnGenesis:Show()
			specWarnGenesis:Play("runoverflowers")
			timerGenesis:Start()
			timerGenesisCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellId == 169251 then
			specWarnEntanglement:Show()
			specWarnEntanglement:Play("targetchange")
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 169120 then
			warnFontofLife:Show()
			timerFontOfLife:Start()
		end
	end
end
