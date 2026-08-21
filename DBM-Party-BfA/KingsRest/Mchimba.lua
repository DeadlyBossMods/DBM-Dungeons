local mod	= DBM:NewMod(2171, "DBM-Party-BfA", 3, 1041)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(134993)
mod:SetEncounterID(2142)
mod:SetZone(1762)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local warnDrainFluids				= mod:NewCountAnnounce(267618, 2)--Cast count for use in hardode only
	local warnBurnCorruption			= mod:NewCountAnnounce(267639, 2)--Cast count for use in hardode only

	--local specWarnBurnCorruption		= mod:NewSpecialWarningBlizzYou(1311956, nil, nil, nil, 1, 2, nil, nil, "poolyou")
	local specWarnEntomb				= mod:NewSpecialWarningBlizzTarget(267702, nil, nil, nil, 1, 2, nil, nil, "targetchange")
	local specWarnAwakeningSlam			= mod:NewSpecialWarningCount(1312146, nil, nil, nil, 2, 2, nil, nil, "aesoon")

	local timerBurnCorruptionCD			= mod:NewCDCountTimer(0, 1311956, nil, nil, nil, 3)
	local timerDrainFluidsCD			= mod:NewCDCountTimer(0, 267618, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
	local timerEntombCD					= mod:NewCDCountTimer(0, 267702, nil, nil, nil, 3)
	local timerAwakeningSlamCD			= mod:NewCDCountTimer(0, 1312146, nil, nil, nil, 2)

	mod:AddAuraSoundOption(1311956, true, 1311956, 1, 1, "poolyou", 18, 0)--Burn Corruption (switch to ENCOUNTER_WARNING intercept if confirmed to have one)
	mod:AddAuraSoundOption(267618, true, 267618, 1, 1, "debuffyou", 17, 0)--Drain Fluids

	mod.vb.burnCorruptionCount = 0
	mod.vb.drainFluidsCount = 0
	mod.vb.entombCount = 0
	mod.vb.awakeningSlamCount = 0
	local badStateDetected = false
	local thirtyTimerCycle = {
		"awakeningSlam",
		"burnCorruption",
		"burnCorruption",
	}
	local nextThirtyTimer = 1
	local batchTimerValues = {
		[5] = true,
		[20] = true,
		[30] = true,
		[32] = true,
		[60] = true,
	}

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			--specWarnBurnCorruption:SetAlert(878, "poolyou", 18, 2, 0)
			specWarnEntomb:SetAlert(879, "targetchange", 2, 3, 0)
			specWarnAwakeningSlam:SetAlert(973, "aesoon", 2, 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerBurnCorruptionCD:SetTimeline(878, onlyColor)
		timerDrainFluidsCD:SetTimeline(880, onlyColor)
		timerEntombCD:SetTimeline(879, onlyColor)
		timerAwakeningSlamCD:SetTimeline(973, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self:TLBatchReset()
		self.vb.burnCorruptionCount = 1
		self.vb.drainFluidsCount = 1
		self.vb.entombCount = 1
		self.vb.awakeningSlamCount = 1
		nextThirtyTimer = 1
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
		self:TLBatchReset()
		self:UnregisterShortTermEvents()
	end

	do
		local function resolveThirtyTimer()
			local eventType = thirtyTimerCycle[nextThirtyTimer]
			nextThirtyTimer = nextThirtyTimer % #thirtyTimerCycle + 1
			if eventType == "awakeningSlam" then
				return timerAwakeningSlamCD, eventType, "awakeningSlamCount"
			end
			return timerBurnCorruptionCD, eventType, "burnCorruptionCount"
		end

		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Confirmed against the 12.1 M+ PTR pull.
			--102-second Awakening Slam and 63-second Entomb placeholders pause then cancel instead of completing.
			if timer == 102 or timer == 63 then
				return true
			end
			if timer == 20 then
				self:TLBatchStart(timer, timerBurnCorruptionCD, timerExact, eventID, "burnCorruption", "burnCorruptionCount", batchTimerValues)
			elseif timer == 5 or timer == 32 then
				self:TLBatchStart(timer, timerDrainFluidsCD, timerExact, eventID, "drainFluids", "drainFluidsCount", batchTimerValues)
			elseif timer == 60 then
				self:TLBatchStart(timer, timerEntombCD, timerExact, eventID, "entomb", "entombCount", batchTimerValues)
			elseif timer == 30 then
				--The live 30-second sequence is Awakening Slam, Burn Corruption, Burn Corruption.
				--Resolve after the batch window so canceled duplicates do not advance this cycle.
				self:TLBatchStart(timer, resolveThirtyTimer, timerExact, eventID, "deferred", nil, batchTimerValues)
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
			if not eventID then return end
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			self:TLBatchUntrack(eventID)
			if not eventState then return end
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType == "burnCorruption" and eventCount then
					warnBurnCorruption:Show(eventCount)
				elseif eventType == "drainFluids" and eventCount then
					warnDrainFluids:Show(eventCount)
				elseif eventType == "entomb" and eventCount then
					specWarnEntomb:Show(eventCount, "targetchange")
				elseif eventType == "awakeningSlam" and eventCount then
					specWarnAwakeningSlam:Show(eventCount)
					specWarnAwakeningSlam:Play("aesoon")
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 267618 267702",
		"SPELL_AURA_REMOVED 267702",
		"SPELL_CAST_START 267639 267763 267702",
		"SPELL_CAST_SUCCESS 267618",
		"SPELL_PERIODIC_DAMAGE 267874",
		"SPELL_PERIODIC_MISSED 267874",
		"CHAT_MSG_RAID_BOSS_EMOTE"
	)

	local specWarnBurnCorruption		= mod:NewSpecialWarningRun(267639, "Melee", nil, nil, 4, 2, nil, nil, "justrun")
	local specWarnDrainFluids			= mod:NewSpecialWarningYou(267618, nil, nil, 2, 1, 2, nil, nil, "targetyou")
	local specWarnDrainFluidsTarget		= mod:NewSpecialWarningTarget(267618, "Healer", nil, nil, 1, 2, nil, nil, "healfull")
	local specWarnEntomb				= mod:NewSpecialWarningYou(267702, nil, nil, nil, 1, 2, nil, nil, "targetyou")
	local yellEntomb					= mod:NewYell(267702)
	local specWarnEntombOther			= mod:NewSpecialWarningSwitch(267702, nil, nil, nil, 1, 2, nil, nil, "targetchange")
	local specWarnWretchedDischarge		= mod:NewSpecialWarningInterrupt(267763, "HasInterrupt", nil, nil, 1, 2, nil, nil, "kickcast")
	local specWarnGTFO					= mod:NewSpecialWarningGTFO(267874, nil, nil, nil, 1, 8, nil, nil, "watchfeet")

	local timerBurnCorruptionCD			= mod:NewCDTimer(15.5, 267639, nil, "Melee", nil, 2, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)
	local timerDrainFluidsCD			= mod:NewCDTimer(16.8, 267618, nil, nil, nil, 3)
	local timerEntombCD					= mod:NewCDTimer(60, 267702, nil, nil, nil, 3)


	function mod:OnCombatStart(delay)
		timerBurnCorruptionCD:Start(10.8-delay)
		timerDrainFluidsCD:Start(17.6-delay)--SUCCESS
		timerEntombCD:Start(26.5-delay)
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 267618 then
			if args:IsPlayer() then
				specWarnDrainFluids:Show()
				specWarnDrainFluids:Play("targetyou")
			else
				specWarnDrainFluidsTarget:Show(args.destName)
				specWarnDrainFluidsTarget:Play("healfull")
			end
		elseif spellId == 267702 then
			--Boss stops casting stuff and opens tombs until phase ends
			timerBurnCorruptionCD:Stop()
			timerDrainFluidsCD:Stop()
			timerEntombCD:Stop()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 267702 then
			--Resume normal boss behavior
			timerBurnCorruptionCD:Start(10)
			timerDrainFluidsCD:Start(17)--SUCCESS
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 267639 then
			specWarnBurnCorruption:Show()
			specWarnBurnCorruption:Play("justrun")
			timerBurnCorruptionCD:Start()
		elseif spellId == 267763 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWretchedDischarge:Show(args.sourceName)
			specWarnWretchedDischarge:Play("kickcast")
		elseif spellId == 267702 then
			timerEntombCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 267618 and self:AntiSpam(3, 1) then
			timerDrainFluidsCD:Start()
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
		if spellId == 267874 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
			specWarnGTFO:Show()
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, targetname)
		if msg:find("spell:267702") then
			if targetname and self:AntiSpam(5, targetname) then
				if targetname == UnitName("player") then
					specWarnEntomb:Show()
					specWarnEntomb:Play("targetyou")
					yellEntomb:Yell()
				else
					specWarnEntombOther:Show()
					specWarnEntombOther:Play("targetchange")
				end
			end
		end
	end
end
