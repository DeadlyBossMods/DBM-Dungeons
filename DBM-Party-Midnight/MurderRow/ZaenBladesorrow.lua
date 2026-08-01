local mod	= DBM:NewMod(2680, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234649)
mod:SetEncounterID(3102)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

local specWarnSameDayDelivery				= mod:NewSpecialWarningCount(474765, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnKillingSpree					= mod:NewSpecialWarningCount(474478, nil, nil, nil, 2, 2, nil, nil, "aesoon")
local specWarnEnvenom						= mod:NewSpecialWarningCount(1222795, "Tank", nil, nil, 2, 3, nil, nil, "defensive")
local specWarnMurderinaRow					= mod:NewSpecialWarningCount(1218347, nil, nil, nil, 2, 4, nil, nil, "breaklos")
local specWarnFireBomb						= mod:NewSpecialWarningBlizzYou(1214357, nil, nil, nil, 2, 12, nil, nil, "bombyou")

local timerFireBombCD						= mod:NewCDCountTimer(20.5, 1214357, nil, nil, nil, 3)
local timerSameDayDeliveryCD				= mod:NewCDCountTimer(20.5, 474765, nil, nil, nil, 3)
local timerMurderinaRowCD					= mod:NewCDCountTimer(20.5, 1218347, nil, nil, nil, 2)
local timerKillingSpreeCD					= mod:NewCDCountTimer(20.5, 474478, nil, nil, nil, 2)
local timerEnvenomCD						= mod:NewCDCountTimer(20.5, 1222795, nil, nil, nil, 5)

----Custom Aura Sounds
mod:AddAuraSoundOption(474545, true, 474545, 1, 1)--Murder in a Row
--mod:AddAuraSoundOption(1214352, true, 1214352, 1, 1, "bombyou", 12)--Fire Bomb (ENCOUNTER_WARNING intercept is used instead)

mod.vb.sameDayDeliveryCount = 0
mod.vb.killingSpreeCount = 0
mod.vb.envenomCount = 0
mod.vb.murderinaRowCount = 0
mod.vb.fireBombCount = 0
local badStateDetected = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnSameDayDelivery:SetAlert(124, "watchstep", 2, 2)
		specWarnKillingSpree:SetAlert(127, "aesoon", 2, 2)
		if self:IsTank() then
			specWarnEnvenom:SetAlert(193, "defensive", 2, 3)
		end
		specWarnMurderinaRow:SetAlert(125, "breaklos", 2, 4)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerFireBombCD:SetTimeline(123, onlyColor)
	timerSameDayDeliveryCD:SetTimeline(124, onlyColor)
	timerMurderinaRowCD:SetTimeline(125, onlyColor)
	timerKillingSpreeCD:SetTimeline(127, onlyColor)
	timerEnvenomCD:SetTimeline(193, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.sameDayDeliveryCount = 1
	self.vb.killingSpreeCount = 1
	self.vb.envenomCount = 1
	self.vb.murderinaRowCount = 1
	self.vb.fireBombCount = 1
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
	local function timersAll(self, timer, timerExact, eventID)
		if timer == 8 then
			timerKillingSpreeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "killingSpree", "killingSpreeCount"))
		elseif timer == 12 or timer == 16 then
			timerSameDayDeliveryCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "sameDayDelivery", "sameDayDeliveryCount"))
		elseif timer == 18 then
			timerFireBombCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fireBomb", "fireBombCount"))
		elseif timer == 26 then
			timerEnvenomCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "envenom", "envenomCount"))
		elseif timer == 36 then
			timerMurderinaRowCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "murderinaRow", "murderinaRowCount"))
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
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType and eventCount then
				if eventType == "killingSpree" then
					specWarnKillingSpree:Show(eventCount)
					specWarnKillingSpree:Play("aesoon")
				elseif eventType == "sameDayDelivery" then
					specWarnSameDayDelivery:Show(eventCount)
					specWarnSameDayDelivery:Play("watchstep")
				elseif eventType == "envenom" then
					if self:IsTank() then
						specWarnEnvenom:Show(eventCount)
						specWarnEnvenom:Play("defensive")
					end
				elseif eventType == "murderinaRow" then
					specWarnMurderinaRow:Show(eventCount)
					specWarnMurderinaRow:Play("breaklos")
				elseif eventType == "fireBomb" then
					specWarnFireBomb:Show(eventCount, "bombyou")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
