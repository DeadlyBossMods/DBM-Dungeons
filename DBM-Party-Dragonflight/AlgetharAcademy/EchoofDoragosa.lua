local mod	= DBM:NewMod(2514, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(190609)
mod:SetEncounterID(2565)
mod:SetHotfixNoticeRev(20221015000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2526)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Note: https://www.wowhead.com/spell=374350/energy-bomb is NOT a private aura so we can't do anything with it currently
if DBM:IsPostMidnight() then
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(1282251, false, 1)--Astral Blast
	mod:AddCustomAlertSoundOption(374341, true, 2)--Bandaid for now. We can't announce victims just the cast
	mod:AddCustomAlertSoundOption(388820, true, 2)--Power Vacuum
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(373325, nil, 3, 0)
	mod:AddCustomTimerOptions(1282251, nil, 5, 0)
	mod:AddCustomTimerOptions(374341, nil, 3, 0)
	mod:AddCustomTimerOptions(388820, nil, 2, 0)
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(389007, true, 389007, 1)--GTFO
	mod:AddPrivateAuraSoundOption(389011, true, 389011, 1)--Overwhelming Power (off by default since we can't warn all stacks, just initial)

	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()

		self:EnableAlertOptions(1282251, 294, "defensive", 2)
		self:EnableAlertOptions(374341, 295, "scattersoon", 2)
		self:EnableAlertOptions(388820, 296, "runout", 2)

		self:EnableTimelineOptions(373325, 293)
		self:EnableTimelineOptions(1282251, 294)
		self:EnableTimelineOptions(374341, 295)
		self:EnableTimelineOptions(388820, 296)

		self:EnablePrivateAuraSound(389007, "watchfeet", 8)
		self:EnablePrivateAuraSound(389011, "debuffyou", 17)
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 374361 388822",
		"SPELL_CAST_SUCCESS 374343",
		"SPELL_AURA_APPLIED 389011 374350 389007",
		"SPELL_AURA_APPLIED_DOSE 389011",
		"SPELL_AURA_REMOVED 374350 389011"
	)

	--Notes, Power Vaccume triggers 4 second ICD, Energy Bomb Triggers 8.5 ICD on Vaccuum but only 7 second ICD on Breath, Astraol breath triggers 7.5 ICD
	--Notes, All of ICD adjustments can be done but for a 5 man boss with 3 abilities it seems overkill. Only perform correction on one case for now
	--[[
	(ability.id = 374361 or ability.id = 388822 or ability.id = 439488) and type = "begincast"
	 or ability.id = 374343 and type = "cast"
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	local warnOverwhelmingPoweer					= mod:NewCountAnnounce(389011, 3, nil, nil, DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.stack:format(389011))--Typical stack warnings have amount and playername, but since used as personal, using count object to just display amount then injecting option text for stack
	local warnEnergyBomb							= mod:NewTargetAnnounce(374352, 3)

	local specWarnAstralBreath						= mod:NewSpecialWarningDodge(374361, nil, nil, nil, 2, 2)
	local specWarnPowerVacuum						= mod:NewSpecialWarningRun(388822, nil, nil, nil, 4, 2)
	local specWarnEnergyBomb						= mod:NewSpecialWarningMoveAway(374352, nil, nil, nil, 1, 2)
	local yellEnergyBomb							= mod:NewYell(374352)
	local yellEnergyBombFades						= mod:NewShortFadesYell(374352)
	local specWarnGTFO								= mod:NewSpecialWarningGTFO(389007, nil, nil, nil, 1, 8)

	local timerAstralBreathCD						= mod:NewCDTimer(26.3, 374361, nil, nil, nil, 3)--26-32
	local timerPowerVacuumCD						= mod:NewCDTimer(21, 388822, nil, nil, nil, 2)--22-29
	local timerEnergyBombCD							= mod:NewCDTimer(14.1, 374352, nil, nil, nil, 3)--14.1-20

	mod:AddInfoFrameOption(389011, true)

	local playerDebuffCount = 0

	function mod:OnCombatStart(delay)
		timerEnergyBombCD:Start(15.9-delay)
		timerPowerVacuumCD:Start(24.9-delay)
		timerAstralBreathCD:Start(28.1-delay)
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(DBM:GetSpellName(389011))
			DBM.InfoFrame:Show(5, "playerdebuffstacks", 389011)
		end
	end

	function mod:OnCombatEnd()
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 374361 then
			specWarnAstralBreath:Show()
			specWarnAstralBreath:Play("breathsoon")
			timerAstralBreathCD:Start()
		elseif spellId == 388822 then
			specWarnPowerVacuum:Show()
			specWarnPowerVacuum:Play("justrun")
			timerPowerVacuumCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 374343 then
			timerEnergyBombCD:Start()
			local remaining = timerPowerVacuumCD:GetRemaining()
			if remaining < 8.5 then
				local adjust = 8.5 - remaining
				timerPowerVacuumCD:AddTime(adjust)
				DBM:Debug("timerPowerVacuumCD extended by: "..adjust)
			end
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 389011 and args:IsPlayer() then
			local amount = args.amount or 1
			playerDebuffCount = amount
			warnOverwhelmingPoweer:Show(amount)
		elseif spellId == 374350 then
			warnEnergyBomb:CombinedShow(0.3, args.destName)
			if args:IsPlayer() then
				specWarnEnergyBomb:Show()
				if playerDebuffCount == 3 then--Will spawn rift when it expires, runout
					specWarnEnergyBomb:Play("runout")
				else
					specWarnEnergyBomb:Play("scatter")
				end
				yellEnergyBomb:Yell()
				yellEnergyBombFades:Countdown(spellId)
			end
		elseif spellId == 389007 and args:IsPlayer() and self:AntiSpam(2, 4) then
			specWarnGTFO:Show(args.spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 374350 then
			if args:IsPlayer() then
				yellEnergyBombFades:Cancel()
			end
		elseif spellId == 389011 and args:IsPlayer() then
			playerDebuffCount = 0
		end
	end
end
