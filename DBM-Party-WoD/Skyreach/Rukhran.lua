local mod	= DBM:NewMod(967, "DBM-Party-WoD", 7, 476)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(76143)
mod:SetEncounterID(1700)

mod:RegisterCombat("combat")

--TODO, some actual custom sounds and timer disables when apis added
if DBM:IsPostMidnight() then
	local specWarnSunbreak			= mod:NewSpecialWarningCount(1253510, nil, nil, nil, 1, 2)
	local specWarnBurningClaws		= mod:NewSpecialWarningCount(1253519, "Tank", nil, nil, 2, 2)
	local specWarnSearingQuills		= mod:NewSpecialWarningCount(1253527, nil, nil, nil, 2, 12)

	local timerSunbreakCD			= mod:NewCDCountTimer(20.5, 1253510, nil, nil, nil, 1)
	local timerBurningClawsCD		= mod:NewCDCountTimer(20.5, 1253519, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerSearingQuillsCD		= mod:NewCDCountTimer(20.5, 1253527, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)

	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1253511, true, 1253511, 1, 1, "targetyou", 2)--Burning Pursuit
	mod:AddCustomAlertSoundOption(1253511, true, 2)--Using old object because it has no timer thus no hardcode

	mod.vb.sunbreakCount = 0
	mod.vb.burningClawsCount = 0
	mod.vb.searingQuillsCount = 0
	local badStateDetected = false

	---@param self DBMMod
	local function setFallback(self)
		specWarnSunbreak:SetAlert(305, "mobsoon", 2, 2)
		if self:IsTank() then
			specWarnBurningClaws:SetAlert(306, "defensive", 2, 2)
		end
		specWarnSearingQuills:SetAlert(308, "breaklos", 12, 2)
		self:EnableAlertOptions(1253511, 603, "mobsoon", 2, 2, 0)--Using old object because it has no timer thus no hardcode
		timerSunbreakCD:SetTimeline(305)
		timerBurningClawsCD:SetTimeline(306)
		timerSearingQuillsCD:SetTimeline(308)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.sunbreakCount = 1
		self.vb.burningClawsCount = 1
		self.vb.searingQuillsCount = 1
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
			if timer == 5 then--Burning Claws
				timerBurningClawsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "burningClaws", "burningClawsCount"))
			elseif timer == 21 then--Sunbreak
				timerSunbreakCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "sunbreak", "sunbreakCount"))
			elseif timer == 38 then--Searing Quills
				timerSearingQuillsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "searingQuills", "searingQuillsCount"))
			elseif timer == 12 then--Sunbreak(odd counts) or Burning Claws(even counts)
				local sunbreakExpectsTwelve = self.vb.sunbreakCount % 2 == 1
				local clawsExpectsTwelve = self.vb.burningClawsCount % 2 == 0
				if sunbreakExpectsTwelve then
					timerSunbreakCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "sunbreak", "sunbreakCount"))
				elseif clawsExpectsTwelve then
					timerBurningClawsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "burningClaws", "burningClawsCount"))
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
					if eventType == "sunbreak" then
						specWarnSunbreak:Show(eventCount)
						specWarnSunbreak:Play("mobsoon")
					elseif eventType == "burningClaws" then
						if self:IsTank() then
							specWarnBurningClaws:Show(eventCount)
							specWarnBurningClaws:Play("defensive")
						end
					elseif eventType == "searingQuills" then
						specWarnSearingQuills:Show(eventCount)
						specWarnSearingQuills:Play("breaklos")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_REMOVED 159382",
		"SPELL_CAST_START 153810 153794 159382",
		"RAID_BOSS_WHISPER"
	)

	local warnSolarFlare			= mod:NewSpellAnnounce(153810, 3)

	local specWarnPierceArmor		= mod:NewSpecialWarningDefensive(153794, nil, nil, nil, 1, 2)
	local specWarnFixate			= mod:NewSpecialWarningYou(176544, nil, nil, nil, 1, 2)
	local specWarnQuills			= mod:NewSpecialWarningMoveTo(159382, nil, nil, nil, 2, 13)
	local specWarnQuillsEnd			= mod:NewSpecialWarningEnd(159382, nil, nil, nil, 1, 2)

	local timerSolarFlareCD			= mod:NewCDTimer(17, 153810, nil, nil, nil, 3)
	local timerQuills				= mod:NewBuffActiveTimer(17, 159382, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

	local skyTrashMod = DBM:GetModByName("SkyreachTrash")

	function mod:OnCombatStart(delay)
		timerSolarFlareCD:Start(11-delay)
	--	if self:IsHard() then
			--timerQuillsCD:Start(33-delay)--Needs review
	--	end
		if skyTrashMod and skyTrashMod.Options.RangeFrame and skyTrashMod.vb.debuffCount ~= 0 then--In case of bug where range frame gets stuck open from trash pulls before this boss.
			skyTrashMod.vb.debuffCount = 0--Fix variable
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 159382 then
			specWarnQuillsEnd:Show()
			specWarnQuillsEnd:Play("safenow")
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 153810 then
			warnSolarFlare:Show()
			timerSolarFlareCD:Start()
			warnSolarFlare:Play("mobsoon")
			if self:IsDps() then
				warnSolarFlare:ScheduleVoice(2, "mobkill")
			end
		elseif spellId == 153794 then
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnPierceArmor:Show()
				specWarnPierceArmor:Play("defensive")
			end
		elseif spellId == 159382 then
			specWarnQuills:Show(DBM_COMMON_L.BREAK_LOS)
			specWarnQuills:Play("breaklos")
			timerQuills:Start()
		end
	end

	function mod:RAID_BOSS_WHISPER()
		specWarnFixate:Show()
		specWarnFixate:Play("targetyou")
	end
end
