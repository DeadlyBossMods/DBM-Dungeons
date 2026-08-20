local mod	= DBM:NewMod(2488, "DBM-Party-Dragonflight", 7, 1202)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(188252)
mod:SetEncounterID(2609)
mod:SetZone(2521)
mod:SetHotfixNoticeRev(20221126000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local specWarnHailburst							= mod:NewSpecialWarningDodge(1307297, nil, nil, nil, 2, 2, nil, nil, "watchstep")
	local specWarnChillStorm						= mod:NewSpecialWarningMoveAway(1307308, nil, nil, nil, 1, 2, nil, nil, "runout")
	--local specWarnFrostOverload						= mod:NewSpecialWarningSwitch(373686, nil, nil, nil, 1, 2, 4, nil, "attackshield")--Seems unused
	local specWarnAwakenWhelps						= mod:NewSpecialWarningCount(373046, "-Healer", nil, nil, 1, 2, nil, nil, "mobsoon")

	local timerChillstormCD							= mod:NewCDCountTimer(30, 1307308, nil, nil, nil, 3)
	local timerHailburstCD							= mod:NewCDCountTimer(30, 1307297, nil, nil, nil, 3)
	--local timerFrostOverloadCD					= mod:NewCDTimer(8.5, 373686, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Cast after each whelps, which is health based

	mod:AddAuraSoundOption(372963, true, 1307308, 1, 2, "watchfeet", 8, 0)--Storm's Eye

	local badStateDetected = false
	local nextTwentyFourIsHailburst = true
	local batchTimerValues = {
		[5] = true,
	}
	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnHailburst:SetAlert(866, "watchstep", 2)
			specWarnChillStorm:SetAlert(867, "runout", 2)
	--		specWarnFrostOverload:SetAlert(868, "attackshield", 2, 2, 0)
			specWarnAwakenWhelps:SetAlert(869, "mobsoon", 2, 3, 0)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerChillstormCD:SetTimeline(867, onlyColor)
		timerHailburstCD:SetTimeline(866, onlyColor)
		--timerFrostOverloadCD:SetTimeline(0, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self:TLBatchReset()
		self.vb.hailburstCount = 1
		self.vb.chillstormCount = 1
		nextTwentyFourIsHailburst = true
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
		self:TLBatchReset()
		self:UnregisterShortTermEvents()
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 or eventInfo.duration == 0 or badStateDetected then return end
		local eventID = eventInfo.id
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if eventState ~= 0 then return end
		local timerExact = eventInfo.duration
		local timer = math.floor(timerExact + 0.5)
		if self:TLBatchTrackLatest(timer, eventID, batchTimerValues) == eventID then return end
		if timer == 5 then
			timerHailburstCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "hailburst", "hailburstCount"))
		elseif timer == 15 then
			timerChillstormCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "chillstorm", "chillstormCount"))
		elseif timer == 24 then
			if nextTwentyFourIsHailburst then
				timerHailburstCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "hailburst", "hailburstCount"))
			else
				timerChillstormCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "chillstorm", "chillstormCount"))
			end
			nextTwentyFourIsHailburst = not nextTwentyFourIsHailburst
		elseif timer == 12 then--Frost Overload cancels the unfinished Hailburst/Chillstorm batch
			self:TLCountReset()
			nextTwentyFourIsHailburst = true
		else
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
		self:TLBatchUntrack(eventID)
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType == "hailburst" and eventCount then
				specWarnHailburst:Show()
				specWarnHailburst:Play("watchstep")
			elseif eventType == "chillstorm" and eventCount then
				specWarnChillStorm:Show()
				specWarnChillStorm:Play("runout")
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 372851 396044 373046",
		"SPELL_AURA_APPLIED 372682 373022 372988 373680 385518",
		"SPELL_AURA_APPLIED_DOSE 372682",
		"SPELL_AURA_REMOVED 372682 372988 373680",
		"SPELL_AURA_REMOVED_DOSE 372682",
		"SPELL_PERIODIC_DAMAGE 372963",
		"SPELL_PERIODIC_MISSED 372963"
	)

	--TODO, target scan Chillstorm if boss looks at victim
	--[[
	(ability.id = 372851 or ability.id = 396044 or ability.id = 373046) and type = "begincast"
	 or ability.id = 373680 and (type = "applybuff" or type = "removebuff")
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	 or ability.id = 385518
	--]]
	local warnFrozenSolid							= mod:NewTargetNoFilterAnnounce(373022, 4, nil, "Healer")
	local warnChillstorm							= mod:NewTargetNoFilterAnnounce(372851, 3)
	local warnIceBulwark							= mod:NewSpellAnnounce(372988, 4)

	local specWarnPrimalChill						= mod:NewSpecialWarningStack(372682, nil, 8, nil, nil, 1, 6, nil, nil, "stackhigh")
	local specWarnHailbombs							= mod:NewSpecialWarningDodge(396044, nil, nil, nil, 2, 2, nil, nil, "watchstep")
	local specWarnChillStorm						= mod:NewSpecialWarningMoveAway(372851, nil, nil, nil, 1, 2, nil, nil, "runout")
	local yellChillstorm							= mod:NewYell(372851)
	local yellChillstormFades						= mod:NewShortFadesYell(372851)
	local specWarnFrostOverload						= mod:NewSpecialWarningInterrupt(373680, "HasInterrupt", nil, 2, 1, 2, 4, nil, "kickcast")
	local specWarnAwakenWhelps						= mod:NewSpecialWarningSwitch(373046, "-Healer", nil, nil, 1, 2, nil, nil, "killmob")
	local specWarnGTFO								= mod:NewSpecialWarningGTFO(372851, nil, nil, nil, 1, 8, nil, nil, "watchfeet")

	local timerChillstormCD							= mod:NewCDTimer(23, 372851, nil, nil, nil, 3)
	local timerHailbombsCD							= mod:NewCDTimer(23, 396044, nil, nil, nil, 3)
	local timerFrostOverloadCD						= mod:NewCDTimer(8.5, 373680, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Cast after each whelps, which is health based

	mod:AddInfoFrameOption(372682, true)

	local chillStacks = {}

	function mod:OnCombatStart(delay)
		table.wipe(chillStacks)
		timerHailbombsCD:Start(4.7-delay)
		timerChillstormCD:Start(11.9-delay)
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(DBM:GetSpellName(372682))
			DBM.InfoFrame:Show(5, "table", chillStacks, 1)
		end
	end

	function mod:OnCombatEnd()
		table.wipe(chillStacks)
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 372851 then
			timerChillstormCD:Start()
		elseif spellId == 396044 then
			specWarnHailbombs:Show()
			specWarnHailbombs:Play("watchstep")
			timerHailbombsCD:Start()
		elseif spellId == 373046 then
			specWarnAwakenWhelps:Show()
			specWarnAwakenWhelps:Play("killmob")
			if self:IsMythic() then
				timerFrostOverloadCD:Start()
			end
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 372682 then
			local amount = args.amount or 1
			chillStacks[args.destName] = amount
			if self.Options.InfoFrame then
				DBM.InfoFrame:UpdateTable(chillStacks, 0.2)
			end
			if args:IsPlayer() and amount >= 8 then
				specWarnPrimalChill:Cancel()--Possible to get multiple applications at once so we throttle by scheduling
				specWarnPrimalChill:Schedule(0.2, amount)
				specWarnPrimalChill:ScheduleVoice(0.2, "stackhigh")
			end
		elseif spellId == 373022 then
			warnFrozenSolid:CombinedShow(1, args.destName)--Slower aggregation to reduce spam
		elseif spellId == 373680 then
			if not self:IsMythic() then--Interruptable at any time on non mythic
				specWarnFrostOverload:Show(args.destName)
				specWarnFrostOverload:Play("kickcast")
			end
			timerHailbombsCD:Stop()
			timerChillstormCD:Stop()
		elseif spellId == 372988 then
			warnIceBulwark:Show()
		elseif spellId == 385518 then
			if args:IsPlayer() then
				specWarnChillStorm:Show()
				specWarnChillStorm:Play("runout")
				yellChillstorm:Yell()
				yellChillstormFades:Countdown(3.5, 2)--Debuff says 1sec but combat log shows 3.5 on M+ at least, not checked lower difficulties since harder to search on WCL
			else
				warnChillstorm:Show(args.destName)
			end
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 372682 then
			chillStacks[args.destName] = nil
			if self.Options.InfoFrame then
				DBM.InfoFrame:UpdateTable(chillStacks, 0.2)
			end
		elseif spellId == 372988 then--Ice Bulwark Removed, now can interrupt on mythic and mythic+
			specWarnFrostOverload:Show(args.destName)
			specWarnFrostOverload:Play("kickcast")
		elseif spellId == 373680 then--Frost Overload
			--True, at least in M+
			timerHailbombsCD:Start(4.1)
			timerChillstormCD:Start(13.3)
		end
	end

	function mod:SPELL_AURA_REMOVED_DOSE(args)
		local spellId = args.spellId
		if spellId == 372682 then
			chillStacks[args.destName] = args.amount or 1
			if self.Options.InfoFrame then
				DBM.InfoFrame:UpdateTable(chillStacks, 0.2)
			end
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 372963 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
end
