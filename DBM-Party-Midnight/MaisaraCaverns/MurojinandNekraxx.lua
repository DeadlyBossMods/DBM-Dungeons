local mod	= DBM:NewMod(2810, "DBM-Party-Midnight", 7, 1315)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(247570)--Muro, Nekraxx is 247572
mod:SetEncounterID(3212)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2874)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnCarrionSwoop			= mod:NewCountAnnounce(1249478, 2)

local specWarnFlankingSpear		= mod:NewSpecialWarningCount(1266480, nil, nil, nil, 1, 2)
local specWarnFetidQuillstorm	= mod:NewSpecialWarningDodgeCount(1243900, nil, nil, nil, 2, 2)
local specWarnFreezingTrap		= mod:NewSpecialWarningDodgeCount(1243741, nil, nil, nil, 2, 19)
local specWarnBarrage			= mod:NewSpecialWarningDodgeCount(1260643, nil, nil, nil, 2, 2)
local specWarnInfectedPinions	= mod:NewSpecialWarningCount(1246666, "RemoveDisease", nil, nil, 1, 2)

local timerFlankingSpearCD		= mod:NewCDCountTimer(20.5, 1266480, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFetidQuillstormCD	= mod:NewCDCountTimer(20.5, 1243900, nil, nil, nil, 3)
local timerFreezingTrapCD		= mod:NewCDCountTimer(20.5, 1243741, nil, nil, nil, 1)
local timerBarrageCD			= mod:NewCDCountTimer(20.5, 1260643, nil, nil, nil, 3)
local timerInfectedPinionsCD	= mod:NewCDCountTimer(20.5, 1246666, nil, nil, nil, 5, nil, DBM_COMMON_L.DISEASE_ICON)
local timerCarrionSwoopCD		= mod:NewCDCountTimer(20.5, 1249478, nil, nil, nil, 3)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1243741, true, 1243741, 1, 1, "stunyou", 19)--Freezing Trap Stun
mod:AddPrivateAuraSoundOption(1260643, true, 1260643, 1, 1, "frontalyou", 19)--Barrage
mod:AddPrivateAuraSoundOption(1249478, true, 1249478, 1, 1, "behindice", 19)--Carrion Swoop

mod.vb.flankingSpearCount = 0
mod.vb.fetidQuillstormCount = 0
mod.vb.freezingTrapCount = 0
mod.vb.barrageCount = 0
mod.vb.infectedPinionsCount = 0
mod.vb.carrionSwoopCount = 0

local cycleStep = 0
local badStateDetected = false

---@param self DBMMod
local function setFallback(self)
	if self:IsTank() then
		specWarnFlankingSpear:SetAlert(150, "defensive", 2)
	end
	specWarnFetidQuillstorm:SetAlert(151, "watchstep", 2)
	specWarnFreezingTrap:SetAlert(152, "trapsincoming", 19)
	specWarnBarrage:SetAlert(154, "frontal", 15)
	timerFlankingSpearCD:SetTimeline(150)
	timerFetidQuillstormCD:SetTimeline(151)
	timerFreezingTrapCD:SetTimeline(152)
	timerBarrageCD:SetTimeline(153)
	timerInfectedPinionsCD:SetTimeline(154)
	timerCarrionSwoopCD:SetTimeline(155)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	cycleStep = 0
	self.vb.flankingSpearCount = 1
	self.vb.fetidQuillstormCount = 1
	self.vb.freezingTrapCount = 1
	self.vb.barrageCount = 1
	self.vb.infectedPinionsCount = 1
	self.vb.carrionSwoopCount = 1
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
	cycleStep = 0
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		local handled = false
		if timer == 5 then--Flanking Spear (opener)
			timerFlankingSpearCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "flankingSpear", "flankingSpearCount"))
			handled = true
		elseif timer == 12 then--Infected Pinions (opener)
			timerInfectedPinionsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "infectedPinions", "infectedPinionsCount"))
			handled = true
		elseif timer == 20 then--Freezing Trap (opener)
			timerFreezingTrapCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "freezingTrap", "freezingTrapCount"))
			handled = true
		elseif timer == 28 then--Fetid Quillstorm (opener)
			timerFetidQuillstormCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fetidQuillstorm", "fetidQuillstormCount"))
			handled = true
		elseif timer == 35 then--Barrage (opener)
			timerBarrageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "barrage", "barrageCount"))
			handled = true
		elseif timer == 41 then--Carrion Swoop (opener)
			timerCarrionSwoopCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "carrionSwoop", "carrionSwoopCount"))
			handled = true
		elseif timer == 45 then--Cycling post-opener: Flanking Spear, Infected Pinions, Freezing Trap, Fetid Quillstorm, Barrage, Carrion Swoop
			cycleStep = cycleStep + 1
			if cycleStep > 6 then cycleStep = 1 end
			if cycleStep == 1 then
				timerFlankingSpearCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "flankingSpear", "flankingSpearCount"))
			elseif cycleStep == 2 then
				timerInfectedPinionsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "infectedPinions", "infectedPinionsCount"))
			elseif cycleStep == 3 then
				timerFreezingTrapCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "freezingTrap", "freezingTrapCount"))
			elseif cycleStep == 4 then
				timerFetidQuillstormCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fetidQuillstorm", "fetidQuillstormCount"))
			elseif cycleStep == 5 then
				timerBarrageCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "barrage", "barrageCount"))
			elseif cycleStep == 6 then
				timerCarrionSwoopCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "carrionSwoop", "carrionSwoopCount"))
			end
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
				if eventType == "flankingSpear" then
					if self:IsTank() then
						specWarnFlankingSpear:Show(eventCount)
						specWarnFlankingSpear:Play("defensive")
					end
				elseif eventType == "fetidQuillstorm" then
					specWarnFetidQuillstorm:Show(eventCount)
					specWarnFetidQuillstorm:Play("watchstep")
				elseif eventType == "freezingTrap" then
					specWarnFreezingTrap:Show(eventCount)
					specWarnFreezingTrap:Play("trapsincoming")
				elseif eventType == "barrage" then
					specWarnBarrage:Show(eventCount)
					specWarnBarrage:Play("frontal")
				elseif eventType == "infectedPinions" then
					specWarnInfectedPinions:Show(eventCount)
					specWarnInfectedPinions:Play("helpdispel")
				elseif eventType == "carrionSwoop" then
					warnCarrionSwoop:Show(eventCount)
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
