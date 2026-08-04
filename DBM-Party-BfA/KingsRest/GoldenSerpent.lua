local mod	= DBM:NewMod(2165, "DBM-Party-BfA", 3, 1041)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(135322)
mod:SetEncounterID(2139)
mod:SetZone(1762)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--local warnSpitGold					= mod:NewTargetAnnounce(265773, 2)

	--local specWarnTailThrash			= mod:NewSpecialWarningDefensive(265910, nil, nil, nil, 1, 2, nil, nil, "defensive")
	--local specWarnSpitGold				= mod:NewSpecialWarningMoveAway(265773, nil, nil, nil, 1, 2, nil, nil, "runout")
	--local specWarnLucreCall			= mod:NewSpecialWarningSwitch(265923, nil, nil, nil, 1, 2, nil, nil, "killmob")
	--local specWarnLucreCallTank		= mod:NewSpecialWarningMove(265923, nil, nil, nil, 1, 2, nil, nil, "moveboss")
	--local specWarnSerpentine			= mod:NewSpecialWarningRun(265781, nil, nil, nil, 4, 2, nil, nil, "justrun")
	--local specWarnGTFO					= mod:NewSpecialWarningGTFO(265914, nil, nil, nil, 1, 8, nil, nil, "watchfeet")

	--local timerTailThrashCD			= mod:NewCDCountTimer(0, 265910, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)
	--local timerSpitGoldCD				= mod:NewCDCountTimer(0, 265773, nil, nil, nil, 3)
	--local timerLucreCallCD				= mod:NewCDCountTimer(0, 265923, nil, nil, nil, 3)
	--local timerSerpentineCD			= mod:NewCDCountTimer(0, 265781, nil, nil, nil, 2)

	local badStateDetected = false
	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			--specWarnTailThrash:SetAlert(0, "defensive", 2)
			--specWarnSpitGold:SetAlert(0, "runout", 2)
			--specWarnLucreCall:SetAlert(0, "killmob", 2)
			--specWarnLucreCallTank:SetAlert(0, "moveboss", 2)
			--specWarnSerpentine:SetAlert(0, "justrun", 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		--timerTailThrashCD:SetTimeline(0, onlyColor)
		--timerSpitGoldCD:SetTimeline(0, onlyColor)
		--timerLucreCallCD:SetTimeline(0, onlyColor)
		--timerSerpentineCD:SetTimeline(0, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		badStateDetected = true
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents("ENCOUNTER_TIMELINE_EVENT_ADDED", "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
			setFallback(self, true)
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		self:UnregisterShortTermEvents()
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		--Timeline routing will be added after event durations are verified.
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		--Timeline completion handling will be added with the event routing.
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
