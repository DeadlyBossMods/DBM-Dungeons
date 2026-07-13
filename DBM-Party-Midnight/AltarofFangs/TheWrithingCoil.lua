local mod	= DBM:NewMod(2879, "DBM-Party-Midnight", 9, 1322)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(231631)
mod:SetEncounterID(3457)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2993)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--https://www.wowhead.com/ptr/spell=1310357/preparing-toxin and https://www.wowhead.com/ptr/spell=1310547/toxic-atrophy exists with encounter event but not in journal (938-939)
local warnSynchonizedVenom			= mod:NewCountAnnounce(1299154, 3)

local specWarnTailScythe			= mod:NewSpecialWarningDefensive(1298949, nil, nil, nil, 1, 2, nil, nil, "defensive")
local specWarnVindictiveOnslaught	= mod:NewSpecialWarningCount(1299940, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnDeathRattle			= mod:NewSpecialWarningCount(1299053, nil, nil, nil, 2, 14, nil, nil, "breakvine")--Verify audio
local specWarnSpitefulHunt			= mod:NewSpecialWarningYou(1300503, nil, nil, nil, 2, 19, nil, nil, "fixateyou")--Change to blizzyou?
local specWarnAssimilation			= mod:NewSpecialWarningSwitchCount(1300686, nil, nil, nil, 1, 2, nil, nil, "targetchange")

local timerSynchonizedVenomCD		= mod:NewCDCountTimer(8, 1299154, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerTailScytheCD				= mod:NewCDCountTimer(8, 1298949, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerVindictiveOnslaughtCD	= mod:NewCDCountTimer(8, 1299940, nil, nil, nil, 3)
local timerDeathRattleCD			= mod:NewCDCountTimer(8, 1299053, nil, nil, nil, 3)

--mod:AddAuraSoundOption(470966, true, 470966, 4, 1, "justrun", 2)

local badStateDetected = false
mod.vb.SynchonizedVenomCount = 0
mod.vb.TailScytheCount = 0
mod.vb.VindictiveOnslaughtCount = 0
mod.vb.DeathRattleCount = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnTailScythe:SetAlert(814, "defensive", 2)
		end
		warnSynchonizedVenom:SetAlert(813, "aesoon", 2, 3)
		specWarnVindictiveOnslaught:SetAlert(815, "watchstep", 2, 2)
		specWarnDeathRattle:SetAlert(816, "breakvine", 14, 2)
		specWarnSpitefulHunt:SetAlert(817, "fixateyou", 19, 2, 0)
		specWarnAssimilation:SetAlert(818, "targetchange", 2, 2, 0)
	end
	--If user has DBM bars enabled, we only want to register colors to the blizz api so that the blizz bars are also colorized.
	--If user has bars disabled, or we are in a bad state, onlyColor is false and we register countdowns as well.
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerSynchonizedVenomCD:SetTimeline(813, onlyColor)
	timerTailScytheCD:SetTimeline(814, onlyColor)
	timerVindictiveOnslaughtCD:SetTimeline(815, onlyColor)
	timerDeathRattleCD:SetTimeline(816, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	badStateDetected = false
	self.vb.SynchonizedVenomCount = 1
	self.vb.TailScytheCount = 1
	self.vb.VindictiveOnslaughtCount = 1
	self.vb.DeathRattleCount = 1
	--if DBM.Options.HardcodedTimer and not badStateDetected then
	--	self:IgnoreBlizzardAPI()
	--	self:RegisterShortTermEvents(
	--		"ENCOUNTER_TIMELINE_EVENT_ADDED",
	--		"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
	--	)
	--	setFallback(self, true)
	--else
		setFallback(self)
	--end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	self:UnregisterShortTermEvents()
end

--[[
do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		if timer == 3 or timer == 30 then
	--		timerRampageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "rampage", "rampageCount"))
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
			local finishedEventType, eventCount = self:TLCountFinish(eventID)
			if finishedEventType and eventCount then
				if finishedEventType == "rampage" then
					if self:IsTank() then
--						specWarnRampage:Show(eventCount)
--						specWarnRampage:Play("defensive")
					end
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
--]]
