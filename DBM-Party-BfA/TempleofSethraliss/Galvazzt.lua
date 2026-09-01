local mod	= DBM:NewMod(2144, "DBM-Party-BfA", 6, 1030)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(133389)
mod:SetEncounterID(2126)
mod:SetZone(1877)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	DBM:RegisterAltSpellName(1309525, DBM_COMMON_L.AOEDAMAGE)--Induction --> AoE
	DBM:RegisterAltSpellName(1291618, DBM_COMMON_L.GROUPSOAK .. DBM_COMMON_L.LINES)--Lightning Spire --> Pushback
	local specWarnInduction			= mod:NewSpecialWarningCount(1309525, nil, nil, nil, 2, 2, nil, nil, "aesoon")
	local specWarnLightningSpire	= mod:NewSpecialWarningCount(1291618, nil, nil, nil, 2, 17, nil, nil, "soakbeam")

	local timerInductionCD 			= mod:NewCDCountTimer(22, 1309525, nil, nil, nil, 3)
	local timerLightningSpireCD		= mod:NewCDCountTimer(22, 1291618, nil, nil, nil, 5)

	mod:AddAuraSoundOption(266923, "Tank", 1291618, 1, 3, "lineyou", 17, 0)--Galvanized
	mod:AddAuraSoundOption(1291815, nil, 1309525, 1, 2, "watchfeet", 8, 0)--Induction Field

	mod.vb.inductionCount = 0
	mod.vb.lightningSpireCount = 0
	local badStateDetected = false
	local nextTwentyTwoTimer = 1

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnInduction:SetAlert(697, "aesoon", 2, 2)
			if self:IsTank() then
				specWarnLightningSpire:SetAlert(698, "farfromline", 17, 2)
			else
				specWarnLightningSpire:SetAlert(698, "soakbeam", 17, 2)
			end
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerInductionCD:SetTimeline(697, onlyColor)
		timerLightningSpireCD:SetTimeline(698, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.inductionCount = 1
		self.vb.lightningSpireCount = 1
		nextTwentyTwoTimer = 1
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
			if timer == 20 then
				timerInductionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "induction", "inductionCount"))
			elseif timer == 5 then
				timerLightningSpireCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightningSpire", "lightningSpireCount"))
			elseif timer == 22 then
				--The repeating 22-second entries alternate Lightning Spire then Induction.
				if nextTwentyTwoTimer == 1 then
					timerLightningSpireCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightningSpire", "lightningSpireCount"))
				else
					timerInductionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "induction", "inductionCount"))
				end
				nextTwentyTwoTimer = nextTwentyTwoTimer % 2 + 1
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
			if C_EncounterTimeline.GetEventState(eventID) ~= 0 then return end
			local timerExact = eventInfo.duration
			local timer = math.floor(timerExact + 0.5)
			if not badStateDetected then
				timersAll(self, timer, timerExact, eventID)
			end
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			if not eventState then return end
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType == "induction" and eventCount then
					specWarnInduction:Show(eventCount)
					specWarnInduction:Play("aesoon")
				elseif eventType == "lightningSpire" and eventCount then
					specWarnLightningSpire:Show(eventCount)
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnLightningSpire:Play("farfromline")
					else
						specWarnLightningSpire:Play("soakbeam")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 266511 266923",
		"SPELL_AURA_APPLIED_DOSE 266511 266923",
		"SPELL_CAST_START 266512"
	)

	--TODO, fine tune stacks?
	--TODO, chaotic Spark fixate?
	local warnCapacitance				= mod:NewCountAnnounce(266511, 2)

	local specWarnConsumeCharge			= mod:NewSpecialWarningSpell(266512, nil, nil, nil, 2, 2, nil, nil, "aesoon")
	local specWarnGalvanize				= mod:NewSpecialWarningStack(266923, nil, 5, nil, nil, 1, 6, nil, nil, "stackhigh")

	--local timerReapSoulCD				= mod:NewNextTimer(13, 194956, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)

	mod:AddInfoFrameOption(266923, true)

	function mod:OnCombatStart()
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(DBM_CORE_L.INFOFRAME_POWER)
			DBM.InfoFrame:Show(2, "enemypower", 2, 10)
		end
	end

	function mod:OnCombatEnd()
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 266511 then
			warnCapacitance:Show(args.amount or 1)
		elseif spellId == 266923 and args:IsPlayer() then
			local amount = args.amount or 1
			if (amount >= 5) and self:AntiSpam(3, 1) then
				specWarnGalvanize:Show(amount)
				specWarnGalvanize:Play("stackhigh")
			end
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 266512 then
			specWarnConsumeCharge:Show()
			specWarnConsumeCharge:Play("aesoon")
		end
	end
end
