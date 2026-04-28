local mod	= DBM:NewMod(2662, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(231865)
mod:SetEncounterID(3074)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnDevouringEntropy				= mod:NewCountAnnounce(1215897, 3)

local specWarnUnstableVoidEssence		= mod:NewSpecialWarningCount(1215087, nil, nil, nil, 2, 12)
local specWarnHulkingFragment			= mod:NewSpecialWarningCount(1280113, nil, nil, nil, 1, 2)

local timerDevouringEntropyCD			= mod:NewCDCountTimer(20.5, 1215897, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
local timerUnstableVoidEssenceCD		= mod:NewCDCountTimer(20.5, 1215087, nil, nil, nil, 5)
local timerHulkingFragmentCD			= mod:NewCDCountTimer(20.5, 1280113, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1215897, true, 1215897, 1, 1, "scatter", 2)--Devouring Entropy

mod.vb.entropyCount = 0
mod.vb.essenceCount = 0
mod.vb.fragmentCount = 0
local badStateDetected = false
local recurringTwentyTwoCount = 0

---@param self DBMMod
---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
local function setFallback(self, dontSetAlerts)
	--Blizz API fallbacks
	if not dontSetAlerts then
		specWarnUnstableVoidEssence:SetAlert(292, "catchballs", 12, 2)
		if self:IsTank() then
			specWarnHulkingFragment:SetAlert(420, "defensive", 2, 1)
		end
	end
	timerDevouringEntropyCD:SetTimeline(290)
	timerUnstableVoidEssenceCD:SetTimeline(292)
	timerHulkingFragmentCD:SetTimeline(420)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.entropyCount = 1
	self.vb.essenceCount = 1
	self.vb.fragmentCount = 1
	recurringTwentyTwoCount = 0
	if self:IsMythicPlus() and DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
		--SetTimeline events since user has disabled DBM Bars (so they can still get countdowns in blizzard timeline API instead)
		if DBM.Options.HideDBMBars then
			setFallback(self, true)
		end
	else
		setFallback(self)
	end

end

function mod:OnCombatEnd()
	self:TLCountReset()
	recurringTwentyTwoCount = 0
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		--Logic confirmed against M+ logs. Opener is 3/9/15, then a repeating 22-second Fragment -> Entropy -> Essence loop.
		if timer > 900 then--Ignored long placeholder artifacts seen in logged pulls
		elseif timer == 3 then--Hulking Fragment opener
			timerHulkingFragmentCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fragment", "fragmentCount"))
		elseif timer == 9 then--Devouring Entropy opener
			timerDevouringEntropyCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "entropy", "entropyCount"))
		elseif timer == 15 then--Unstable Void Essence opener
			timerUnstableVoidEssenceCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "essence", "essenceCount"))
		elseif timer == 24 then--Recurring Fragment -> Entropy -> Essence rotation
			recurringTwentyTwoCount = recurringTwentyTwoCount + 1
			if recurringTwentyTwoCount % 3 == 1 then
				timerHulkingFragmentCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fragment", "fragmentCount"))
			elseif recurringTwentyTwoCount % 3 == 2 then
				timerDevouringEntropyCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "entropy", "entropyCount"))
			else
				timerUnstableVoidEssenceCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "essence", "essenceCount"))
			end
		else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
			badStateDetected = true
			self:ResumeBlizzardAPI()
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	--Note, bar state changing and canceling is handled by core
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
				if eventType == "entropy" then
					warnDevouringEntropy:Show(eventCount)
				elseif eventType == "essence" then
					specWarnUnstableVoidEssence:Show(eventCount)
					specWarnUnstableVoidEssence:Play("catchballs")
				elseif eventType == "fragment" then
					if self:IsTank() then
						specWarnHulkingFragment:Show(eventCount)
						specWarnHulkingFragment:Play("defensive")
					end
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
