local mod	= DBM:NewMod(2165, "DBM-Party-BfA", 3, 1041)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(135322)
mod:SetEncounterID(2139)
mod:SetZone(1762)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local warnSpitGold					= mod:NewCountAnnounce(265773, 2)--Cast count for use in hardode only

	local specWarnTailThrash			= mod:NewSpecialWarningDefensive(265910, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnSpitGold				= mod:NewSpecialWarningBlizzYou(265773, nil, nil, nil, 1, 2, nil, nil, "runout")
	local specWarnLucreCall				= mod:NewSpecialWarningCount(265923, nil, nil, nil, 1, 2, nil, nil, "killmob")
	local specWarnSerpentine			= mod:NewSpecialWarningCount(1311987, nil, nil, nil, 2, 13, nil, nil, "pushbackincoming")

	local timerTailThrashCD				= mod:NewCDCountTimer(0, 265910, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)
	local timerSpitGoldCD				= mod:NewCDCountTimer(0, 265773, nil, nil, nil, 3)
	local timerLucreCallCD				= mod:NewCDCountTimer(0, 265923, nil, nil, nil, 3)
	local timerSerpentineCD				= mod:NewCDCountTimer(0, 1311987, nil, nil, nil, 2)

	--mod:AddAuraSoundOption(1306736, true, 1306736, 1, 1, "poolyou", 18, 0)--Spit Gold (uses ENCOUNTER_WARNING intercept)
	mod:AddAuraSoundOption(265914, true, 1306736, 1, 2, "watchfeet", 8, 0)--Molten Gold

	mod.vb.tailThrashCount = 0
	mod.vb.spitGoldCount = 0
	mod.vb.lucreCallCount = 0
	mod.vb.serpentineCount = 0
	local badStateDetected = false
	local nextTwentyFiveTimer = 1

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnTailThrash:SetAlert(891, "defensive", 2, 2)
			--specWarnSpitGold:SetAlert(767, "runout", 2, 2, 0)--Use only after confirming. commented for now
			if self:IsTank() then
				specWarnLucreCall:SetAlert(893, "kite", 2)
			else
				specWarnLucreCall:SetAlert(893, "killmob", 2)
			end
			specWarnSerpentine:SetAlert(892, "justrun", 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerTailThrashCD:SetTimeline(891, onlyColor)
		timerSpitGoldCD:SetTimeline(767, onlyColor)
		timerLucreCallCD:SetTimeline(893, onlyColor)
		timerSerpentineCD:SetTimeline(892, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.tailThrashCount = 1
		self.vb.spitGoldCount = 1
		self.vb.lucreCallCount = 1
		self.vb.serpentineCount = 1
		nextTwentyFiveTimer = 1
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents(
				"ENCOUNTER_TIMELINE_EVENT_ADDED",
				"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
			)
			setFallback(self, true)
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
			--Confirmed against the 12.1 M+ PTR pull.
			if timer == 8 then
				timerTailThrashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "tailThrash", "tailThrashCount"))
			elseif timer == 5 then
				timerSpitGoldCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "spitGold", "spitGoldCount"))
			elseif timer == 54 then
				timerLucreCallCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lucreCall", "lucreCallCount"))
			elseif timer == 14 or timer == 28 then
				timerSerpentineCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "serpentine", "serpentineCount"))
			elseif timer == 25 then
				--The repeating 25-second entries are Spit Gold, then Tail Thrash.
				if nextTwentyFiveTimer == 1 then
					timerSpitGoldCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "spitGold", "spitGoldCount"))
				else
					timerTailThrashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "tailThrash", "tailThrashCount"))
				end
				nextTwentyFiveTimer = nextTwentyFiveTimer % 2 + 1
			else
				return
			end
			return true
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
			if eventInfo.source ~= 0 then return end
			local eventID = eventInfo.id
			if C_EncounterTimeline.GetEventState(eventID) ~= 0 then return end
			local timerExact = eventInfo.duration
			if not timersAll(self, math.floor(timerExact + 0.5), timerExact, eventID) and not badStateDetected then
				badStateDetected = true
				self:ResumeBlizzardAPI()
				self:UnregisterShortTermEvents()
				setFallback(self)
				DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
			end
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			if not eventState then return end
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType == "tailThrash" then
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnTailThrash:Show()
						specWarnTailThrash:Play("defensive")
					end
				elseif eventType == "spitGold" and eventCount then
					warnSpitGold:Show(eventCount)
					specWarnSpitGold:Show(eventCount, "runout")
				elseif eventType == "lucreCall" and eventCount then
					specWarnLucreCall:Show(eventCount)
					if self:IsTank() then
						specWarnLucreCall:Play("kite")
					else
						specWarnLucreCall:Play("killmob")
					end
				elseif eventType == "serpentine" and eventCount then
					specWarnSerpentine:Show(eventCount)
					specWarnSerpentine:Play("justrun")
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 265773",
		"SPELL_AURA_REMOVED 265773",
		"SPELL_CAST_START 265773 265923 265781 265910",
		"SPELL_PERIODIC_DAMAGE 265914",
		"SPELL_PERIODIC_MISSED 265914"
	)

	--(ability.id = 265923 or ability.id = 265773 or ability.id = 265781 or ability.id = 265910) and type = "begincast"
	local warnSpitGold					= mod:NewTargetAnnounce(265773, 2)

	local specWarnTailThrash			= mod:NewSpecialWarningDefensive(265910, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnSpitGold				= mod:NewSpecialWarningMoveAway(265773, nil, nil, nil, 1, 2, nil, nil, "runout")
	local yellSpitGold					= mod:NewYell(265773)
	local yellSpitGoldFades				= mod:NewShortFadesYell(265773)
	local specWarnLucreCall				= mod:NewSpecialWarningSwitch(265923, nil, nil, nil, 1, 2, nil, nil, "killmob")--Only non Tank
	local specWarnLucreCallTank			= mod:NewSpecialWarningMove(265923, nil, nil, nil, 1, 2, nil, nil, "moveboss")--Only Tank
	local specWarnSerpentine			= mod:NewSpecialWarningRun(265781, nil, nil, nil, 4, 2, nil, nil, "justrun")
	local specWarnGTFO					= mod:NewSpecialWarningGTFO(265914, nil, nil, nil, 1, 8, nil, nil, "watchfeet")

	local timerTailThrashCD				= mod:NewCDTimer(16.6, 265910, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)
	local timerSpitGoldCD				= mod:NewCDTimer(10.9, 265773, nil, nil, nil, 3)
	local timerLucreCallCD				= mod:NewCDTimer(37.6, 265923, nil, nil, nil, 3)
	local timerSerpentineCD				= mod:NewCDTimer(21.8, 265781, nil, nil, nil, 2)

	function mod:OnCombatStart(delay)
		timerSpitGoldCD:Start(8.3-delay, 1)
		timerSerpentineCD:Start(13.1-delay)
		timerTailThrashCD:Start(16.8-delay)
		timerLucreCallCD:Start(41.2-delay)
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 265773 then
			warnSpitGold:CombinedShow(0.3, args.destName)
			if args:IsPlayer() then
				specWarnSpitGold:Show()
				specWarnSpitGold:Play("runout")
				yellSpitGold:Yell()
				yellSpitGoldFades:Countdown(9)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 265773 then
			if args:IsPlayer() then
				yellSpitGoldFades:Cancel()
			end
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 265773 then
			timerSpitGoldCD:Start(10.9)
		elseif spellId == 265923 then
			if self:IsTank() then
				specWarnLucreCall:Show()
				specWarnLucreCall:Play("killmob")
			else
				specWarnLucreCallTank:Show()
				specWarnLucreCallTank:Play("moveboss")
			end
			timerLucreCallCD:Start()--Probably wrong, didn't get to log this far, but guessed similar to pull on 3x gold rule
			if timerSpitGoldCD:GetRemaining() < 3.6 then
				local elapsed, total = timerSpitGoldCD:GetTime()
				local extend = 3.6 - (total-elapsed)
				DBM:Debug("timerSpitGoldCD extended by: "..extend, 2)
				timerSpitGoldCD:Stop()
				timerSpitGoldCD:Update(elapsed, total+extend)
			end
		elseif spellId == 265781 then
			specWarnSerpentine:Show()
			specWarnSerpentine:Play("justrun")
			timerSerpentineCD:Start(21.9)
		elseif spellId == 265910 then
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnTailThrash:Show()
				specWarnTailThrash:Play("defensive")
			end
			timerTailThrashCD:Start()
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
		if spellId == 265914 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
			specWarnGTFO:Show()
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
end
