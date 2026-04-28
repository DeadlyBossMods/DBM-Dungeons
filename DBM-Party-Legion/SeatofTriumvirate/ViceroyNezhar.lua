local mod	= DBM:NewMod(1981, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(124874)
mod:SetEncounterID(2067)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--NOTE: Repulse being cast signals a restart of the ability sequence
	local warnMindBlast					= mod:NewCountAnnounce(244750, 2)
	local warnMassVoidInfusion			= mod:NewCountAnnounce(1263542, 2)

	local specWarnUmbralTentacles		= mod:NewSpecialWarningCount(1263538, nil, nil, nil, 1, 2)
	local specWarnRepulse				= mod:NewSpecialWarningCount(1263528, nil, nil, nil, 2, 2)
	local specWarnGatesOfAbyss			= mod:NewSpecialWarningCount(1277358, nil, nil, nil, 2, 2)

	local timerMindBlastCD				= mod:NewCDCountTimer(20.5, 244750, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON..DBM_COMMON_L.TANK_ICON)
	local timerMassVoidCD				= mod:NewCDCountTimer(20.5, 1263542, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
	local timerUmbralTentaclesCD		= mod:NewCDCountTimer(20.5, 1263538, nil, nil, nil, 1)
	local timerRepulseCD				= mod:NewCDCountTimer(20.5, 1263528, nil, nil, nil, 2)
	local timerGatesCD					= mod:NewCDCountTimer(20.5, 1277358, nil, nil, nil, 3)

	mod:AddPrivateAuraSoundOption(1263542, false, 1263542, 1, 1, "debuffyou", 17)--Mass Void Infusion (just minor rot damage, off by default)
	mod:AddPrivateAuraSoundOption(1263532, true, 1263532, 1, 1, "watchfeet", 8)--Void Storm (GTFO)

	mod.vb.mindBlastCount = 0
	mod.vb.massVoidCount = 0
	mod.vb.umbralTentaclesCount = 0
	mod.vb.repulseCount = 0
	mod.vb.gatesCount = 0
	-- Per-cycle counters to disambiguate shared durations; reset on each Repulse
	local d6Cycle = 0  -- dur 6: 1st=GatesOpener, 2nd=MindBlast
	local d12Cycle = 0 -- dur 12: 1st=MassVoidInfusion, 2nd=MindBlast
	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnUmbralTentacles:SetAlert(246, "mobsoon", 1, 2)
			specWarnRepulse:SetAlert(247, "carefly", 2, 2)
			specWarnGatesOfAbyss:SetAlert(376, "watchwave", 2, 2)
		end
		timerMindBlastCD:SetTimeline(244)
		timerMassVoidCD:SetTimeline(245)
		timerUmbralTentaclesCD:SetTimeline(246)
		timerRepulseCD:SetTimeline(247)
		timerGatesCD:SetTimeline(376)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		d6Cycle = 0
		d12Cycle = 0
		self.vb.mindBlastCount = 1
		self.vb.massVoidCount = 1
		self.vb.umbralTentaclesCount = 1
		self.vb.repulseCount = 1
		self.vb.gatesCount = 1
		if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
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
			if timer == 4 or timer == 2 or timer == 14 then--Mind Blast (unambiguous durations)
				timerMindBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "mindblast", "mindBlastCount"))
			elseif timer == 26 then--Umbral Tentacles
				timerUmbralTentaclesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "umbraltentacles", "umbralTentaclesCount"))
			elseif timer == 45 then--Repulse
				timerRepulseCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "repulse", "repulseCount"))
			elseif timer == 18 then--Gates of the Abyss (2nd per cycle)
				timerGatesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "gatesofabyss", "gatesCount"))
			elseif timer == 6 then--Gates of the Abyss opener (1st per cycle) or Mind Blast (6th per cycle)
				d6Cycle = d6Cycle + 1
				if d6Cycle == 1 then
					timerGatesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "gatesofabyss", "gatesCount"))
				else
					timerMindBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "mindblast", "mindBlastCount"))
				end
			elseif timer == 12 then--Mass Void Infusion (1st per cycle) or Mind Blast (3rd per cycle)
				d12Cycle = d12Cycle + 1
				if d12Cycle == 1 then
					timerMassVoidCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "massvoid", "massVoidCount"))
				else
					timerMindBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "mindblast", "mindBlastCount"))
				end
			else
				badStateDetected = true
				self:ResumeBlizzardAPI()
				self:UnregisterShortTermEvents()
				setFallback(self)
				DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
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
					if eventType == "mindblast" then
						warnMindBlast:Show(eventCount)
					elseif eventType == "massvoid" then
						warnMassVoidInfusion:Show(eventCount)
					elseif eventType == "umbraltentacles" then
						specWarnUmbralTentacles:Show(eventCount)
						specWarnUmbralTentacles:Play("mobsoon")
					elseif eventType == "repulse" then
						d6Cycle = 0
						d12Cycle = 0
						specWarnRepulse:Show(eventCount)
						specWarnRepulse:Play("carefly")
					elseif eventType == "gatesofabyss" then
						specWarnGatesOfAbyss:Show(eventCount)
						specWarnGatesOfAbyss:Play("watchwave")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
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
