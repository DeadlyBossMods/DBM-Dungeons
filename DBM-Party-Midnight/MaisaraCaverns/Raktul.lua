local mod	= DBM:NewMod(2812, "DBM-Party-Midnight", 7, 1315)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248605)
mod:SetEncounterID(3214)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2874)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnCrushSouls			= mod:NewCountAnnounce(1252676, 2)

local specWarnSpiritbreaker		= mod:NewSpecialWarningCount(1251023, nil, nil, nil, 1, 2)
local specWarnSoulrendingRoar	= mod:NewSpecialWarningCount(1253788, nil, nil, nil, 2, 2)

local timerSpiritbreakerCD		= mod:NewCDCountTimer(26, 1251023, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerCrushSoulsCD			= mod:NewCDCountTimer(26, 1252676, nil, nil, nil, 3)
local timerSoulrendingRoarCD	= mod:NewCDCountTimer(70, 1253788, nil, nil, nil, 6)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1252675, true, 1252675, 1, 1, "leapyou", 19)--Crush Souls
mod:AddPrivateAuraSoundOption(1253779, true, 1253779, 1, 2, "watchfeet", 8)--Spectral Decay

mod.vb.spiritbreakerCount = 0
mod.vb.crushSoulsCount = 0
mod.vb.soulrendingRoarCount = 0

local cycle26Count = 0--NOTE: dur=26 is shared by Spiritbreaker and Crush Souls; cycle order is Spiritbreaker, Crush Souls, Spiritbreaker; reset when dur=4 (Spiritbreaker opener) is seen
local badStateDetected = false

---@param self DBMMod
local function setFallback(self)
	if self:IsTank() then
		specWarnSpiritbreaker:SetAlert(156, "defensive", 2)
	end
	specWarnSoulrendingRoar:SetAlert(158, "phasechange", 2)
	timerSpiritbreakerCD:SetTimeline(156)
	timerCrushSoulsCD:SetTimeline(157)
	timerSoulrendingRoarCD:SetTimeline(158)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	cycle26Count = 0
	self.vb.spiritbreakerCount = 1
	self.vb.crushSoulsCount = 1
	self.vb.soulrendingRoarCount = 1
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
	cycle26Count = 0
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		local handled = false
		if timer == 4 then--Spiritbreaker (cycle opener); also resets dur=26 ambiguity counter
			cycle26Count = 0
			timerSpiritbreakerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "spiritbreaker", "spiritbreakerCount"))
			handled = true
		elseif timer == 17 then--Crush Souls (cycle opener)
			timerCrushSoulsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "crushSouls", "crushSoulsCount"))
			handled = true
		elseif timer == 70 then--Soulrending Roar (always cancelled via state 3)
			timerSoulrendingRoarCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "soulrendingRoar", "soulrendingRoarCount"))
			handled = true
		elseif timer == 26 then--Spiritbreaker or Crush Souls (post-opener): cycle is Spiritbreaker, Crush Souls, Spiritbreaker
			cycle26Count = cycle26Count + 1
			if cycle26Count == 1 or cycle26Count == 3 then
				timerSpiritbreakerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "spiritbreaker", "spiritbreakerCount"))
				handled = true
			elseif cycle26Count == 2 then
				timerCrushSoulsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "crushSouls", "crushSoulsCount"))
				handled = true
			end
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
				if eventType == "spiritbreaker" then
					if self:IsTank() then
						specWarnSpiritbreaker:Show(eventCount)
						specWarnSpiritbreaker:Play("defensive")
					end
				elseif eventType == "crushSouls" then
					warnCrushSouls:Show(eventCount)
				elseif eventType == "soulrendingRoar" then
					specWarnSoulrendingRoar:Show(eventCount)
					specWarnSoulrendingRoar:Play("phasechange")
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
