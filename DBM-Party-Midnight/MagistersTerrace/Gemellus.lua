local mod	= DBM:NewMod(2660, "DBM-Party-Midnight", 3, 1300)
--local L		= mod:GetLocalizedStrings()--Nothing to localize for blank mods

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(239636)
mod:SetEncounterID(3073)
--mod:SetHotfixNoticeRev(20250823000000)
--mod:SetMinSyncRevision(20250823000000)
mod:SetZone(2811)
mod.respawnTime = 29

mod:RegisterCombat("combat")

local warnCosmicSting					= mod:NewCountAnnounce(1223958, 3)
local warnNeuralLink					= mod:NewCountAnnounce(1253709, 3)

local timerTriplicateCD					= mod:NewCDCountTimer(20.5, 1223847, nil, nil, nil, 5)
local timerCosmicStingCD				= mod:NewCDCountTimer(20.5, 1223958, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
local timerAstralGraspCD				= mod:NewCDCountTimer(20.5, 1224299, nil, nil, nil, 3)
local timerNeuralLinkCD					= mod:NewCDCountTimer(20.5, 1253709, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerVoidSecretionsCD				= mod:NewCDCountTimer(20.5, 1224104, nil, nil, nil, 3)

--Abilities that have unreliable timers so we have to use pure alert APIs for ENCOUNTER_WARNING
mod:AddCustomAlertSoundOption(1223847, true, 2)--Triplicate
mod:AddCustomAlertSoundOption(1224299, true, 1)--Astral Grasp
--Private aura sounds
--mod:AddPrivateAuraSoundOption(1223958, true, 1223958, 1, 1)--Cosmic Sting
mod:AddPrivateAuraSoundOption(1224104, true, 1224104, 1, 2, "watchfeet", 8)--Void Secretions
mod:AddPrivateAuraSoundOption(1253709, true, 1253709, 1, 1, "linegather", 2)--Neural Link
--mod:AddPrivateAuraSoundOption(1224299, true, 1224299, 1, 1)--Astral Grasp

mod.vb.triplicateCount = 0
mod.vb.stingCount = 0
mod.vb.graspCount = 0
mod.vb.linkCount = 0
local badStateDetected = false
local triplicateUsed = false

---@param self DBMMod
---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
local function setFallback(self, dontSetAlerts)
	--Blizz API fallbacks
	if not dontSetAlerts then
	end
	timerTriplicateCD:SetTimeline(635)
	timerNeuralLinkCD:SetTimeline(97)
	timerAstralGraspCD:SetTimeline(98)
	timerVoidSecretionsCD:SetTimeline(99)
	timerCosmicStingCD:SetTimeline(100)
end

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.triplicateCount = 1
	self.vb.stingCount = 1
	self.vb.graspCount = 1
	self.vb.linkCount = 1
	triplicateUsed = false
	self:EnableAlertOptions(1223847, 635, "specialsoon", 2, 2, 0)
	self:EnableAlertOptions(1224299, 98, "pullin", 2, 2, 0)
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
	triplicateUsed = false
	self:UnregisterShortTermEvents()
end

do
	---@param self DBMMod
	---@param timer number
	---@param timerExact number
	---@param eventID number
	local function timersAll(self, timer, timerExact, eventID)
		--Logic confirmed against M+ logs. Opener is Triplicate(5), then repeating batches of Cosmic Sting(5)/Astral Grasp(29)/Neural Link(16).
		if timer > 80 then return end--Placeholder bars, always canceled
		if timer == 5 then
			if not triplicateUsed then--First duration-5 event is always Triplicate opener
				triplicateUsed = true
				timerTriplicateCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "triplicate", "triplicateCount"))
			else
				timerCosmicStingCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "sting", "stingCount"))
			end
		elseif timer == 16 then--Neural Link
			timerNeuralLinkCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "link", "linkCount"))
		elseif timer == 29 then--Astral Grasp
			timerAstralGraspCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "grasp", "graspCount"))
		else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
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
				if eventType == "sting" then
					warnCosmicSting:Show(eventCount)
				elseif eventType == "link" then
					warnNeuralLink:Show(eventCount)
				end
			end
		elseif eventState == 3 then
			self:TLCountCancel(eventID)
		end
	end
end
