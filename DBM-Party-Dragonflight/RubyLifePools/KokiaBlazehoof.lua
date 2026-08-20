local mod	= DBM:NewMod(2485, "DBM-Party-Dragonflight", 7, 1202)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(189232)
mod:SetEncounterID(2606)
mod:SetZone(2521)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--local warnBaitBoulder							= mod:NewBaitAnnounce(372107, 3, nil, nil, nil, nil, 8)--Hardcode later
	--local warnBaitAdd								= mod:NewBaitAnnounce(372863, 3, nil, false, 2, nil, 8)--Hardcode later

	local specWarnSearingBlows						= mod:NewSpecialWarningDefensive(372858, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnMoltenBoulder						= mod:NewSpecialWarningDodgeCount(372110, nil, nil, nil, 1, 15, nil, nil, "frontal")
	local specWarnRitualofBlazebinding				= mod:NewSpecialWarningBlizzTarget(372864, nil, nil, nil, 1, 2, nil, nil, "killmob")
	--local specWarnBurnout							= mod:NewSpecialWarningRun(373087, "Melee", nil, nil, 4, 2, nil, nil, "justrun")

	local timerSearingBlowsCD						= mod:NewCDCountTimer(30, 372858, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.HEALER_ICON)
	local timerMoltenBoulderCD						= mod:NewCDCountTimer(30, 372110, nil, nil, nil, 3)
	local timerRitualofBlazebindingCD				= mod:NewCDCountTimer(30, 372864, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)

	mod:AddAuraSoundOption(372865, true, 372864, 1, 1, "targetyou", 2, 0)--Ritual of Blazebinding
	mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)--Scorched Earth

	local badStateDetected = false
	local nextFortyIsRitual = true
	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			if self:IsTank() then
				specWarnSearingBlows:SetAlert(884, "defensive", 2)
			end
			specWarnMoltenBoulder:SetAlert(883, "frontal", 15)
			specWarnRitualofBlazebinding:SetAlert(882, "killmob", 2)
			--specWarnBurnout:SetAlert(0, "justrun", 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerSearingBlowsCD:SetTimeline(884, onlyColor)
		timerMoltenBoulderCD:SetTimeline(883, onlyColor)
		timerRitualofBlazebindingCD:SetTimeline(882, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.searingCount = 1
		self.vb.boulderCount = 1
		self.vb.ritualCount = 1
		nextFortyIsRitual = true
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
		if eventInfo.source ~= 0 or badStateDetected then return end
		local eventID = eventInfo.id
		local timerExact = eventInfo.duration
		local timer = math.floor(timerExact + 0.5)
		if timer == 8 then
			timerRitualofBlazebindingCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "ritual", "ritualCount"))
		elseif timer == 19 or timer == 20 then
			timerMoltenBoulderCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "boulder", "boulderCount"))
		elseif timer == 28 then
			timerSearingBlowsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "searing", "searingCount"))
		elseif timer == 40 then
			if nextFortyIsRitual then
				timerRitualofBlazebindingCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "ritual", "ritualCount"))
			else
				timerSearingBlowsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "searing", "searingCount"))
			end
			nextFortyIsRitual = not nextFortyIsRitual
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
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType == "searing" and eventCount then
				if self:IsTanking("player", "boss1", nil, true) then
					specWarnSearingBlows:Show()
					specWarnSearingBlows:Play("defensive")
				end
			elseif eventType == "boulder" and eventCount then
				specWarnMoltenBoulder:Show(eventCount)
				specWarnMoltenBoulder:Play("frontal")
			elseif eventType == "ritual" and eventCount then
				specWarnRitualofBlazebinding:Show(eventCount, "killmob")
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 372107 372863 373017 373087 384823",
		"SPELL_CAST_SUCCESS 372858",
		"SPELL_AURA_APPLIED 372858",
	--	"SPELL_AURA_REMOVED"
		"SPELL_PERIODIC_DAMAGE 372820",
		"SPELL_PERIODIC_MISSED 372820",
		"UNIT_DIED"
	--	"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, track https://www.wowhead.com/beta/spell=372860/searing-wounds stacks? there isn't a tank swap so it feels like something that naturally falls off somehow
	--TODO, verify Molten Boulder target scan
	--[[
	(ability.id = 372107 or ability.id = 372863) and type = "begincast"
	 or ability.id = 372858 and type = "cast"
	 or (ability.id = 373017 or ability.id = 373087) and type = "begincast"
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	local warnBurnout								= mod:NewCastAnnounce(373087, 4)
	local warnInferno								= mod:NewCastAnnounce(384823, 3)
	local warnBaitBoulder							= mod:NewBaitAnnounce(372107, 3, nil, nil, nil, nil, 8)
	local warnBaitAdd								= mod:NewBaitAnnounce(372863, 3, nil, false, 2, nil, 8)

	local specWarnSearingBlows						= mod:NewSpecialWarningDefensive(372858, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnMoltenBoulder						= mod:NewSpecialWarningDodgeCount(372107, nil, nil, nil, 1, 2, nil, nil, "shockwave")
	local yellMoltenBoulder							= mod:NewYell(372107)
	local specWarnRitualofBlazebinding				= mod:NewSpecialWarningSwitchCount(372863, nil, nil, nil, 1, 2, nil, nil, "killmob")
	local specWarnRoaringBlaze						= mod:NewSpecialWarningInterruptCount(373017, "HasInterrupt", nil, 2, 1, 2, nil, nil, "kick2r")
	local specWarnBurnout							= mod:NewSpecialWarningRun(373087, "Melee", nil, nil, 4, 2, nil, nil, "justrun")
	local specWarnGTFO								= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8, nil, nil, "watchfeet")

	local timerSearingBlowsCD						= mod:NewCDTimer(32.7, 372858, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.HEALER_ICON)
	local timerMoltenBoulderCD						= mod:NewCDCountTimer(16.9, 372107, nil, nil, nil, 3)
	local timerRitualofBlazebindingCD				= mod:NewCDCountTimer(33.9, 372863, nil, nil, nil, 1)

	local castsPerGUID = {}

	mod.vb.ritualCount = 0
	mod.vb.boulderCount = 0
	mod.vb.addsAlive = 0

	function mod:BoulderTarget(targetname)
		if not targetname then return end
		if targetname == UnitName("player") then
			yellMoltenBoulder:Yell()
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.ritualCount = 0
		self.vb.boulderCount = 0
		self.vb.addsAlive = 0
		table.wipe(castsPerGUID)
		timerRitualofBlazebindingCD:Start(6.9-delay, 1)
		timerMoltenBoulderCD:Start(14.2-delay, 1)
		timerSearingBlowsCD:Start(21.4-delay)
	end

	function mod:OnCombatEnd()
		table.wipe(castsPerGUID)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 372107 then
			self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "BoulderTarget", 0.1, 8, true)
			self.vb.boulderCount = self.vb.boulderCount + 1
			specWarnMoltenBoulder:Show(self.vb.boulderCount)
			specWarnMoltenBoulder:Play("shockwave")
			timerMoltenBoulderCD:Start(nil, self.vb.boulderCount+1)
			warnBaitBoulder:ScheduleVoice(13.4, "bait")--3.5 seconds before
		elseif spellId == 372863 then
			self.vb.ritualCount = self.vb.ritualCount + 1
			specWarnRitualofBlazebinding:Show(self.vb.ritualCount)
			specWarnRitualofBlazebinding:Play("killmob")
			timerRitualofBlazebindingCD:Start(nil, self.vb.ritualCount+1)
			warnBaitAdd:ScheduleVoice(29.2, "bait")--3.5 seconds before
		elseif spellId == 373017 then
			if not castsPerGUID[args.sourceGUID] then
				castsPerGUID[args.sourceGUID] = 0
				self.vb.addsAlive = self.vb.addsAlive + 1
			end
			castsPerGUID[args.sourceGUID] = castsPerGUID[args.sourceGUID] + 1
			local count = castsPerGUID[args.sourceGUID]
			--Scope it to only target/focus if more than 1 add is up else no scoping
			if self.vb.addsAlive <= 1 or self:CheckInterruptFilter(args.sourceGUID, false, false) then
				specWarnRoaringBlaze:Show(args.sourceName, count)
				if count == 1 then
					specWarnRoaringBlaze:Play("kick1r")
				elseif count == 2 then
					specWarnRoaringBlaze:Play("kick2r")
				elseif count == 3 then
					specWarnRoaringBlaze:Play("kick3r")
				elseif count == 4 then
					specWarnRoaringBlaze:Play("kick4r")
				elseif count == 5 then
					specWarnRoaringBlaze:Play("kick5r")
				else
					specWarnRoaringBlaze:Play("kickcast")
				end
			end
		elseif spellId == 373087 then
			if self.Options.SpecWarn373087run then
				specWarnBurnout:Show()
				specWarnBurnout:Play("justrun")
			else
				warnBurnout:Show()
			end
		elseif spellId == 384823 then
			warnInferno:Show()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 372858 then
			timerSearingBlowsCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 372858 then
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnSearingBlows:Show()
				specWarnSearingBlows:Play("defensive")
			end
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 189886 then--Blazebound Firestorm
			if self.vb.addsAlive > 0 then
				self.vb.addsAlive = self.vb.addsAlive - 1
			end
		end
	end
end
