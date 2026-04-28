local mod	= DBM:NewMod(966, "DBM-Party-WoD", 7, 476)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(76141)
mod:SetEncounterID(1699)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local specWarnFierySmash	= mod:NewSpecialWarningCount(154115, nil, nil, nil, 1, 15)
	local specWarnEnergize		= mod:NewSpecialWarningCount(154162, nil, nil, DBM_COMMON_L.GROUPSOAKS, 1, 17)
	local specWarnSupernova		= mod:NewSpecialWarningCount(154135, nil, nil, nil, 2, 2)

	local timerSmashCD			= mod:NewCDCountTimer(20.5, 154115, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerEnergizeCD		= mod:NewCDCountTimer(20.5, 154162, DBM_COMMON_L.GROUPSOAKS.." (%s)", nil, nil, 5, nil, DBM_COMMON_L.IMPORTANT_ICON)
	local timerSupernovaCD		= mod:NewCDCountTimer(20.5, 154135, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

	mod:AddPrivateAuraSoundOption(154132, true, 154115, 1, 3, "screwup", 18)--Failing at smash

	mod.vb.smashCount = 0
	mod.vb.energizeCount = 0
	mod.vb.supernovaCount = 0
	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			if self:IsTank() then
				specWarnFierySmash:SetAlert(302, "frontal", 15, 1)
			end
			if not self:IsTank() then
				--Tank frontals are cast during soak
				--so do NOT tell tank to help with the soaking
				specWarnEnergize:SetAlert(303, "soakbeam", 17, 1)
			end
			specWarnSupernova:SetAlert(304, "aesoon", 2, 2)
		end
		timerSmashCD:SetTimeline(302)
		timerEnergizeCD:SetTimeline(303)
		timerSupernovaCD:SetTimeline(304)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.smashCount = 1
		self.vb.energizeCount = 1
		self.vb.supernovaCount = 1
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
		self:UnregisterShortTermEvents()
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			if timer == 5 or timer == 10 or timer == 15 then--Fiery Smash
				timerSmashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "smash", "smashCount"))
			elseif timer == 6 or timer == 24 then--Energize
				timerEnergizeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "energize", "energizeCount"))
			elseif timer == 50 then--Supernova
				timerSupernovaCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "supernova", "supernovaCount"))
			else
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
					if eventType == "smash" then
						if self:IsTank() then
							specWarnFierySmash:Show(eventCount)
							specWarnFierySmash:Play("frontal")
						end
					elseif eventType == "energize" then
						if not self:IsTank() then
							specWarnEnergize:Show(eventCount)
							specWarnEnergize:Play("soakbeam")
						end
					elseif eventType == "supernova" then
						specWarnSupernova:Show(eventCount)
						specWarnSupernova:Play("aesoon")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 154110 154113 154135",
		"SPELL_AURA_APPLIED 154159"
	)


	--Add smash? it's a 1 sec cast, can it be dodged?
	local warnEnergize		= mod:NewSpellAnnounce(154159, 3)

	local specWarnBurst		= mod:NewSpecialWarningCount(154135, nil, nil, nil, 2, 2)
	local specWarnSmash		= mod:NewSpecialWarningDodge(154110, "Tank", nil, 2, 1, 2)

	local timerEnergozeCD	= mod:NewNextTimer(20, 154159, nil, nil, nil, 5)
	local timerBurstCD		= mod:NewCDCountTimer(23, 154135, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

	mod.vb.burstCount = 0

	function mod:OnCombatStart(delay)
		self.vb.burstCount = 0
		timerBurstCD:Start(20-delay, 1)
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 154135 then
			self.vb.burstCount = self.vb.burstCount + 1
			specWarnBurst:Show(self.vb.burstCount)
			specWarnBurst:Play("aesoon")
			timerBurstCD:Start(nil, self.vb.burstCount+1)
		elseif args:IsSpellID(154110, 154113) then
			specWarnSmash:Show()
			specWarnSmash:Play("watchstep")
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 154159 and self:AntiSpam(2, 1) then
			warnEnergize:Show()
			timerEnergozeCD:Start()
		end
	end
end
