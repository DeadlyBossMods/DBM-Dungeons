local mod	= DBM:NewMod(2791, "DBM-Party-Midnight", 6, 1313)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(238887)
mod:SetEncounterID(3285)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2923)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local is121 = DBM:GetTOC() == 120100

--mod:RegisterEventsInCombat(

--)
local specWarnVoidBlast						= mod:NewSpecialWarningCount(is121 and 1297017 or 1222085, "Tank", nil, nil, 1, 2, nil, nil, "defensive")
local specWarnBlackHole						= mod:NewSpecialWarningCount(is121 and 1300259 or 1222274, nil, nil, nil, 2, 2, nil, nil, "pullin")
local specWarnUmbralRupture					= mod:NewSpecialWarningCount(1296963, nil, nil, nil, 2, 2, nil, nil, "watchstep")
local specWarnNetherDash					= mod:NewSpecialWarningBlizzYou(1222098, nil, nil, nil, 2, 2, nil, nil, "chargemove")

local timerVoidBlastCD						= mod:NewCDCountTimer(20.5, is121 and 1297017 or 1222085, nil, nil, nil, 5)
local timerBlackHoleCD						= mod:NewCDCountTimer(20.5, is121 and 1300259 or 1222274, nil, nil, nil, 2)
local timerUmbralRuptureCD					= mod:NewCDCountTimer(20.5, 1296963, nil, nil, nil, 3)
local timerNetherDashCD						= mod:NewCDCountTimer(20.5, 1222098, nil, nil, nil, 3)
--Custom Aura Sounds
mod:AddAuraSoundOption(1225011, true, 1225011, 1, 1, "debuffyou", 17)--Ethereal Shards
--mod:AddAuraSoundOption(1222098, true, 1222098, 1, 1, "chargemove", 2)--Nether Dash

mod.vb.voidBlastCount = 0
mod.vb.blackHoleCount = 0
mod.vb.umbralRuptureCount = 0
mod.vb.netherDashCount = 0
local badStateDetected = false
local function setFallback(self, dontSetAlerts)
	if not dontSetAlerts then
		if self:IsTank() then specWarnVoidBlast:SetAlert(39, "defensive", 2, 2) end
		specWarnNetherDash:SetAlert(558, "chargemove", 2, 2, 0)
		specWarnBlackHole:SetAlert(41, "pullin", 12, 2)
		if is121 then
			specWarnUmbralRupture:SetAlert(782, "watchstep", 2, 2)
		end
	end
	local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
	timerVoidBlastCD:SetTimeline(39, onlyColor)
	timerBlackHoleCD:SetTimeline(41, onlyColor)
	if is121 then
		timerNetherDashCD:SetTimeline(558, onlyColor)
		timerUmbralRuptureCD:SetTimeline(782, onlyColor)
	end
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.voidBlastCount = 1
	self.vb.blackHoleCount = 1
	self.vb.umbralRuptureCount = 1
	self.vb.netherDashCount = 1
	if is121 and DBM.Options.HardcodedTimer and not badStateDetected then
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
		if timer == 31 then
			timerBlackHoleCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "blackHole", "blackHoleCount"))
		elseif timer == 16 then
			timerUmbralRuptureCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "umbralRupture", "umbralRuptureCount"))
		elseif timer == 25 then
			timerVoidBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "voidBlast", "voidBlastCount"))
		elseif timer == 6 then
			timerNetherDashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "netherDash", "netherDashCount"))
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
				if eventType == "voidBlast" then
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnVoidBlast:Show(eventCount)
						specWarnVoidBlast:Play("defensive")
					end
				elseif eventType == "blackHole" then
					specWarnBlackHole:Show(eventCount)
					specWarnBlackHole:Play("pullin")
				elseif eventType == "umbralRupture" then
					specWarnUmbralRupture:Show(eventCount)
					specWarnUmbralRupture:Play("watchstep")
				elseif eventType == "netherDash" then
					specWarnNetherDash:Show(eventCount, "chargemove")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
