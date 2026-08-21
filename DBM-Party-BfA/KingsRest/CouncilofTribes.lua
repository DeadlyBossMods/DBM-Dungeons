local mod	= DBM:NewMod(2170, "DBM-Party-BfA", 3, 1041)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(135475, 135470, 135472)
mod:SetEncounterID(2140)
mod:SetUsedIcons(1, 2)
mod:SetBossHPInfoToHighest()
mod:SetZone(1762)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	mod:RegisterSafeEventsInCombat("CHAT_MSG_MONSTER_YELL")
	--Overview:
	--The battle will begin with Kula the Butcher. When a councilor is defeated, they will return to their urn and the next will join the encounter.
	--However, the defeated councilor will periodically rejoin the battle to use a single ability, and then return to their urn.
	--When all three councilors are defeated, the encounter ends.
	--Important signals for routing.
	--1. Previous bosses timeline events canceling and next bosses starting should signal advance to next boss
	--2. Defeated boss now expected to use one special ability with less frequency going forward but they don't fire timeline events
	--3. Boss order is Kula, Aka'ali, Zanazal.
	--4. Barrel Through continues to fire ENCOUNTER_WARNING when Aka'ali is defeated, but the timeline event no longer exists, so NewSpecialWarningBlizzTarget is broken. Therefore, when Aka'ali is defeated specWarnBarrelThrough fires its SetFallback
	--5. Objects are sorted by boss for clear identification of ability ownership.

	--Kula the Butcher
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18261))
	--local warnSeveringAxe				= mod:NewCountAnnounce(266231, 3, nil, "Healer")

	local specWarnWhirlingAxes			= mod:NewSpecialWarningDodgeCount(266206, nil, nil, nil, 2, 2, nil, nil, "watchstep")

	local timerWhirlingAxesCD			= mod:NewCDCountTimer(30, 266206, nil, nil, nil, 3)
	local timerSeveringAxeCD			= mod:NewCDCountTimer(30, 266231, nil, nil, nil, 3)

	mod:AddAuraSoundOption(266231, true, 266231, 1, 3, "bleedyou", 19, 0)--Severing Axe

	--Aka'ali the Conqueror
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18264))
	local specWarnBarrelThrough			= mod:NewSpecialWarningBlizzTarget(267494, nil, nil, nil, 1, 2, nil, nil, "helpsoak")--Caveat, target will get double alerts
	local specWarnDebilitatingBackhand	= mod:NewSpecialWarningRunCount(266237, nil, nil, nil, 4, 2, nil, nil, "justrun")

	local timerBarrelThroughCD			= mod:NewCDCountTimer(30, 267494, nil, nil, nil, 3)
	local timerDebilitatingBackhandCD	= mod:NewCDCountTimer(30, 266237, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)

	mod:AddAuraSoundOption(267494, true, 267494, 1, 1, "lineyou", 17, 0)--Barrel Through

	--Zanazal the Wise
	local Zanazal = DBM:EJ_GetSectionInfo(18267)--Also used for Interrupt warning source name
	mod:AddTimerLine(Zanazal)
	local specWarnPoisonNova				= mod:NewSpecialWarningInterrupt(267273, "HasInterrupt", nil, nil, 1, 2, nil, nil, "kickcast")
	local specWarnTotems					= mod:NewSpecialWarningSwitchCount(267060, nil, nil, nil, 1, 2, nil, nil, "changetarget")

	local timerArcLightningCD				= mod:NewCDCountTimer(30, 1305810, nil, nil, nil, 3)
	local timerPoisonNovaCD					= mod:NewCDCountTimer(30, 267273, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	local timerTotemsCD						= mod:NewCDCountTimer(30, 267060, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)

	mod.vb.whirlingAxesCount = 1
	mod.vb.severingAxeCount = 1
	mod.vb.barrelThroughCount = 1
	mod.vb.debilitatingBackhandCount = 1
	mod.vb.arcLightningCount = 1
	mod.vb.poisonNovaCount = 1
	mod.vb.totemsCount = 1

	local badStateDetected = false
	local stage3BarrelYellArmed = false
	local lastStage3YellTime = 0

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnWhirlingAxes:SetAlert(870, "watchstep", 2)
			specWarnBarrelThrough:SetAlert(872, "helpsoak", 2, 2, 0)
			if self:IsTank() then
				specWarnDebilitatingBackhand:SetAlert(873, "carefly", 2)
			end
			specWarnPoisonNova:SetAlert(875, "kickcast", 2)
			specWarnTotems:SetAlert(876, "changetarget", 2)
		end
		--If user has DBM bars enabled, only register colors with the Blizzard API.
		--If bars are disabled, or the timeline is in a bad state, also register countdowns.
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerWhirlingAxesCD:SetTimeline(870, onlyColor)
		timerSeveringAxeCD:SetTimeline(871, onlyColor)
		timerBarrelThroughCD:SetTimeline(872, onlyColor)
		timerDebilitatingBackhandCD:SetTimeline(873, onlyColor)
		timerArcLightningCD:SetTimeline(874, onlyColor)
		timerPoisonNovaCD:SetTimeline(875, onlyColor)
		timerTotemsCD:SetTimeline(876, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self:SetStage(1)
		self.vb.whirlingAxesCount = 1
		self.vb.severingAxeCount = 1
		self.vb.barrelThroughCount = 1
		self.vb.debilitatingBackhandCount = 1
		self.vb.arcLightningCount = 1
		self.vb.poisonNovaCount = 1
		self.vb.totemsCount = 1
		stage3BarrelYellArmed = false
		lastStage3YellTime = 0
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents(
				"ENCOUNTER_TIMELINE_EVENT_ADDED",
				"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED",
				"ENCOUNTER_WARNING"
			)
			setFallback(self, true)
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		stage3BarrelYellArmed = false
		lastStage3YellTime = 0
		self:UnregisterShortTermEvents()
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			local handled = false
			if timer == 8 or (timer == 15 and timerExact ~= 15) then--Whirling Axes opener and repeat (repeat is 14.75)
				timerWhirlingAxesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "whirlingAxes", "whirlingAxesCount"))
				handled = true
			elseif timerExact == 15 or timer == 17 then--Severing Axe opener and repeat
				timerSeveringAxeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "severingAxe", "severingAxeCount"))
				handled = true
			elseif self:GetStage(2) then
				if timer == 5 or timer == 20 then--Barrel Through opener and repeat
					timerBarrelThroughCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "barrelThrough", "barrelThroughCount"))
					handled = true
				elseif timer == 14 or timer == 22 then--Debilitating Backhand opener and repeat
					timerDebilitatingBackhandCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "debilitatingBackhand", "debilitatingBackhandCount"))
					handled = true
				end
			elseif self:GetStage(3) then
				if timer == 2 or timer == 7 then--Arc Lightning opener and repeat
					timerArcLightningCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "arcLightning", "arcLightningCount"))
					handled = true
				elseif timer == 10 or timer == 24 then--Poison Nova opener and repeat
					--When blizzard sends a timer of 24, it's wrong, it's 23
					timerPoisonNovaCD:TLStart(timer == 24 and 23 or timerExact, eventID, self:TLCountStart(eventID, "poisonNova", "poisonNovaCount"))
					handled = true
				elseif timer == 20 or timer == 53 then--Call of the Elements opener and repeat
					timerTotemsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "totems", "totemsCount"))
					handled = true
				end
			end
			if not handled then
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
					if eventType == "whirlingAxes" then
						specWarnWhirlingAxes:Show(eventCount)
						specWarnWhirlingAxes:Play("watchstep")
					elseif eventType == "barrelThrough" then
						specWarnBarrelThrough:Show(eventCount, "helpsoak")
					elseif eventType == "debilitatingBackhand" then
						if self:IsTank() then--can't disambiguate which boss is which at this time
							specWarnDebilitatingBackhand:Show(eventCount)
							specWarnDebilitatingBackhand:Play("justrun")
						end
					elseif eventType == "poisonNova" then
						specWarnPoisonNova:Show(Zanazal or DBM_COMMON_L.UNKNOWN)
						specWarnPoisonNova:Play("kickcast")
					elseif eventType == "totems" then
						specWarnTotems:Show(eventCount)
						specWarnTotems:Play("changetarget")
					end
				end
			elseif eventState == 3 then
				local eventType = self:TLCountCancel(eventID)
				if self:GetStage(1) and (eventType == "whirlingAxes" or eventType == "severingAxe") then
					self:SetStage(2)
				elseif self:GetStage(2) and (eventType == "barrelThrough" or eventType == "debilitatingBackhand") then
					self:SetStage(3)
					--The yell-to-warning timing is the only non-secret stage-3 Barrel Through signal.
					stage3BarrelYellArmed = true
				end
			end
		end

		function mod:CHAT_MSG_MONSTER_YELL()
			if stage3BarrelYellArmed then
				lastStage3YellTime = GetTime()
				--BlizzTarget expires after strict 0.5 seconds unless the next event is an ENCOUNTER_WARNING.
				specWarnBarrelThrough:Show(self.vb.barrelThroughCount, "helpsoak", 0.5)
			end
		end

		function mod:ENCOUNTER_WARNING()
			if not stage3BarrelYellArmed or lastStage3YellTime == 0 then return end
			local elapsed = GetTime() - lastStage3YellTime
			lastStage3YellTime = 0
			if elapsed <= 0.5 then
				self.vb.barrelThroughCount = self.vb.barrelThroughCount + 1
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 267256 266231",
		"SPELL_AURA_REMOVED 267256 266231",
		"SPELL_CAST_START 266206 266951 266237 267273 267060",
		"SPELL_CAST_SUCCESS 266231",
		"UNIT_DIED",
		"CHAT_MSG_RAID_BOSS_EMOTE",
		"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3",
		"UNIT_TARGETABLE_CHANGED boss1 boss2 boss3"
	)

	--TODO, finish accurate detection of who starts fight, and bosses swapping in and out.
	--TODO, I believe the inactive bosses assisting is health based off the enabled boss, so timers only work for ACTIVE boss.
	--[[
	(ability.id = 266206 or ability.id = 266951 or ability.id = 266237 or ability.id = 267273 or ability.id = 267060) and type = "begincast"
	 or ability.id = 266231 and type = "cast"
	--]]
	--Kula the Butcher
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18261))
	local warnSeveringAxe				= mod:NewTargetNoFilterAnnounce(266231, 3, nil, "Healer")

	local specWarnWhirlingAxes			= mod:NewSpecialWarningDodge(266206, nil, nil, nil, 2, 2, nil, nil, "watchstep")
	local specWarnSeveringAxe			= mod:NewSpecialWarningDefensive(266231, nil, nil, nil, 1, 2, nil, nil, "defensive")

	local timerWhirlingAxesCD			= mod:NewCDTimer(10.8, 266206, nil, nil, nil, 3)--Used inactive
	local timerSeveringAxeCD			= mod:NewCDTimer(21.8, 266231, nil, nil, nil, 3)

	mod:AddSetIconOption("SetIconOnAxe", 266231, false, 0, {2})
	--Aka'ali the Conqueror
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18264))
	local specWarnBarrelThrough			= mod:NewSpecialWarningYou(266951, nil, nil, nil, 1, 2, nil, nil, "targetyou")
	local yellBarrelThrough				= mod:NewYell(266951)
	local yellBarrelThroughFades		= mod:NewShortFadesYell(266951)
	local specWarnBarrelThroughSoak		= mod:NewSpecialWarningMoveTo(266951, nil, nil, nil, 1, 2, nil, nil, "gathershare")
	local specWarnDebilitatingBackhand	= mod:NewSpecialWarningRun(266237, nil, nil, nil, 4, 2, nil, nil, "justrun")

	local timerBarrelThroughCD			= mod:NewCDTimer(23, 266951, nil, nil, nil, 3)--Used inactive
	local timerDebilitatingBackhandCD	= mod:NewCDTimer(22.8, 266237, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)

	mod:AddSetIconOption("SetIconOnBarrel", 266951, true, 0, {1})
	--Zanazal the Wise
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18267))
	local specWarnPoisonNova			= mod:NewSpecialWarningInterrupt(267273, "HasInterrupt", nil, nil, 1, 2, nil, nil, "kickcast")
	local specWarnTotems				= mod:NewSpecialWarningSwitch(267060, nil, nil, nil, 1, 2, nil, nil, "changetarget")
	local specWarnEarthwall				= mod:NewSpecialWarningDispel(267256, "MagicDispeller", nil, nil, 1, 2, nil, nil, "dispelboss")

	local timerPoisonNovaCD				= mod:NewCDTimer(26.7, 267273, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Used inactive
	local timerTotemsCD					= mod:NewCDTimer(53.5, 267060, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--Actual timer needs doing

	mod.vb.bossOne = 0
	mod.vb.bossTwo = 0
	mod.vb.earthTotemActive = false
	mod.vb.bossName = "nil"

	--Engage Timers
	local function whoDat(self, delay)
		for i = 1, 3 do--Might actually only need to check boss 1
			local bossUID = "boss"..i
			if UnitCanAttack("player", bossUID) then
				local cid = self:GetUnitCreatureId(bossUID)
				if cid == 135475 then -- Kula the Butcher
					timerWhirlingAxesCD:Start(6-delay)
					timerSeveringAxeCD:Start(22.2-delay)--SUCCESS
				elseif cid == 135470 then -- Aka'ali the Conqueror
					--timerBarrelThroughCD:Start(1-delay)
					--timerDebilitatingBackhandCD:Start(1-delay)
				elseif cid == 135472 then -- Zanazal the Wise
					timerPoisonNovaCD:Start(8.8-delay)
					timerTotemsCD:Start(23.5-delay)
				end
			end
		end
	end

	function mod:OnCombatStart(delay)
		self:SetStage(1)
		self.vb.bossOne = 0
		self.vb.bossTwo = 0
		self.vb.bossName = "nil"
		self.vb.earthTotemActive = false
		self:Schedule(2, whoDat, self, delay)
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 267256 and not self.vb.earthTotemActive and not args:IsDestTypePlayer() then
			specWarnEarthwall:Show(args.destName)
			specWarnEarthwall:Play("dispelboss")
			self.vb.bossName = args.destName
		elseif spellId == 266231 then
			if args:IsPlayer() then
				specWarnSeveringAxe:Show()
				specWarnSeveringAxe:Play("defensive")
			else
				warnSeveringAxe:Show(args.destName)
			end
			if self.Options.SetIconOnAxe then
				self:SetIcon(args.destName, 2)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 267256  then
			self.vb.bossName = "nil"
		elseif spellId == 266231 then
			if self.Options.SetIconOnAxe then
				self:SetIcon(args.destName, 0)
			end
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 266206 then
			specWarnWhirlingAxes:Show()
			specWarnWhirlingAxes:Play("watchstep")
			local cid = self:GetCIDFromGUID(args.sourceGUID)
			if cid ~= self.vb.bossOne and cid ~= self.vb.bossTwo then
				timerWhirlingAxesCD:Start()
			end
		elseif spellId == 266951 then
			local cid = self:GetCIDFromGUID(args.sourceGUID)
			if cid ~= self.vb.bossOne and cid ~= self.vb.bossTwo then
				timerBarrelThroughCD:Start()
			end
		elseif spellId == 266237 then
			if self:IsTank() then
				specWarnDebilitatingBackhand:Show()
				specWarnDebilitatingBackhand:Play("justrun")
				--specWarnDebilitatingBackhand:ScheduleVoice(3.5, "justrun")
			end
			timerDebilitatingBackhandCD:Start()
		elseif spellId == 267273 then
			if self:CheckInterruptFilter(args.sourceGUID, false, true, true) then
				specWarnPoisonNova:Show(args.sourceName)
				specWarnPoisonNova:Play("kickcast")
			end
			local cid = self:GetCIDFromGUID(args.sourceGUID)
			if cid ~= self.vb.bossOne and cid ~= self.vb.bossTwo then
				timerPoisonNovaCD:Start(26.7)
			end
		elseif spellId == 267060 then
			self.vb.earthTotemActive = true
			specWarnTotems:Show()
			specWarnTotems:Play("changetarget")
			local cid = self:GetCIDFromGUID(args.sourceGUID)
			if cid ~= self.vb.bossOne and cid ~= self.vb.bossTwo then
				timerTotemsCD:Start(53.5)
			end
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 266231 then
			timerSeveringAxeCD:Start(21.8)
		end
	end

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 135759 then--Earth Totem
			self.vb.earthTotemActive = false
			if self.vb.bossName ~= "nil" then
				specWarnEarthwall:Show(self.vb.bossName)
				specWarnEarthwall:Play("dispelboss")
			end
		end
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
		if msg:find("spell:266951") then
			local targetname = DBM:GetUnitFullName(target)
			if targetname then
				if targetname == UnitName("player") then
					specWarnBarrelThrough:Show()
					specWarnBarrelThrough:Play("targetyou")
					yellBarrelThrough:Yell()
					yellBarrelThroughFades:Countdown(8)
				else
					specWarnBarrelThroughSoak:Show(targetname)
					specWarnBarrelThroughSoak:Play("gathershare")
				end
				if self.Options.SetIconOnBarrel then
					self:SetIcon(targetname, 1, 8)
				end
			end
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 34098 and self:AntiSpam(3, uId) then--ClearAllDebuffs (sometimes fires twice, so antispam needed)
			timerWhirlingAxesCD:Stop()
			timerBarrelThroughCD:Stop()
			timerDebilitatingBackhandCD:Stop()
			timerPoisonNovaCD:Stop()
			timerTotemsCD:Stop()
			self:SetStage(0)
			local cid = self:GetUnitCreatureId(uId)
			if self:GetStage(2) then
				self.vb.bossOne = cid
				--Start Boss 1 Timer (17sec)
				if cid == 135475 then -- Kula the Butcher
				--	timerWhirlingAxesCD:Start(17)
				elseif cid == 135470 then -- Aka'ali the Conqueror
				--	timerBarrelThroughCD:Start(17)
				elseif cid == 135472 then -- Zanazal the Wise
				--	timerPoisonNovaCD:Start(17)
				end
			else
				self.vb.bossTwo = cid
			end
		end
	end

	--2nd and 3rd Boss timers
	function mod:UNIT_TARGETABLE_CHANGED(uId)
		if UnitCanAttack("player", uId) then
			local cid = self:GetUnitCreatureId(uId)
			if cid == 135475 then -- Kula the Butcher
				timerWhirlingAxesCD:Start(8)
				timerSeveringAxeCD:Start(22.2)
			elseif cid == 135470 then -- Aka'ali the Conqueror
				timerBarrelThroughCD:Start(6)
				timerDebilitatingBackhandCD:Start(15.7)
			elseif cid == 135472 then -- Zanazal the Wise
				timerPoisonNovaCD:Start(18.1)
				timerTotemsCD:Start(19.2)
			end
		end
	end
end
