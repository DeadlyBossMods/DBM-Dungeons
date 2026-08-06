local mod	= DBM:NewMod(2771, "DBM-Party-Midnight", 4, 1309)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(245912)
mod:SetEncounterID(3201)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2859)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)
--NOTE https://www.wowhead.com/ptr/spell=1296871/power-surge has an ID of 780 but is not in the journal

--local warnLightfire							= mod:NewCountAnnounce(1239825, 2)
local warnPulverizingStrikes				= mod:NewCountAnnounce(1240222, 2)

local specWarnLightfall						= mod:NewSpecialWarningCount(1240098, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnGrievousThrash				= mod:NewSpecialWarningCount(1241058, "Healer", nil, nil, 2, 2, nil, nil, "healfull")
local specWarnMoonkinForm					= mod:NewSpecialWarningCount(1239882, nil, nil, nil, 1, 2, nil, nil, "phasechange")
local specWarnBearForm						= mod:NewSpecialWarningCount(1239885, nil, nil, nil, 1, 2, nil, nil, "phasechange")
local specWarnHaranirForm					= mod:NewSpecialWarningCount(1239883, nil, nil, nil, 1, 2, nil, nil, "phasechange")
local specWarnSpiritsOfTheVale				= mod:NewSpecialWarningCount(1241067, nil, nil, nil, 2, 2, nil, nil, "specialsoon")
local specWarnLightfire						= mod:NewSpecialWarningBlizzYou(1239825, nil, nil, nil, 2, 2, nil, nil, "runout")

local timerLightfireCD						= mod:NewCDCountTimer(20.5, 1239825, nil, nil, nil, 3)
local timerLightfallCD						= mod:NewCDCountTimer(20.5, 1240098, nil, nil, nil, 3)
local timerPulverizingStrikesCD				= mod:NewCDCountTimer(20.5, 1240222, nil, nil, nil, 3)
local timerGrievousThrashCD					= mod:NewCDCountTimer(20.5, 1241058, nil, "Healer", nil, 5)

--Custom Aura Sounds
--mod:AddAuraSoundOption(1239825, true, 1239825, 1, 1, "runout", 2)--Lightfire
--mod:AddAuraSoundOption(1240222, true, 1240222, 1, 1, "lineyou", 17)--Pulverizing Strikes

mod.vb.lightfireCount = 0
mod.vb.lightfallCount = 0
mod.vb.grievousThrashCount = 0
mod.vb.pulverizingStrikesCount = 0
local badStateDetected = false
local stageOneAlternation = 1
local stageTwoAlternation = 1
local stageThreeAlternation = 1

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		specWarnLightfall:SetAlert(182, "watchstep", 2, 3)
		specWarnGrievousThrash:SetAlert(184, "healfull", 2, 3)
		specWarnBearForm:SetAlert(185, "phasechange", 2, 2)
		specWarnMoonkinForm:SetAlert(186, "phasechange", 2, 2)
		specWarnHaranirForm:SetAlert(187, "phasechange", 2, 2)
		specWarnSpiritsOfTheVale:SetAlert(188, "specialsoon", 2, 4, 0)
		specWarnLightfire:SetAlert(181, "runout", 2, 2, 0)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerLightfireCD:SetTimeline(181, onlyColor)
	timerLightfallCD:SetTimeline(182, onlyColor)
	timerPulverizingStrikesCD:SetTimeline(183, onlyColor)
	timerGrievousThrashCD:SetTimeline(184, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self:SetStage(1)
	self.vb.lightfireCount = 1
	self.vb.lightfallCount = 1
	self.vb.grievousThrashCount = 1
	self.vb.pulverizingStrikesCount = 1
	stageOneAlternation = 1
	stageTwoAlternation = 1
	stageThreeAlternation = 1
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
	local function startLightfire(self, timerExact, eventID)
		timerLightfireCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightfire", "lightfireCount"))
	end
	local function startLightfall(self, timerExact, eventID)
		timerLightfallCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightfall", "lightfallCount"))
	end
	local function startGrievousThrash(self, timerExact, eventID)
		if self:GetStage(1) then
			self:SetStage(2)
			stageTwoAlternation = 1
			specWarnBearForm:Show(1)
			specWarnBearForm:Play("phasechange")
		end
		timerGrievousThrashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "grievousThrash", "grievousThrashCount"))
	end
	local function startPulverizingStrikes(self, timerExact, eventID)
		timerPulverizingStrikesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "pulverizingStrikes", "pulverizingStrikesCount"))
	end

	local function timersAll(self, timer, timerExact, eventID)
		if timerExact == 0.5 then
			specWarnMoonkinForm:Show(1)
			specWarnMoonkinForm:Play("phasechange")
			return true
		elseif timerExact == 2.5 then
			if not self:GetStage(3) then
				self:SetStage(3)
				stageThreeAlternation = 1
				specWarnSpiritsOfTheVale:Show(1)
				specWarnSpiritsOfTheVale:Play("specialsoon")
				specWarnHaranirForm:Show(1)
				specWarnHaranirForm:Play("phasechange")
			end
			return true
		elseif timer == 3 then
			startGrievousThrash(self, timerExact, eventID)--Stage-two transition
		elseif self:GetStage(3) then
			if timer == 7 then
				startLightfire(self, timerExact, eventID)
			elseif timer == 15 then
				startGrievousThrash(self, timerExact, eventID)
			elseif timer == 23 then
				startLightfall(self, timerExact, eventID)
			elseif timer == 31 then
				startPulverizingStrikes(self, timerExact, eventID)
			elseif timer == 32 then
				if stageThreeAlternation == 1 then
					startLightfire(self, timerExact, eventID)
				elseif stageThreeAlternation == 2 then
					startGrievousThrash(self, timerExact, eventID)
				elseif stageThreeAlternation == 3 then
					startLightfall(self, timerExact, eventID)
				else
					startPulverizingStrikes(self, timerExact, eventID)
				end
				stageThreeAlternation = stageThreeAlternation % 4 + 1
			else
				return
			end
		elseif self:GetStage(1) then
			if timer == 5 then
				startLightfire(self, timerExact, eventID)
			elseif timer == 18 then
				startLightfall(self, timerExact, eventID)
			elseif timer >= 20 and timer <= 21 then
				if stageOneAlternation == 1 then
					startLightfire(self, timerExact, eventID)
				else
					startLightfall(self, timerExact, eventID)
				end
				stageOneAlternation = stageOneAlternation % 2 + 1
			else
				return
			end
		else
			if timer == 9 then
				startPulverizingStrikes(self, timerExact, eventID)
			elseif timer >= 20 and timer <= 21 then
				if stageTwoAlternation == 1 then
					startGrievousThrash(self, timerExact, eventID)
				else
					startPulverizingStrikes(self, timerExact, eventID)
				end
				stageTwoAlternation = stageTwoAlternation % 2 + 1
			else
				return
			end
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
				if eventType == "lightfire" then
					specWarnLightfire:Show(eventCount, "runout")
				elseif eventType == "lightfall" then
					specWarnLightfall:Show(eventCount)
					specWarnLightfall:Play("watchstep")
				elseif eventType == "grievousThrash" then
					if self:IsHealer() then
						specWarnGrievousThrash:Show(eventCount)
						specWarnGrievousThrash:Play("healfull")
					end
				elseif eventType == "pulverizingStrikes" then
					warnPulverizingStrikes:Show(eventCount)
				end
			end
		elseif eventState == 1 or eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
