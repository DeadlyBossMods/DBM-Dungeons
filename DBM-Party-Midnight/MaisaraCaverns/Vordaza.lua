local mod	= DBM:NewMod(2811, "DBM-Party-Midnight", 7, 1315)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(248595)
mod:SetEncounterID(3213)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2874)
mod.respawnTime = 29

mod:RegisterCombat("combat")

--NOTE: Final Pursuit has TWO eventIDs even though it's an add fixate. maybe it has a timer?
--NOTE: Whispering Miasma has no event ID, but might be a persistent effect entire encounter and not need one
--NOTE: https://www.wowhead.com/spell=1251813/lingering-dread has a private aura but it doesn't need an alert, just anchor tracking
--NOTE: Wrest Phantoms timeline spellID is 1251204; 1252130 is the damage aura tracked by AddPrivateAuraSoundOption below

local specWarnDrainSoul				= mod:NewSpecialWarningCount(1251554, nil, nil, nil, 1, 2)
local specWarnUnmake				= mod:NewSpecialWarningDodgeCount(1252054, nil, nil, nil, 2, 2)
local specWarnWrestPhantoms			= mod:NewSpecialWarningCount(1252130, nil, nil, nil, 2, 2)
local specWarnNecroticConvergence	= mod:NewSpecialWarningCount(1250708, nil, nil, nil, 1, 2)

local timerDrainSoulCD				= mod:NewCDCountTimer(20.5, 1251554, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerUnmakeCD					= mod:NewCDCountTimer(20.5, 1252054, nil, nil, nil, 3)
local timerWrestPhantomsCD			= mod:NewCDCountTimer(20.5, 1252130, nil, nil, nil, 1)
local timerNecroticConvergenceCD	= mod:NewCDCountTimer(70, 1250708, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1252130, true, 1252130, 1, 2, "watchfeet", 8)--Unmake damage (Wrest Phantoms cast is 1251204)
mod:AddPrivateAuraSoundOption(1251775, true, 1251775, 1, 2, "fixateyou", 19)--Final Pursuit (also encounterevent ID 688 which was hotfixed in recently. Indicating this private aura might zap soon)

mod.vb.drainSoulCount = 0
mod.vb.unmakeCount = 0
mod.vb.wrestPhantomsCount = 0
mod.vb.necroticConvergenceCount = 0

local cycle34Count = 0--NOTE: dur≈34 is shared by Drain Soul, Wrest Phantoms, Unmake post-opener; cycle order is DS, WP, Unmake; resets when dur=3 (cycle-start Drain Soul) is seen
local badStateDetected = false
local necroticCDInfo = {}--tracks startTime and duration per eventID to detect on-time state 3 cancels for Necrotic Convergence

---@param self DBMMod
local function setFallback(self)
	if self:IsTank() then
		specWarnDrainSoul:SetAlert(16, "defensive", 2)
	end
	specWarnUnmake:SetAlert(17, "frontal", 15)
	specWarnWrestPhantoms:SetAlert(19, "mobsoon", 2)
	specWarnNecroticConvergence:SetAlert(20, "attackshield", 2)
	timerDrainSoulCD:SetTimeline(16)
	timerUnmakeCD:SetTimeline(17)
	timerWrestPhantomsCD:SetTimeline(19)
	timerNecroticConvergenceCD:SetTimeline(20)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	cycle34Count = 0
	self.vb.drainSoulCount = 1
	self.vb.unmakeCount = 1
	self.vb.wrestPhantomsCount = 1
	self.vb.necroticConvergenceCount = 1
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
	cycle34Count = 0
	necroticCDInfo = {}
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		local handled = false
		if timer == 3 then--Drain Soul (cycle opener); also resets dur≈34 ambiguity counter
			cycle34Count = 0
			timerDrainSoulCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "drainSoul", "drainSoulCount"))
			handled = true
		elseif timer == 14 then--Wrest Phantoms (cycle opener)
			timerWrestPhantomsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "wrestPhantoms", "wrestPhantomsCount"))
			handled = true
		elseif timer == 25 then--Unmake (cycle opener)
			timerUnmakeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "unmake", "unmakeCount"))
			handled = true
		elseif timer == 70 then--Necrotic Convergence (fires as state 3 due to Blizzard bug; treated as success if elapsed >= duration - 1)
			timerNecroticConvergenceCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "necroticConvergence", "necroticConvergenceCount"))
			necroticCDInfo[eventID] = {startTime = GetTime(), duration = timerExact}
			handled = true
		elseif timer == 33 or timer == 34 then--Drain Soul, Wrest Phantoms, or Unmake (post-opener); last Unmake of cycle can round to 33
			cycle34Count = cycle34Count + 1
			if cycle34Count == 1 then--Drain Soul
				timerDrainSoulCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "drainSoul", "drainSoulCount"))
				handled = true
			elseif cycle34Count == 2 then--Wrest Phantoms
				timerWrestPhantomsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "wrestPhantoms", "wrestPhantomsCount"))
				handled = true
			elseif cycle34Count == 3 then--Unmake
				timerUnmakeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "unmake", "unmakeCount"))
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
			necroticCDInfo[eventID] = nil
			if eventType and eventCount then
				if eventType == "drainSoul" then
					if self:IsTank() then
						specWarnDrainSoul:Show(eventCount)
						specWarnDrainSoul:Play("defensive")
					end
				elseif eventType == "unmake" then
					specWarnUnmake:Show(eventCount)
					specWarnUnmake:Play("frontal")
				elseif eventType == "wrestPhantoms" then
					specWarnWrestPhantoms:Show(eventCount)
					specWarnWrestPhantoms:Play("mobsoon")
				elseif eventType == "necroticConvergence" then
					specWarnNecroticConvergence:Show(eventCount)
					specWarnNecroticConvergence:Play("attackshield")
				end
			end
		elseif eventState == 3 then
			local info = necroticCDInfo[eventID]
			necroticCDInfo[eventID] = nil
			if info and (GetTime() - info.startTime) >= info.duration - 1 then
				--On-time cancel: Blizzard fires state 3 instead of state 2 for Necrotic Convergence; treat as success
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType and eventCount then
					specWarnNecroticConvergence:Show(eventCount)
					specWarnNecroticConvergence:Play("attackshield")
				end
			else
				self:TLCountCancel(eventID)
			end
		end
	end
end
