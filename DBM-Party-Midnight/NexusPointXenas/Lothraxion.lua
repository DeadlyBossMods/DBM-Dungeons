local mod	= DBM:NewMod(2815, "DBM-Party-Midnight", 8, 1316)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(241546)
mod:SetEncounterID(3333)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2915)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnBrilliantRadiance			= mod:NewCountAnnounce(1255503, 2)

local specWarnSearingRend			= mod:NewSpecialWarningCount(1255335, "Melee", nil, nil, 1, 2)
local specWarnDivineGuile			= mod:NewSpecialWarningCount(1257567, nil, nil, nil, 2, 2)
local specWarnFlicker				= mod:NewSpecialWarningDodgeCount(1255531, nil, nil, nil, 2, 2)

local timerSearingRendCD			= mod:NewCDCountTimer(26, 1255335, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerBrilliantDispersionCD	= mod:NewCDCountTimer(25, 1255503, nil, nil, nil, 3)
local timerDivineGuileCD			= mod:NewCDCountTimer(52, 1257567, nil, nil, nil, 6)
local timerFlickerCD				= mod:NewCDCountTimer(10, 1255531, nil, nil, nil, 3)

--Private Auras
mod:AddPrivateAuraSoundOption(1255503, true, 1255503, 1, 1, "poolyou", 18)--Brilliant Dispersion
--mod:AddPrivateAuraSoundOption(1255335, false, 1255335, 1, 1)--Searing Rend
mod:AddPrivateAuraSoundOption(1255310, true, 1255310, 1, 2, "watchfeet", 8)--Radiant Scar
--mod:AddPrivateAuraSoundOption(1271956, false, 1271956, 1, 1)--Mirrored Rend

mod.vb.searingRendCount = 0
mod.vb.brilliantDispersionCount = 0
mod.vb.divineGuileCount = 0
mod.vb.flickerCount = 0

local badStateDetected = false

---@param self DBMMod
local function setFallback(self)
	warnBrilliantRadiance:SetAlert(109, "scattersoon", 2)
	specWarnDivineGuile:SetAlert(110, "phasechange", 2)
	if self:IsMelee() then
		specWarnSearingRend:SetAlert(111, "frontal", 15)
	end
	specWarnFlicker:SetAlert(112, "watchstep", 2)
	timerBrilliantDispersionCD:SetTimeline(109)
	timerDivineGuileCD:SetTimeline(110)
	timerSearingRendCD:SetTimeline(111)
	timerFlickerCD:SetTimeline(112)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.searingRendCount = 1
	self.vb.brilliantDispersionCount = 1
	self.vb.divineGuileCount = 1
	self.vb.flickerCount = 1
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
		local handled = false
		if timer == 2 or timer == 26 then--Searing Rend (2=opener/re-opener, 26=post-opener repeat)
			timerSearingRendCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "searingRend", "searingRendCount"))
			handled = true
		elseif timer == 11 or timer == 25 then--Brilliant Dispersion (11=opener/re-opener, 25=post-opener repeat)
			timerBrilliantDispersionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "brilliantDispersion", "brilliantDispersionCount"))
			handled = true
		elseif timer == 10 or timer == 24 then--Flicker (24=opener/re-opener, 10=post-opener repeat)
			timerFlickerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "flicker", "flickerCount"))
			handled = true
		elseif timer == 52 then--Divine Guile
			timerDivineGuileCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "divineGuile", "divineGuileCount"))
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
				if eventType == "searingRend" then
					specWarnSearingRend:Show(eventCount)
					specWarnSearingRend:Play("frontal")
				elseif eventType == "brilliantDispersion" then
					warnBrilliantRadiance:Show(eventCount)
				elseif eventType == "divineGuile" then
					specWarnDivineGuile:Show(eventCount)
					specWarnDivineGuile:Play("phasechange")
				elseif eventType == "flicker" then
					specWarnFlicker:Show(eventCount)
					specWarnFlicker:Play("watchstep")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
