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
	mod:AddCustomAlertSoundOption(374341, true, 2)--Energy Bomb: ENCOUNTER_WARNING provides target name
	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(389007, true, 389007, 1, 1, "watchfeet", 8)--GTFO
	mod:AddPrivateAuraSoundOption(389011, true, 389011, 1, 1, "debuffyou", 17)--Overwhelming Power (off by default since we can't warn all stacks, just initial)

	local warnEnergyBomb					= mod:NewCountAnnounce(374341, 3)--Blizzard alert will handle personal bomb alert

	local specWarnAstralBlast				= mod:NewSpecialWarningCount(1282251, nil, nil, nil, 1, 2)
	local specWarnPowerVacuum				= mod:NewSpecialWarningCount(388820, nil, 56689, nil, 2, 2)

	local timerArcaneBarrageCD				= mod:NewCDCountTimer(20.5, 373325, nil, nil, nil, 3)
	local timerAstralBlastCD				= mod:NewCDCountTimer(20.5, 1282251, nil, nil, nil, 5)
	local timerEnergyBombCD					= mod:NewCDCountTimer(20.5, 374341, nil, nil, nil, 3)
	local timerPowerVacuumCD				= mod:NewCDCountTimer(20.5, 388820, 56689, nil, nil, 2)--Shortname "Grip"

	mod.vb.barrageCount = 0
	mod.vb.blastCount = 0
	mod.vb.bombCount = 0
	mod.vb.vacuumCount = 0

	local badStateDetected = false

	local function functionSetAllowedWarning(self)
		DBM.Options.BlizzAPIAllowOnce = true
	end

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			if self:IsTank() then
				specWarnAstralBlast:SetAlert(294, "defensive", 2)
			end
			specWarnPowerVacuum:SetAlert(296, "runout", 2)
		end
		timerArcaneBarrageCD:SetTimeline(293)
		timerAstralBlastCD:SetTimeline(294)
		timerEnergyBombCD:SetTimeline(295)
		timerPowerVacuumCD:SetTimeline(296)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.barrageCount = 1
		self.vb.blastCount = 1
		self.vb.bombCount = 1
		self.vb.vacuumCount = 1
		badStateDetected = false
		self:EnableAlertOptions(374341, 295, "bombyou", 12, 2, 0)
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents(
				"ENCOUNTER_TIMELINE_EVENT_ADDED",
				"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
			)
			--SetTimeline events since user has disabled DBM Bars (so they can still get countdowns in blizzard timeline API instead)
			if DBM.Options.HideDBMBars then
				setFallback(self, true)
			end
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		self:UnregisterShortTermEvents()
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Logic confirmed against DoragosaKill1/DoragosaKill2 M+ pulls.
			if timer == 7 then--Arcane Missiles short segment (exact 7.0) or Astral Blast imminent bar (exact 6.5)
				if timerExact < 6.75 then--Astral Blast (6.5) — imminent bar, fires very soon
					timerAstralBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "blast", "blastCount"))
				else--Arcane Missiles (7.0)
					timerArcaneBarrageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "barrage", "barrageCount"))
				end
			elseif timer == 9 then--Astral Blast opening/post-vacuum CD
				timerAstralBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "blast", "blastCount"))
			elseif timer == 10 then--Arcane Missiles second segment
				timerArcaneBarrageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "barrage", "barrageCount"))
			elseif timer == 12 then--Astral Blast main CD bar
				timerAstralBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "blast", "blastCount"))
			elseif timer == 14 then--Energy Bomb
				timerEnergyBombCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bomb", "bombCount"))
				self:Schedule(timerExact-1.5, functionSetAllowedWarning, self)
			elseif timer == 28 then--Power Vacuum
				timerPowerVacuumCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "vacuum", "vacuumCount"))
			else
				if not DBM.Options.DebugMode then
					badStateDetected = true
					self:ResumeBlizzardAPI()
					self:UnregisterShortTermEvents()
					setFallback(self)
					DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
				else
					DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers|r", nil, nil, nil, true)
				end
			end
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
			if eventInfo.source ~= 0 then return end
			local eventID = eventInfo.id
			local timerExact = eventInfo.duration
			local timer = math.floor(timerExact + 0.5)
			if not badStateDetected then
				timersAll(self, timer, timerExact, eventID)
			end
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			if not eventID or not eventState then return end
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType and eventCount then
					if eventType == "blast" then
						if self:IsTanking("player", "boss1", nil, true) then
							specWarnAstralBlast:Show(eventCount)
							specWarnAstralBlast:Play("defensive")
						end
					elseif eventType == "bomb" then
						warnEnergyBomb:Show(eventCount)
					elseif eventType == "vacuum" then
						specWarnPowerVacuum:Show(eventCount)
						specWarnPowerVacuum:Play("runout")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
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
