local mod	= DBM:NewMod("Nullaeus", "DBM-Delves-Midnight", 1)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"
mod.soloChallenge = true

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(244752)--Not known which 2 are nemesis boss yet and which 2 are random spawns
mod:SetEncounterID(3372, 3430)
mod:SetHotfixNoticeRev(20250220000000)
mod:SetMinSyncRevision(20250220000000)
mod:SetZone(2966)

mod:RegisterCombat("combat")

--NOTES:
--https://www.wowhead.com/beta/spell=1255886/oblivion-shell is a private aura for a boss ability. Seems iffy to use as a PA sound though
--Despite adding 3 abilities, it's unclear what any of them actually do. Sounds will likely need tweaking.
--Custom Sounds on cast/cooldown expiring

local warnDevouringEssence					= mod:NewCountAnnounce(1256358, 2)

local specWarnImplodingStrike				= mod:NewSpecialWarningDefensive(1256355, nil, nil, nil, 1, 2)
local specWarnEmptinessOfTheVoid			= mod:NewSpecialWarningInterruptCount(1256351, nil, nil, nil, 3, 2)

local timerDevouringEssenceCD				= mod:NewCDCountTimer(20.5, 1256358, DBM_COMMON_L.DEBUFF.." (%s)", nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerImplodingStrikeCD				= mod:NewCDCountTimer(20.5, 1256355, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerEmptinessOfTheVoidCD				= mod:NewVarCountTimer("v19.5-23.3", 1256351, DBM_COMMON_L.INTERRUPT.." (%s)", nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerPhase							= mod:NewStageTimer(42)

mod:AddPrivateAuraSoundOption({1287014, 1256045}, true, 1287014, 1, 2, "watchfeet", 8)--Null Zone

mod.vb.devouringEssenceCount = 0
mod.vb.implodingStrikeCount = 0
mod.vb.voidCount = 0
local badStateDetected = false
local workaroundblizzardincompitence = {}--In case we have to fall back to blizz timers, this will prevent us from trying to use encounter timeline events which are also used by blizz timers and will cause false positives that break timers
--local tankFound = false

local function setFallback(self)
	--Blizz API fallbacks
	warnDevouringEssence:SetAlert({390, 395}, "incomingdebuff", 15, 2)
	timerDevouringEssenceCD:SetTimeline({390, 395})
	specWarnImplodingStrike:SetAlert({391, 394}, "defensive", 19, 2)
	timerImplodingStrikeCD:SetTimeline({391, 394})
	specWarnEmptinessOfTheVoid:SetAlert({392, 393}, "kickcast", 19, 2)
	timerEmptinessOfTheVoidCD:SetTimeline({392, 393})
end

--[[
local function isTankInGroup()
	if not IsInGroup() then
		tankFound = UnitGroupRolesAssigned("player") == "TANK"
	else
		local groupType = IsInRaid() and "raid" or "party"
		for i = 1, GetNumGroupMembers() do
			if UnitIsGroupLeader(groupType..i) then
				tankFound = UnitGroupRolesAssigned(groupType..i) == "TANK"
				return
			end
		end
	end
end
--]]

function mod:OnLimitedCombatStart()
	self:TLCountReset()
	self.vb.devouringEssenceCount = 1
	self.vb.implodingStrikeCount = 1
	self.vb.voidCount = 1
	workaroundblizzardincompitence = {}
--	isTankInGroup()
	if DBM.Options.HardcodedTimer and not badStateDetected then
		self:IgnoreBlizzardAPI()
		self:RegisterShortTermEvents(
			"ENCOUNTER_TIMELINE_EVENT_ADDED",
			"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
		)
	else
		setFallback(self)
	end
	--if self:IsMythic() then
	--	self:SetCreatureID(252892)
	--else
	--	self:SetCreatureID(244752)
	--end
end

function mod:OnCombatEnd()
	self:TLCountReset()
	self:UnregisterShortTermEvents()
end

do
	--Timers tank verified for both prot and fury warrior
	---@param self DBMMod
	---@param timer number
	---@param eventID number
	local function timersAll(self, timer, eventID)
		--Void has unique rounded durations (7 opener, 21 recurring)
		if timer == 7 or self:IsRoundedTimer(timer, 21.5, 0.5) or self:IsRoundedTimer(timer, 36) or self:IsRoundedTimer(timer, 51) then
			if workaroundblizzardincompitence["void"] then
				specWarnEmptinessOfTheVoid:Show(L.name, self.vb.voidCount)
				specWarnEmptinessOfTheVoid:Play("kickcast")
				self.vb.voidCount = self.vb.voidCount + 1
				DBM:Debug("Showing extra emptyness of the void warning", nil, nil, nil, true)
				workaroundblizzardincompitence["void"] = false
			end
			local count = self:TLCountStart(eventID, "void", "voidCount")
			timerEmptinessOfTheVoidCD:TLStart(timer == 21 and "v19.5-23.3" or 7, eventID, count)
		--Devouring is opener 16.0 and recurring 18.5 (rounded to 19)
		elseif timer == 16 or self:IsRoundedTimer(timer, 19, 0.5) then--Is rounded covers 18.5-19.5
			if workaroundblizzardincompitence["devouring"] then
				warnDevouringEssence:Show(self.vb.devouringEssenceCount)
				self.vb.devouringEssenceCount = self.vb.devouringEssenceCount + 1
				DBM:Debug("Showing extra devouring essence warning", nil, nil, nil, true)
				workaroundblizzardincompitence["devouring"] = false
			end
			local count = self:TLCountStart(eventID, "devouring", "devouringEssenceCount")
			timerDevouringEssenceCD:TLStart(timer, eventID, count)
		--Imploding is opener 12, recurring 15.4-16.2 (but we let devouring essence claim 16.0 since we haven't seen it here
		elseif timer == 12 or self:IsRoundedTimer(timer, 15.8, 0.4) then
			if workaroundblizzardincompitence["imploding"] then
				specWarnImplodingStrike:Show()
				specWarnImplodingStrike:Play("defensive")
				self.vb.implodingStrikeCount = self.vb.implodingStrikeCount + 1
				DBM:Debug("Showing extra imploding strike warning", nil, nil, nil, true)
				workaroundblizzardincompitence["imploding"] = false
			end
			local count = self:TLCountStart(eventID, "imploding", "implodingStrikeCount")
			timerImplodingStrikeCD:TLStart(timer, eventID, count)
		else--Hardcode failed; disable and fall back to Blizzard API
			badStateDetected = true
			if DBM.Options.IgnoreBlizzAPI then
				DBM.Options.IgnoreBlizzAPI = false
				DBM:FireEvent("DBM_ResumeBlizzAPI")
			end
			self:UnregisterShortTermEvents()
			setFallback(self)
			DBM:Debug("|cffff0000TormentsRise: Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
		end
	end

	--Note, bar state changing and canceling is handled by core
	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 then return end
		local eventID = eventInfo.id
		local timerExact = eventInfo.duration
--		local timer = math.floor(timerExact + 0.5)
		if not badStateDetected then
			timersAll(self, timerExact, eventID)
		end
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventID or not eventState then return end
		local eventType, eventCount = self:TLCountFinish(eventID)
		if eventType and eventCount then
			if eventState == 1 and eventType == "void" then
				workaroundblizzardincompitence["void"] = true
				timerPhase:Start()
			elseif eventState == 2 then--Finished
				if eventType == "void" then
					specWarnEmptinessOfTheVoid:Show(L.name, eventCount)
					specWarnEmptinessOfTheVoid:Play("kickcast")
					workaroundblizzardincompitence["void"] = false
				elseif eventType == "imploding" then
					specWarnImplodingStrike:Show()
					specWarnImplodingStrike:Play("defensive")
					workaroundblizzardincompitence["imploding"] = false
				elseif eventType == "devouring" then
					warnDevouringEssence:Show(eventCount)
					workaroundblizzardincompitence["devouring"] = false
				end
			elseif eventState == 3 then--Canceled
				self:TLCountCancel(eventID)
			end
		end
	end
end
