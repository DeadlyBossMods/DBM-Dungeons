local mod	= DBM:NewMod(2792, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(239008)
mod:SetEncounterID(3286)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
local specWarnProvokeCreeper				= mod:NewSpecialWarningCount(1222371, nil, nil, nil, 1, 2, nil, nil, "bigmob")--No direct timeline event; scheduled 3 seconds after Monstrous Roar
local specWarnHulkingClaw					= mod:NewSpecialWarningCount(1222642, "Tank", nil, nil, 1, 2, nil, nil, "defensive")
local specWarnNoxiousBreath					= mod:NewSpecialWarningCount(1263977, nil, nil, nil, 2, 3, nil, nil, "frontal")
local specWarnPoisonSplash					= mod:NewSpecialWarningCount(1226120, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnMonstrousRoar					= mod:NewSpecialWarningCount(1262497, nil, nil, nil, 2, 3, nil, nil, "carefly")

local timerProvokeCreeperCD					= mod:NewCDCountTimer(20.5, 1222371, nil, nil, nil, 1)--No direct timeline event; scheduled 3 seconds after Monstrous Roar
local timerHulkingClawCD					= mod:NewCDCountTimer(20.5, 1222642, nil, nil, nil, 5)
local timerNoxiousBreathCD					= mod:NewCDCountTimer(20.5, 1263977, nil, nil, nil, 3)
local timerPoisonSplashCD					= mod:NewCDCountTimer(20.5, 1226120, nil, nil, nil, 3)
local timerMonstrousRoarCD					= mod:NewCDCountTimer(20.5, 1262497, nil, nil, nil, 2)
--Custom Aura Sounds
mod:AddAuraSoundOption(1283506, true, 1283506, 4, 1, "kite", 19)--Fixate (currently broken, doesn't work on blizzards end)
mod:AddAuraSoundOption(1222484, true, 1222484, 1, 2, "watchfeet", 8)--Poison Pool

mod.vb.provokeCreeperCount = 0
mod.vb.hulkingClawCount = 0
mod.vb.noxiousBreathCount = 0
mod.vb.poisonSplashCount = 0
mod.vb.monstrousRoarCount = 0
local badStateDetected = false
local count20 = 0
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnProvokeCreeper:SetAlert(46, "bigmob", 2, 2, 0)
		if self:IsTank() then
			specWarnHulkingClaw:SetAlert(47, "defensive", 2, 2)
		end
		specWarnNoxiousBreath:SetAlert(54, "frontal", 15, 3)
		specWarnPoisonSplash:SetAlert(55, "watchstep", 2, 2)
		specWarnMonstrousRoar:SetAlert(297, "carefly", 2, 3)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerProvokeCreeperCD:SetTimeline(46, onlyColor)
	timerHulkingClawCD:SetTimeline(47, onlyColor)
	timerNoxiousBreathCD:SetTimeline(54, onlyColor)
	timerPoisonSplashCD:SetTimeline(55, onlyColor)
	timerMonstrousRoarCD:SetTimeline(297, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.provokeCreeperCount = 1
	self.vb.hulkingClawCount = 1
	self.vb.noxiousBreathCount = 1
	self.vb.poisonSplashCount = 1
	self.vb.monstrousRoarCount = 1
	count20 = 0
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
		if timer == 5 then
			timerPoisonSplashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "poisonSplash", "poisonSplashCount"))
		elseif timer == 10 then
			timerHulkingClawCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "hulkingClaw", "hulkingClawCount"))
		elseif timer == 15 or timer == 30 then
			timerNoxiousBreathCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "noxiousBreath", "noxiousBreathCount"))
		elseif timer == 20 then
			count20 = count20 + 1
			if count20 % 2 == 1 then
				timerPoisonSplashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "poisonSplash", "poisonSplashCount"))
			else
				timerHulkingClawCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "hulkingClaw", "hulkingClawCount"))
			end
		elseif timer == 35 then
			timerMonstrousRoarCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "monstrousRoar", "monstrousRoarCount"))
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
				if eventType == "hulkingClaw" then
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnHulkingClaw:Show(eventCount)
						specWarnHulkingClaw:Play("defensive")
					end
				elseif eventType == "noxiousBreath" then
					specWarnNoxiousBreath:Show(eventCount)
					specWarnNoxiousBreath:Play("frontal")
				elseif eventType == "poisonSplash" then
					specWarnPoisonSplash:Show(eventCount)
					specWarnPoisonSplash:Play("watchstep")
				elseif eventType == "monstrousRoar" then
					specWarnMonstrousRoar:Show(eventCount)
					specWarnMonstrousRoar:Play("carefly")
					local provokeCount = self.vb.provokeCreeperCount
					timerProvokeCreeperCD:Start(3, provokeCount)
					specWarnProvokeCreeper:Schedule(3, provokeCount)
					specWarnProvokeCreeper:ScheduleVoice(3, "bigmob")
					self.vb.provokeCreeperCount = provokeCount + 1
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
