local mod	= DBM:NewMod(2495, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(191736)
mod:SetEncounterID(2564)
mod:SetHotfixNoticeRev(20221127000000)
mod:SetZone(2526)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--Play Ball uses ENCOUNTER_WARNING with no stable timeline event in tested pulls
	mod:AddCustomAlertSoundOption(377182, true, 2)--Play Ball
	--Midnight private aura replacements
--	mod:AddPrivateAuraSoundOption(433740, true, 433740, 1)

	local specWarnSavagePeck					= mod:NewSpecialWarningCount(376997, nil, nil, nil, 1, 2)
	local specWarnDeafeningScreech				= mod:NewSpecialWarningCount(377004, nil, nil, nil, 2, 2)
	local specWarnOverpoweringGust				= mod:NewSpecialWarningCount(377034, nil, nil, nil, 2, 15)

	local timerSavagePeckCD						= mod:NewCDCountTimer(13.6, 376997, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerDeafeningScreechCD				= mod:NewCDCountTimer(22.7, 377004, nil, nil, nil, 2)
	local timerOverpoweringGustCD				= mod:NewCDCountTimer(28.2, 377034, nil, nil, nil, 3)

	mod.vb.peckCount = 0
	mod.vb.screechCount = 0
	mod.vb.gustCount = 0

	local badStateDetected = false

	---@param self DBMMod
	local function setFallback(self)
		if self:IsTank() then
			specWarnSavagePeck:SetAlert(278, "defensive", 2)
		end
		specWarnDeafeningScreech:SetAlert(279, self:IsSpellCaster() and "stopcast" or "aesoon", 2)
		specWarnOverpoweringGust:SetAlert(280, "frontal", 15)
		timerSavagePeckCD:SetTimeline(278)
		timerDeafeningScreechCD:SetTimeline(279)
		timerOverpoweringGustCD:SetTimeline(280)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.peckCount = 1
		self.vb.screechCount = 1
		self.vb.gustCount = 1
		badStateDetected = false
		self:EnableAlertOptions(377182, 397, "phasechange", 2, 2, 0)
		if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents(
				"ENCOUNTER_TIMELINE_EVENT_ADDED",
				"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
			)
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
			--Logic confirmed against CrawthKill1/CrawthKill2 M+ pulls.
			if timer == 5 then--Savage Peck
				timerSavagePeckCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "peck", "peckCount"))
			elseif timer == 14 then--Deafening Screech
				timerDeafeningScreechCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "screech", "screechCount"))
			elseif timer == 20 then--Overpowering Gust
				timerOverpoweringGustCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "gust", "gustCount"))
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
					if eventType == "peck" then
						if self:IsTanking("player", "boss1", nil, true) then
							specWarnSavagePeck:Show(eventCount)
							specWarnSavagePeck:Play("defensive")
						end
					elseif eventType == "screech" then
						specWarnDeafeningScreech:Show(eventCount)
						if self:IsSpellCaster() then
							specWarnDeafeningScreech:Play("stopcast")
							specWarnDeafeningScreech:ScheduleVoice(1, "scatter")
						else
							specWarnDeafeningScreech:Play("scatter")
						end
					elseif eventType == "gust" then
						specWarnOverpoweringGust:Show(eventCount)
						specWarnOverpoweringGust:Play("frontal")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 377034 377004 376997",
		"SPELL_CAST_SUCCESS 376781",
		"SPELL_AURA_APPLIED 376781 181089",
		"SPELL_AURA_REMOVED 376781"
	)

	--Gale force not in combat log
	--TODO, verify target scan
	--[[
	(ability.id = 377034 or ability.id = 377004 or ability.id = 376997) and type = "begincast"
	 or ability.id = 376781
	 or ability.id = 181089
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	local warnPlayBall								= mod:NewSpellAnnounce(377182, 2, nil, nil, nil, nil, nil, 2)

	local specWarnFirestorm							= mod:NewSpecialWarningDodge(376448, nil, nil, nil, 2, 2)
	local specWarnOverpoweringGust					= mod:NewSpecialWarningDodge(377034, nil, nil, nil, 2, 2)
	local yellOverpoweringGust						= mod:NewYell(377034)
	local specWarnDeafeningScreech					= mod:NewSpecialWarningMoveAwayCount(377004, nil, nil, nil, 2, 2)
	local specWarnSavagePeck						= mod:NewSpecialWarningDefensive(376997, nil, nil, nil, 1, 2)

	local timerFirestorm							= mod:NewBuffActiveTimer(12, 376448, nil, nil, nil, 1)
	local timerOverpoweringGustCD					= mod:NewCDTimer(28.2, 377034, nil, nil, nil, 3)
	local timerDeafeningScreechCD					= mod:NewCDCountTimer(22.7, 377004, nil, nil, nil, 3)
	local timerSavagePeckCD							= mod:NewCDTimer(13.6, 376997, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Spell queued intoo oblivion often

	mod.vb.ScreechCount = 0

	function mod:GustTarget(targetname)
		if not targetname then return end
		if targetname == UnitName("player") then
			yellOverpoweringGust:Yell()
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.ScreechCount = 0
		timerSavagePeckCD:Start(3.6-delay)
		timerDeafeningScreechCD:Start(5.4-delay, 1)
		timerOverpoweringGustCD:Start(15.7-delay)
	end

	function mod:OnCombatEnd()
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 377034 then
			self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "GustTarget", 0.1, 8, true)
			specWarnOverpoweringGust:Show()
			specWarnOverpoweringGust:Play("shockwave")
			timerOverpoweringGustCD:Start()
		elseif spellId == 377004 then
			self.vb.ScreechCount = self.vb.ScreechCount + 1
			specWarnDeafeningScreech:Show(self.vb.ScreechCount)
			if self:IsSpellCaster() then
				specWarnDeafeningScreech:Play("stopcast")
				specWarnDeafeningScreech:ScheduleVoice(1, "scatter")
			else
				specWarnDeafeningScreech:Play("scatter")
			end
			timerDeafeningScreechCD:Start(nil, self.vb.ScreechCount+1)
		elseif spellId == 376997 then
			timerSavagePeckCD:Start()
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnSavagePeck:Show()
				specWarnSavagePeck:Play("defensive")
			end
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 376781 then
			specWarnFirestorm:Show()
			specWarnFirestorm:Play("watchstep")
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 376781 then
			timerFirestorm:Start()
			--Regardless of time remaining, crawth will cast these coming out of stun
			--Season 4 seems to have swapped these? or spell queue is now happening and either can be cast at 12?
			timerDeafeningScreechCD:Stop()
			timerDeafeningScreechCD:Start(12, 1)
			timerOverpoweringGustCD:Stop()
			timerOverpoweringGustCD:Start(12)--Screech and gust can swap, whatever one is 12 the other is ~17
			timerSavagePeckCD:Stop()--24.6, This one probably restarts too but also gets wierd spell queue and MIGHT not happen
		elseif spellId == 181089 then
			if args:GetDestCreatureID() == 191736 then--Crawth getting buff is play ball starting
				warnPlayBall:Show()
				warnPlayBall:Play("phasechange")
			else--if it's not Crawth, then it's goals activating
				--Swap timer back to same timer with a new count
				local elapsed, total = timerDeafeningScreechCD:GetTime(self.vb.ScreechCount+1)
				if total and total ~= 0 then
					timerDeafeningScreechCD:Stop()--Stop old one
					timerDeafeningScreechCD:Update(elapsed, total, self.vb.ScreechCount+1)--Generate new one with update
				end
				self.vb.ScreechCount = 0
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 376781 then
			timerFirestorm:Stop()
		end
	end
end
