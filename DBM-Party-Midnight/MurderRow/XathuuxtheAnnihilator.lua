local mod	= DBM:NewMod(2681, "DBM-Party-Midnight", 2, 1304)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234647)
mod:SetEncounterID(3103)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2813)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--mod:RegisterEventsInCombat(

--)

--NOTE, https://www.wowhead.com/ptr/spell=1295452/infernal-crush has an ID of 752 for the targeted circles
local specWarnLegionStrike					= mod:NewSpecialWarningCount(473898, "Tank", nil, nil, 1, 2, nil, nil, "defensive")
local specWarnDemonicRage					= mod:NewSpecialWarningCount(474197, nil, nil, nil, 2, 2, nil, nil, "aesoon")
local specWarnAxeToss						= mod:NewSpecialWarningBlizzYou(1214637, nil, nil, nil, 1, 2, nil, nil, "targetyou")--Unverified: personal ENCOUNTER_WARNING not seen in the logger's pulls

local timerLegionStrikeCD					= mod:NewCDCountTimer(20.5, 473898, nil, nil, nil, 5)
local timerDemonicRageCD					= mod:NewCDCountTimer(20.5, 474197, nil, nil, nil, 2)
local timerAxeTossCD						= mod:NewCDCountTimer(20.5, 1214637, nil, nil, nil, 3)
local timerInfernalCrushCD					= mod:NewCDCountTimer(20.5, 1295452, nil, nil, nil, 3)

--Custom Aura Sounds
mod:AddAuraSoundOption(474234, true, 474234, 1, 2, "watchfeet", 8)--Burning Steps
mod:AddAuraSoundOption(1218203, true, 1218203, 1, 1, "runout", 2)--Fingers of Gul'dan
mod:AddAuraSoundOption(1295452, true, 1295452, 1, 1, "runout", 2)--Infernal Crush (Check for ENCOUNTER_WARNING intercept instead)

mod.vb.legionStrikeCount = 0
mod.vb.demonicRageCount = 0
mod.vb.axeTossCount = 0
mod.vb.infernalCrushCount = 0
local badStateDetected = false
local count27 = 1

---@param self DBMMod
---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then
			specWarnLegionStrike:SetAlert(30, "defensive", 2, 2)
		end
		specWarnDemonicRage:SetAlert(32, "aesoon", 2, 2)
		specWarnAxeToss:SetAlert({31, 559}, "targetyou", 2, 2, 0)
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerLegionStrikeCD:SetTimeline(30, onlyColor)
	timerDemonicRageCD:SetTimeline(32, onlyColor)
	timerAxeTossCD:SetTimeline({31, 559}, onlyColor)
	timerInfernalCrushCD:SetTimeline(752, onlyColor)
end

function mod:OnLimitedCombatStart()
	self:FixBlizzardAPI()--This boss also uses 16 minute timers to show paused abilities on track (it's like blizz forgot bars exist though)
	self:TLCountReset()
	self.vb.legionStrikeCount = 1
	self.vb.demonicRageCount = 1
	self.vb.axeTossCount = 1
	self.vb.infernalCrushCount = 1
	count27 = 1
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
	count27 = 1
	self:UnregisterShortTermEvents()
end

do
	local function timersAll(self, timer, timerExact, eventID)
		if timer > 100 or timer < 1 then
			return true--Ignored paused/placeholder bars
		elseif timer == 6 then
			timerLegionStrikeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "legionStrike", "legionStrikeCount"))
		elseif timer == 27 then
			local isPhantom = count27 % 2 == 0
			count27 = count27 + 1
			if not isPhantom then
				timerLegionStrikeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "legionStrike", "legionStrikeCount"))
			end
		elseif timer == 15 then
			timerAxeTossCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "axeToss", "axeTossCount"))
		elseif timer == 30 then
			timerInfernalCrushCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "infernalCrush", "infernalCrushCount"))
		elseif timer == 35 then
			timerDemonicRageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "demonicRage", "demonicRageCount"))
		else
			return
		end
		return true
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 then return end
		local eventID = eventInfo.id
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if eventState ~= 0 then return end
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
				if eventType == "legionStrike" then
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnLegionStrike:Show(eventCount)
						specWarnLegionStrike:Play("defensive")
					end
				elseif eventType == "demonicRage" then
					specWarnDemonicRage:Show(eventCount)
					specWarnDemonicRage:Play("aesoon")
				elseif eventType == "axeToss" then
					specWarnAxeToss:Show(eventCount, "targetyou")--Unverified: assumes the next personal ENCOUNTER_WARNING belongs to Axe Toss
				end
			end
		elseif eventState == 1 or eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
