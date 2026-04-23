local mod	= DBM:NewMod(2655, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231606)
mod:SetEncounterID(3056)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--https://www.wowhead.com/beta/spell=1253907/fire-breath is a private aura but it's hidden but keep an eye on it
--https://www.wowhead.com/beta/spell=470212/flaming-twisters is a private aura but it's impractical to add a sound for
local warnFlamingUpdraft			= mod:NewCountAnnounce(466556, 3)

local specWarnSearingBeak			= mod:NewSpecialWarningCount(466064, nil, nil, nil, 1, 2)
local specWarnBurningGale			= mod:NewSpecialWarningCount(465904, nil, nil, nil, 2, 13)

local timerSearingBeakCD			= mod:NewCDCountTimer(10, 466064, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFlamingUpdraftCD			= mod:NewCDCountTimer(6, 466556, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
local timerBurningGaleCD			= mod:NewCDCountTimer(15, 465904, nil, nil, nil, 2, nil, DBM_COMMON_L.IMPORTANT_ICON)

--TODO, fix private aura GTFO sound defaults if assumption is wrong
mod:AddPrivateAuraSoundOption(466559, true, 466556, 1, 1, "runout", 2)--Flaming Updraft (Currently disabled by blizzard, so hidden from UI automatically by core)
mod:AddPrivateAuraSoundOption(472118, false, 472118, 1, 2, "watchfeet", 8)--Ignited Embers. GTFO that's off by default because under certain conditions you do not want to avoid it

mod.vb.searingBeakCount = 0
mod.vb.flamingUpdraftCount = 0
mod.vb.burningGaleCount = 0

local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnSearingBeak:SetAlert(239, "defensive", 2)
		end
		specWarnBurningGale:SetAlert(242, "pushbackincoming", 13)
	end
	timerSearingBeakCD:SetTimeline(239)
	timerFlamingUpdraftCD:SetTimeline(241)
	timerBurningGaleCD:SetTimeline(242)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.searingBeakCount = 1
	self.vb.flamingUpdraftCount = 1
	self.vb.burningGaleCount = 1
	badStateDetected = false
	if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
		--SetTimeline events since user has disabled DBM Bars (so they can still get countdowns in blizzard timeline API instead)
		if DBM.Options.HideDBMBars then
			setFallback(self, true)
		end
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
		--Logic confirmed against M+ only.
		if timer == 6 then--Flaming Updraft short CD
			timerFlamingUpdraftCD:Stop()--Prevent refreshed before finished debug spam due to blizzard bugs
			timerFlamingUpdraftCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "updraft", "flamingUpdraftCount"))
		elseif timer == 10 then--Searing Beak short CD (opener after reset)
			timerSearingBeakCD:Stop()--Prevent refreshed before finished debug spam due to blizzard bugs
			timerSearingBeakCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "beak", "searingBeakCount"))
		elseif timer == 13 then--Searing Beak steady CD
			timerSearingBeakCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "beak", "searingBeakCount"))
		elseif timer == 15 then--Burning Gale early CD (exact 15.0)
			timerBurningGaleCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "gale", "burningGaleCount"))
		elseif timer == 16 then--Flaming Updraft steady CD (exact 15.5)
			timerFlamingUpdraftCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "updraft", "flamingUpdraftCount"))
		elseif timer == 30 then--Burning Gale transition or steady CD
			timerBurningGaleCD:Stop()--Prevent refreshed before finished debug spam due to blizzard bugs
			timerBurningGaleCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "gale", "burningGaleCount"))
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
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		--Ignore some of bugged events at least. Any paused on start event is bustedd
		--Unfortunately we can't ignore all the other bugged events as easily
		if eventState == 1 then return end
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
				if eventType == "beak" then
					if self:IsTank() then
						specWarnSearingBeak:Show(eventCount)
						specWarnSearingBeak:Play("defensive")
					end
				elseif eventType == "updraft" then
					warnFlamingUpdraft:Show(eventCount)
				elseif eventType == "gale" then
					specWarnBurningGale:Show(eventCount)
					specWarnBurningGale:Play("pushbackincoming")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
