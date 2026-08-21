local mod	= DBM:NewMod(2879, "DBM-Party-Midnight", 9, 1322)
local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(231631)
mod:SetEncounterID(3457)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2993)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnSynchonizedVenom			= mod:NewCountAnnounce(1299154, 3)

local specWarnTailScythe			= mod:NewSpecialWarningDefensive(1298949, nil, nil, nil, 1, 2, nil, nil, "defensive")
local specWarnVindictiveOnslaught	= mod:NewSpecialWarningCount(1299940, nil, nil, nil, 2, 15, nil, nil, "frontal")
local specWarnDeathRattle			= mod:NewSpecialWarningCount(1299053, nil, nil, nil, 2, 14, nil, nil, "breakvine")--Verify audio
local specWarnSpitefulHunt			= mod:NewSpecialWarningYou(1300503, nil, nil, nil, 2, 19, nil, nil, "fixateyou")--Change to blizzyou?
local specWarnAssimilation			= mod:NewSpecialWarningSwitchCount(1300686, nil, nil, nil, 1, 2, nil, nil, "targetchange")
local specWarnToxicAtrophy			= mod:NewSpecialWarningInterruptCount(1310547, "HasInterrupt", nil, nil, 1, 2, nil, nil, "kickcast")

local timerSynchonizedVenomCD		= mod:NewCDCountTimer(8, 1299154, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerTailScytheCD				= mod:NewCDCountTimer(8, 1298949, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerVindictiveOnslaughtCD	= mod:NewCDCountTimer(8, 1299940, nil, nil, nil, 3)
local timerDeathRattleCD			= mod:NewCDCountTimer(8, 1299053, nil, nil, nil, 3)
local timerToxicBarrageCD			= mod:NewCDCountTimer(8, 1310357, nil, nil, nil, 5)
local timerToxicAtrophyCD			= mod:NewCDCountTimer(8, 1310547, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--mod:AddAuraSoundOption(470966, true, 470966, 4, 1, "justrun", 2)

local badStateDetected = false
local nextTenIsToxicAtrophy = true
mod.vb.SynchonizedVenomCount = 0
mod.vb.TailScytheCount = 0
mod.vb.VindictiveOnslaughtCount = 0
mod.vb.DeathRattleCount = 0
mod.vb.AssimilationCount = 0
mod.vb.ToxicAtrophyCount = 0
mod.vb.ToxicBarrageCount = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnTailScythe:SetAlert(814, "defensive", 2)
		end
		warnSynchonizedVenom:SetAlert(813, "aesoon", 2, 3)
		specWarnVindictiveOnslaught:SetAlert(815, "frontal", 15, 2)
		specWarnDeathRattle:SetAlert(816, "breakvine", 14, 2)
		specWarnSpitefulHunt:SetAlert(817, "fixateyou", 19, 2, 0)
		specWarnAssimilation:SetAlert(818, "targetchange", 2, 2, 0)
		specWarnToxicAtrophy:SetAlert(939, "kickcast", 2, 2, 0)
	end
	--If user has DBM bars enabled, we only want to register colors to the blizz api so that the blizz bars are also colorized.
	--If user has bars disabled, or we are in a bad state, onlyColor is false and we register countdowns as well.
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerSynchonizedVenomCD:SetTimeline(813, onlyColor)
	timerTailScytheCD:SetTimeline(814, onlyColor)
	timerVindictiveOnslaughtCD:SetTimeline(815, onlyColor)
	timerDeathRattleCD:SetTimeline(816, onlyColor)
	timerToxicBarrageCD:SetTimeline(938, onlyColor)
	timerToxicAtrophyCD:SetTimeline(939, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	badStateDetected = false
	self.vb.SynchonizedVenomCount = 1
	self.vb.TailScytheCount = 1
	self.vb.VindictiveOnslaughtCount = 1
	self.vb.DeathRattleCount = 1
	self.vb.AssimilationCount = 1
	self.vb.ToxicAtrophyCount = 1
	self.vb.ToxicBarrageCount = 1
	nextTenIsToxicAtrophy = true
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
	nextTenIsToxicAtrophy = true
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		--Confirmed against M+ PTR log. After the opener, 10-second events alternate Toxic Atrophy then Synchronized Venom.
		if timer == 1 then
			timerSynchonizedVenomCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "synchonizedVenom", "SynchonizedVenomCount"))
		elseif timer == 7 or timer == 16 then
			timerTailScytheCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "tailScythe", "TailScytheCount"))
		elseif timer == 10 then
			if nextTenIsToxicAtrophy then
				nextTenIsToxicAtrophy = false
				timerToxicAtrophyCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "toxicAtrophy", "ToxicAtrophyCount"))
			else
				nextTenIsToxicAtrophy = true
				timerSynchonizedVenomCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "synchonizedVenom", "SynchonizedVenomCount"))
			end
		elseif timer == 14 or timer == 23 then
			timerToxicBarrageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "toxicBarrage", "ToxicBarrageCount"))
		elseif timer == 25 then
			self:TLCountStart(eventID, "assimilation", "AssimilationCount")
		elseif timer == 30 or timer == 39 then
			timerVindictiveOnslaughtCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "vindictiveOnslaught", "VindictiveOnslaughtCount"))
		elseif timer == 44 or timer == 53 then
			timerDeathRattleCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "deathRattle", "DeathRattleCount"))
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
		local handled = timersAll(self, math.floor(timerExact + 0.5), timerExact, eventID)
		if not handled and not badStateDetected then
			badStateDetected = true
			self:ResumeBlizzardAPI()
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventID or not eventState then return end
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "synchonizedVenom" then
					warnSynchonizedVenom:Show(eventCount)
				elseif eventType == "tailScythe" and self:IsTanking("player", "boss1", nil, true) then
					specWarnTailScythe:Show()
					specWarnTailScythe:Play("defensive")
				elseif eventType == "vindictiveOnslaught" then
					specWarnVindictiveOnslaught:Show(eventCount)
					specWarnVindictiveOnslaught:Play("frontal")
				elseif eventType == "deathRattle" then
					specWarnDeathRattle:Show(eventCount)
					specWarnDeathRattle:Play("breakvine")
				elseif eventType == "assimilation" then
					specWarnAssimilation:Show(eventCount)
					specWarnAssimilation:Play("targetchange")
				elseif eventType == "toxicAtrophy" then
					specWarnToxicAtrophy:Show(L.name, eventCount)
					specWarnToxicAtrophy:Play("kickcast")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
