local mod	= DBM:NewMod(2661, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231863)
mod:SetEncounterID(3072)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnRunicMark						= mod:NewCountAnnounce(1225787, 3)

local specWarnSuppressionZone			= mod:NewSpecialWarningCount(1224903, nil, nil, nil, 2, 2)
local specWarnHasteningWard				= mod:NewSpecialWarningCount(1248689, "MagicDispeller", nil, nil, 1, 2)
local specWarnWaveOfSilence				= mod:NewSpecialWarningCount(1225193, nil, nil, nil, 2, 15)

local timerSuppressionZoneCD			= mod:NewCDCountTimer(20.5, 1224903, nil, nil, nil, 3)
local timerHasteningWardCD				= mod:NewCDCountTimer(20.5, 1248689, nil, nil, nil, 5)
local timerRunicMarkCD					= mod:NewCDCountTimer(20.5, 1225787, nil, nil, nil, 3)
local timerWaveOfSilenceCD				= mod:NewCDCountTimer(20.5, 1225193, nil, nil, nil, 2)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption({1225787,1225792}, true, 1225787, 1, 1, "scatter", 2)--Runic Mark

mod.vb.zoneCount = 0
mod.vb.wardCount = 0
mod.vb.markCount = 0
mod.vb.waveCount = 0
local badStateDetected = false

---@param self DBMMod
local function setFallback(self)
	--Blizz API fallbacks
	specWarnSuppressionZone:SetAlert(93, "watchstep", 2)
	specWarnHasteningWard:SetAlert(94, "dispelboss", 2)
	specWarnWaveOfSilence:SetAlert(96, "findshield", 15)
	timerSuppressionZoneCD:SetTimeline(93)
	timerHasteningWardCD:SetTimeline(94)
	timerRunicMarkCD:SetTimeline({95, 513})
	timerWaveOfSilenceCD:SetTimeline(96)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.zoneCount = 1
	self.vb.wardCount = 1
	self.vb.markCount = 1
	self.vb.waveCount = 1
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
		--Logic confirmed against M+ logs. Cycle opener: Runic Mark(7)/Suppression Zone(17)/Hastening Ward(26)/Wave of Silence(51), then recurring Runic Mark(29). Bars >60 are placeholders always canceled.
		if timer > 80 then return end--Placeholder bars, always canceled
		if timer == 7 or timer == 29 then--Runic Mark (7 = cycle opener, 29 = recurring)
			timerRunicMarkCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "mark", "markCount"))
		elseif timer == 17 then--Suppression Zone
			timerSuppressionZoneCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "zone", "zoneCount"))
		elseif timer == 26 then--Hastening Ward
			timerHasteningWardCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "ward", "wardCount"))
		elseif timer == 51 then--Wave of Silence
			timerWaveOfSilenceCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "wave", "waveCount"))
		else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
			if not DBM.Options.DebugMode then
				badStateDetected = true
				if DBM.Options.IgnoreBlizzAPI then
					DBM.Options.IgnoreBlizzAPI = false
					DBM:FireEvent("DBM_ResumeBlizzAPI")
				end
				self:UnregisterShortTermEvents()
				setFallback(self)
				DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
			else
				DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers|r", nil, nil, nil, true)
			end
		end
	end

	--Note, bar state changing and canceling is handled by core
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
				if eventType == "mark" then
					warnRunicMark:Show(eventCount)
				elseif eventType == "zone" then
					specWarnSuppressionZone:Show(eventCount)
					specWarnSuppressionZone:Play("watchstep")
				elseif eventType == "ward" then
					specWarnHasteningWard:Show(eventCount)
					specWarnHasteningWard:Play("dispelboss")
				elseif eventType == "wave" then
					specWarnWaveOfSilence:Show(eventCount)
					specWarnWaveOfSilence:Play("findshield")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
