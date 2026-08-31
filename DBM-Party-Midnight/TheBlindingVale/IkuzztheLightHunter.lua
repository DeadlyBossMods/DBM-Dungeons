local mod	= DBM:NewMod(2770, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(244887)
mod:SetEncounterID(3200)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

local warnBloodthirstyGaze						= mod:NewCountAnnounce(1237091, 2)

local specWarnVerdantStomp						= mod:NewSpecialWarningCount(1236746, nil, nil, nil, 2, 2, nil, nil, "carefly")
local specWarnThorncallerRoar					= mod:NewSpecialWarningCount(1236709, nil, nil, nil, 2, 2, nil, nil, "watchstep")

local timerVerdantStompCD						= mod:NewCDCountTimer(20.5, 1236746, nil, nil, nil, 2)
local timerThorncallerRoarCD					= mod:NewCDCountTimer(20.5, 1236709, nil, nil, nil, 2)
local timerBloodthirstyGazeCD					= mod:NewCDCountTimer(20.5, 1237091, nil, nil, nil, 1)

--Custom Aura Sounds
mod:AddAuraSoundOption(1237091, true, 1237091, 4, 1, "fixateyou", 19)--Bloodthirsty Gaze
mod:AddAuraSoundOption(1272290, true, 1272290, 1, 1, "stunyou", 19)--Crunched

mod.vb.verdantStompCount = 0
mod.vb.thorncallerRoarCount = 0
mod.vb.bloodthirstyGazeCount = 0
local badStateDetected = false
local pendingVerdantStompEventID

local function startPendingVerdantStomp(self, eventID, timerExact)
	if pendingVerdantStompEventID ~= eventID then return end
	pendingVerdantStompEventID = nil
	timerVerdantStompCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "verdantStomp", "verdantStompCount"))
end

local function cancelPendingVerdantStomp(self)
	pendingVerdantStompEventID = nil
	self:Unschedule(startPendingVerdantStomp)
end

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnVerdantStomp:SetAlert(178, "carefly", 2, 2)
		specWarnThorncallerRoar:SetAlert(179, "watchstep", 2, 2)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerVerdantStompCD:SetTimeline(178, onlyColor)
	timerThorncallerRoarCD:SetTimeline(179, onlyColor)
	timerBloodthirstyGazeCD:SetTimeline(180, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	cancelPendingVerdantStomp(self)
	self.vb.verdantStompCount = 1
	self.vb.thorncallerRoarCount = 1
	self.vb.bloodthirstyGazeCount = 1
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
	cancelPendingVerdantStomp(self)
	self:UnregisterShortTermEvents()
end

do
	local function timersAll(self, timer, timerExact, eventID)
		if timer > 60 then
			return true--Paused placeholder bars
		elseif timer == 6 then
			--At recurring reset, Blizzard sends a false 29-second Stomp immediately before the valid 6-second Stomp.
			--Discard the pending 29 before it can reserve a count or refresh the valid bar.
			cancelPendingVerdantStomp(self)
			timerVerdantStompCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "verdantStomp", "verdantStompCount"))
		elseif timer == 29 then
			--Defer until this dispatch completes: only the reset's false 29 is followed by a 6 in the same batch.
			pendingVerdantStompEventID = eventID
			self:Schedule(0, startPendingVerdantStomp, self, eventID, timerExact)
		elseif timer == 22 then
			timerThorncallerRoarCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "thorncallerRoar", "thorncallerRoarCount"))
		elseif timer == 50 then
			timerBloodthirstyGazeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bloodthirstyGaze", "bloodthirstyGazeCount"))
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
			cancelPendingVerdantStomp(self)
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		if not eventID then return end
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "verdantStomp" then
					specWarnVerdantStomp:Show(eventCount)
					specWarnVerdantStomp:Play("carefly")
				elseif eventType == "thorncallerRoar" then
					specWarnThorncallerRoar:Show(eventCount)
					specWarnThorncallerRoar:Play("watchstep")
				elseif eventType == "bloodthirstyGaze" then
					warnBloodthirstyGaze:Show(eventCount)
				end
			end
		elseif eventState == 1 or eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
