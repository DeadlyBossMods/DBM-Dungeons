local mod	= DBM:NewMod(2814, "DBM-Party-Midnight", 8, 1316)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(254227)
mod:SetEncounterID(3332)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2915)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnEclipsingStep				= mod:NewCountAnnounce(1249020, 2)

local specWarnLightscareFlare		= mod:NewSpecialWarningCount(1264439, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnUmbralLash			= mod:NewSpecialWarningCount(1247937, "Tank", nil, nil, 1, 2, nil, nil, "carefly")
local specWarnNullVanguard			= mod:NewSpecialWarningCount(1252703, nil, nil, nil, 1, 2, nil, nil, "mobsoon")
local specWarnDevourTheUnworthy		= mod:NewSpecialWarningCount(1271684, nil, nil, nil, 2, 2, nil, nil, "aesoon")
local specWarnEclipsingStep			= mod:NewSpecialWarningBlizzYou(1249020, nil, nil, nil, 1, 2, nil, nil, "scatter")

local timerEclipsingStepCD			= mod:NewCDCountTimer(18, 1249020, nil, nil, nil, 3)
local timerLightscareFlareCD		= mod:NewCDCountTimer(61, 1264439, nil, nil, nil, 5)
local timerUmbralLashCD				= mod:NewCDCountTimer(17, 1247937, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerNullVanguardCD			= mod:NewCDCountTimer(61, 1252703, nil, nil, nil, 1, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerDevourTheUnworthyCD		= mod:NewCDCountTimer(15, 1271684, nil, nil, nil, 2)

--Private Auras
--mod:AddPrivateAuraSoundOption(1249020, true, 1249020, 1, 1, "scatter", 2)--Eclipsing Step
mod:AddPrivateAuraSoundOption(1282678, true, 1282678, 1, 1, "justrun", 2)--Flailstorm

mod.vb.eclipsingStepCount = 0
mod.vb.lightscareFlareCount = 0
mod.vb.umbralLashCount = 0
mod.vb.nullVanguardCount = 0
mod.vb.devourTheUnworthyCount = 0

local badStateDetected = false
local sixtyOneTimerCount = 0
local activeEventTypes = {}
local pendingStage2Devour = false
local cancelBurstStart = 0
local cancelBurstCount = 0
local cancelBurstExpected = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnLightscareFlare:SetAlert(34, "watchstep", 2)
		if self:IsTank() then
			specWarnUmbralLash:SetAlert(35, "carefly", 2)
		end
		specWarnNullVanguard:SetAlert(36, "mobsoon", 2)
		specWarnDevourTheUnworthy:SetAlert(37, "aesoon", 2)
	end
	--If user has DBM bars enabled, we only want to register colors to the blizz api so that the blizz bars are also colorized.
	--If user has bars disabled, or we are in a bad state, onlyColor is false and we register countdowns as well.
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerEclipsingStepCD:SetTimeline(33, onlyColor)
	timerLightscareFlareCD:SetTimeline(34, onlyColor)
	timerUmbralLashCD:SetTimeline(35, onlyColor)
	timerNullVanguardCD:SetTimeline(36, onlyColor)
	timerDevourTheUnworthyCD:SetTimeline(37, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self:SetStage(1)
	self.vb.eclipsingStepCount = 1
	self.vb.lightscareFlareCount = 1
	self.vb.umbralLashCount = 1
	self.vb.nullVanguardCount = 1
	self.vb.devourTheUnworthyCount = 1
	sixtyOneTimerCount = 0
	activeEventTypes = {}
	pendingStage2Devour = false
	cancelBurstStart = 0
	cancelBurstCount = 0
	cancelBurstExpected = 0
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
	activeEventTypes = {}
	pendingStage2Devour = false
	cancelBurstStart = 0
	cancelBurstCount = 0
	cancelBurstExpected = 0
	self:UnregisterShortTermEvents()
end

do
	---@return number
	local function getActiveEventCount()
		local count = 0
		for _ in pairs(activeEventTypes) do
			count = count + 1
		end
		return count
	end

	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		local handled = false
		if timer > 80 then
			return
		elseif timer == 3 or timer == 17 then--Umbral Lash
			timerUmbralLashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "umbralLash", "umbralLashCount"))
			activeEventTypes[eventID] = "umbralLash"
			handled = true
		elseif timer == 5 or timer == 18 then--Eclipsing Step
			timerEclipsingStepCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "eclipsingStep", "eclipsingStepCount"))
			activeEventTypes[eventID] = "eclipsingStep"
			handled = true
		elseif timer == 28 then--Lightscare Flare opener
			timerLightscareFlareCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightscareFlare", "lightscareFlareCount"))
			activeEventTypes[eventID] = "lightscareFlare"
			handled = true
		elseif timer == 61 then--Null Vanguard and Lightscare Flare share 61s slots, observed alternating by occurrence
			sixtyOneTimerCount = sixtyOneTimerCount + 1
			if sixtyOneTimerCount % 2 == 1 then
				timerNullVanguardCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "nullVanguard", "nullVanguardCount"))
				activeEventTypes[eventID] = "nullVanguard"
			else
				timerLightscareFlareCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightscareFlare", "lightscareFlareCount"))
				activeEventTypes[eventID] = "lightscareFlare"
			end
			handled = true
		elseif timer == 15 then--Stage-change marker: after a full cancel burst, next 15s becomes Devour the Unworthy
			if pendingStage2Devour then
				timerDevourTheUnworthyCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "devourTheUnworthy", "devourTheUnworthyCount"))
				activeEventTypes[eventID] = "devourTheUnworthy"
				pendingStage2Devour = false
			else
				timerNullVanguardCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "nullVanguard", "nullVanguardCount"))
				activeEventTypes[eventID] = "nullVanguard"
			end
			handled = true
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
		if C_EncounterTimeline.GetEventState(eventID) == 1 then return end--Paused bars are transient and canceled later
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
			activeEventTypes[eventID] = nil
			if eventType and eventCount then
				if eventType == "eclipsingStep" then
					warnEclipsingStep:Show(eventCount)
					specWarnEclipsingStep:Show(eventCount, "scatter")
				elseif eventType == "lightscareFlare" then
					specWarnLightscareFlare:Show(eventCount)
					specWarnLightscareFlare:Play("watchstep")
				elseif eventType == "umbralLash" then
					if self:IsTank() then
						specWarnUmbralLash:Show(eventCount)
						specWarnUmbralLash:Play("carefly")
					end
				elseif eventType == "nullVanguard" then
					specWarnNullVanguard:Show(eventCount)
					specWarnNullVanguard:Play("mobsoon")
				elseif eventType == "devourTheUnworthy" then
					specWarnDevourTheUnworthy:Show(eventCount)
					specWarnDevourTheUnworthy:Play("aesoon")
					if self:GetStage(2) then
						self:SetStage(1)
					end
				end
			end
		elseif eventState == 3 then
			local now = GetTime()
			if (now - cancelBurstStart) <= 0.35 then
				cancelBurstCount = cancelBurstCount + 1
			else
				cancelBurstStart = now
				cancelBurstCount = 1
				cancelBurstExpected = getActiveEventCount()
			end
			self:TLCountCancel(eventID)
			activeEventTypes[eventID] = nil
			if cancelBurstExpected >= 4 and cancelBurstCount >= cancelBurstExpected then
				pendingStage2Devour = true
				if not self:GetStage(2) then
					self:SetStage(2)
				end
			end
		end
	end
end
