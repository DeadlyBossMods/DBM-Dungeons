local mod	= DBM:NewMod(2658, "DBM-Party-Midnight", 1, 1299)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231636)
mod:SetEncounterID(3059)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2805)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--NOTE: maybe also add a Bolt Gale general cast sound if the cone is large
local warnBoltGale					= mod:NewCountAnnounce(474528, 3)
local warnGustShot					= mod:NewCountAnnounce(1253979, 3)

local specWarnBullseyeWindblast		= mod:NewSpecialWarningCount(468429, nil, nil, nil, 1, 15)
local specWarnArrowRain				= mod:NewSpecialWarningDodgeCount(472556, nil, nil, nil, 2, 2)
local specWarnTempestSlash			= mod:NewSpecialWarningCount(472662, nil, nil, nil, 3, 2)

local timerBullseyeWindblastCD		= mod:NewCDCountTimer(24, 468429, nil, nil, nil, 3, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerBoltGaleCD				= mod:NewCDCountTimer(39, 474528, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
local timerArrowRainCD				= mod:NewCDCountTimer(9, 472556, nil, nil, nil, 3)
local timerTempestSlashCD			= mod:NewCDCountTimer(21, 472662, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerGustShotCD				= mod:NewCDCountTimer(23.5, 1253979, nil, nil, nil, 3)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1282911, true, 474528, 1, 1, "lineyou", 17)--Bolt Gale
mod:AddPrivateAuraSoundOption(1253979, true, 1253979, 1, 1, "movetopool", 15)--Gust Shot
mod:AddPrivateAuraSoundOption(472662, true, 472662, 1, 1, "movetoarrow", 19)--Tempest Slash
mod:AddPrivateAuraSoundOption(1216042, true, 1216042, 1, 1, "movetoarrow", 19)--Squall Leap

mod.vb.bullseyeWindblastCount = 0
mod.vb.boltGaleCount = 0
mod.vb.arrowRainCount = 0
mod.vb.tempestSlashCount = 0
mod.vb.gustShotCount = 0

local badStateDetected = false

---@param self DBMMod
local function setFallback(self)
	specWarnBullseyeWindblast:SetAlert(21, "getknockedup", 15)
	specWarnArrowRain:SetAlert(23, "watchstep", 2)
	if self:IsTank() then
		specWarnTempestSlash:SetAlert(24, "defensive", 2)
	end
	timerBullseyeWindblastCD:SetTimeline(21)
	timerBoltGaleCD:SetTimeline(22)
	timerArrowRainCD:SetTimeline(23)
	timerTempestSlashCD:SetTimeline(24)
	timerGustShotCD:SetTimeline(538)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.bullseyeWindblastCount = 1
	self.vb.boltGaleCount = 1
	self.vb.arrowRainCount = 1
	self.vb.tempestSlashCount = 1
	self.vb.gustShotCount = 1
	badStateDetected = false
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
		--Logic confirmed against M+ only.
		if timer == 9 or timer == 11 then--Arrow Rain (9 opener, 11 steady)
			timerArrowRainCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "arrowRain", "arrowRainCount"))
		elseif timer == 21 then--Tempest Slash
			timerTempestSlashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "tempestSlash", "tempestSlashCount"))
		elseif timer == 24 then--Bullseye Windblast opener (24.0) or Gust Shot (23.5)
			if timerExact < 23.75 then--Gust Shot at 23.5
				timerGustShotCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "gustShot", "gustShotCount"))
			else--Bullseye Windblast opener at 24.0
				timerBullseyeWindblastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bullseyeWindblast", "bullseyeWindblastCount"))
			end
		elseif timer == 39 then--Bolt Gale
			timerBoltGaleCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "boltGale", "boltGaleCount"))
		elseif timer == 53 then--Bullseye Windblast steady
			timerBullseyeWindblastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bullseyeWindblast", "bullseyeWindblastCount"))
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
				if eventType == "arrowRain" then
					specWarnArrowRain:Show(eventCount)
					specWarnArrowRain:Play("watchstep")
				elseif eventType == "tempestSlash" then
					if self:IsTank() then
						specWarnTempestSlash:Show(eventCount)
						specWarnTempestSlash:Play("defensive")
					end
				elseif eventType == "bullseyeWindblast" then
					specWarnBullseyeWindblast:Show(eventCount)
					specWarnBullseyeWindblast:Play("getknockedup")
				elseif eventType == "boltGale" then
					warnBoltGale:Show(eventCount)
				elseif eventType == "gustShot" then
					warnGustShot:Show(eventCount)
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
