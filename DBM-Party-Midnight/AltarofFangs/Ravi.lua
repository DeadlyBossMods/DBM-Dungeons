local mod	= DBM:NewMod(2878, "DBM-Party-Midnight", 9, 1322)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(231631)
mod:SetEncounterID(3456)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2993)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--https://www.wowhead.com/ptr/spell=1296219/fetid-roar isn't in journal but has encounter event
--use https://www.wowhead.com/ptr/spell=1297876/triple-shot for spread debuff/aura sound?
--901 is used for "Fresh Meat" but not sure for what. Announcing it's spawn?
local warnTripleShot				= mod:NewIncomingAnnounce(1296220, 2)

local specWarnSsscavenging			= mod:NewSpecialWarningCount(1309522, nil, nil, nil, 1, 2, nil, nil, "attackshield")
local specWarnFeedingFrenzy			= mod:NewSpecialWarningCount(1307765, nil, nil, nil, 3, 2, nil, nil, "attackshield")--Empowered version of Ssscavenging (from fresh meat)
local specWarnFetidRoar				= mod:NewSpecialWarningCount(1296219, nil, nil, nil, 2, 2, nil, nil, "aesoon")--Possibly not needed
local specWarnRegurgitate			= mod:NewSpecialWarningCount(1296050, nil, nil, nil, 2, 2, nil, nil, "watchwave")
local specWarnRavenousStomp			= mod:NewSpecialWarningCount(1307894, nil, nil, nil, 2, 2, nil, nil, "watchstep")

local timerSsscavengingCD			= mod:NewCDCountTimer(8, 1309522, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerTripleShotCD				= mod:NewCDCountTimer(8, 1296220, nil, nil, nil, 3)
local timerRegurgitateCD			= mod:NewCDCountTimer(8, 1296050, nil, nil, nil, 3)
local timerRavenousStompCD			= mod:NewCDCountTimer(8, 1307894, nil, nil, nil, 3)

--mod:AddAuraSoundOption(470966, true, 470966, 4, 1, "justrun", 2)

local badStateDetected = false
mod.vb.SsscavengingCount = 0
mod.vb.TripleShotCount = 0
mod.vb.RegurgitateCount = 0
mod.vb.RavenousStompCount = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
--		if self:IsTank() then
--			specWarnRampage:SetAlert({210, 556}, "defensive", 2)
--		end
		specWarnSsscavenging:SetAlert(795, "attackshield", 2, 3)
		specWarnFetidRoar:SetAlert(796, "aesoon", 2, 2, 0)
		warnTripleShot:SetAlert(797, "incomingdebuff", 15, 2)
		specWarnRegurgitate:SetAlert(798, "watchwave", 2, 2, 0)
		specWarnRavenousStomp:SetAlert(899, "watchstep", 2, 2, 0)
		specWarnFeedingFrenzy:SetAlert(902, "attackshield", 2, 3, 0)
	end
	--If user has DBM bars enabled, we only want to register colors to the blizz api so that the blizz bars are also colorized.
	--If user has bars disabled, or we are in a bad state, onlyColor is false and we register countdowns as well.
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerSsscavengingCD:SetTimeline(795, onlyColor)
	timerTripleShotCD:SetTimeline(797, onlyColor)
	timerRegurgitateCD:SetTimeline(798, onlyColor)
	timerRavenousStompCD:SetTimeline(899, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	badStateDetected = false
	self.vb.SsscavengingCount = 1
	self.vb.TripleShotCount = 1
	self.vb.RegurgitateCount = 1
	self.vb.RavenousStompCount = 1
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
