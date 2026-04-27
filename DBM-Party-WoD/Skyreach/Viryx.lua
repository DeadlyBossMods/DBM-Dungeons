local mod	= DBM:NewMod(968, "DBM-Party-WoD", 7, 476)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(76266)
mod:SetEncounterID(1701)
mod:SetUsedIcons(1)

mod:RegisterCombat("combat")

--NOTE: Solar Blast alternates between 12 and 27 second cd
if DBM:IsPostMidnight() then
	local warnScorchingRay			= mod:NewCountAnnounce(1253538, 2)
	local warnLensFlare				= mod:NewCountAnnounce(1253531, 2)
	local warnCastDown				= mod:NewBlizzTargetAnnounce(1253998, 4)

	local specWarnCastDown			= mod:NewSpecialWarningCount(1253998, nil, nil, DBM_COMMON_L.ADD, 1, 2)
	local specWarnSolarBlast		= mod:NewSpecialWarningInterruptCount(154396, "HasInterrupt", nil, nil, 1, 2)

	local timerScorchingRayCD		= mod:NewCDCountTimer(20.5, 1253538, nil, nil, nil, 3)
	local timerCastDownCD			= mod:NewCDCountTimer(20.5, 1253998, DBM_COMMON_L.ADD.." (%s)", nil, nil, 1, nil, DBM_COMMON_L.IMPORTANT_ICON..DBM_COMMON_L.DAMAGE_ICON)
	local timerSolarBlastCD			= mod:NewCDCountTimer(20.5, 154396, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	local timerLensFlareCD			= mod:NewCDCountTimer(20.5, 1253531, nil, nil, nil, 3)

	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1253541, true, 1253541, 1, 1, "debuffyou", 17)--Scorching Ray
	--mod:AddPrivateAuraSoundOption(153954, true, 1253998, 1, 1, "targetyou", 2)--Cast Down (no longer a private aura post 4-14-26 hotfixes
	mod:AddPrivateAuraSoundOption(1253531, true, 1253531, 1, 1, "laserrun", 2)--Lens Flare

	mod.vb.scorchingRayCount = 0
	mod.vb.castDownCount = 0
	mod.vb.solarBlastCount = 0
	mod.vb.lensFlareCount = 0
	local nextTwelveIsCastDown = true
	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnCastDown:SetAlert(310, "targetchange", 2, 2)
			specWarnSolarBlast:SetAlert(311, "kickcast", 2, 2)
		end
		timerScorchingRayCD:SetTimeline(309)
		timerCastDownCD:SetTimeline(310)
		timerSolarBlastCD:SetTimeline(311)
		timerLensFlareCD:SetTimeline(312)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.scorchingRayCount = 1
		self.vb.castDownCount = 1
		self.vb.solarBlastCount = 1
		self.vb.lensFlareCount = 1
		nextTwelveIsCastDown = true
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
			if timer == 5 or timer == 10 then--Scorching Ray
				timerScorchingRayCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "scorchingRay", "scorchingRayCount"))
			elseif timer == 8 then--Solar Blast
				timerSolarBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "solarBlast", "solarBlastCount"))
			elseif timer == 30 then--Lens Flare
				timerLensFlareCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lensFlare", "lensFlareCount"))
			elseif timer == 12 then--Cast Down or Solar Blast
				if nextTwelveIsCastDown then
					timerCastDownCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "castDown", "castDownCount"))
				else
					timerSolarBlastCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "solarBlast", "solarBlastCount"))
				end
				nextTwelveIsCastDown = not nextTwelveIsCastDown
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
					if eventType == "scorchingRay" then
						warnScorchingRay:Show(eventCount)
					elseif eventType == "castDown" then
						warnCastDown:Show(eventCount)
						specWarnCastDown:Show(eventCount)
						specWarnCastDown:Play("targetchange")
					elseif eventType == "solarBlast" then
						specWarnSolarBlast:Show(L.name, eventCount)
						specWarnSolarBlast:Play("kickcast")
					elseif eventType == "lensFlare" then
						warnLensFlare:Show(eventCount)
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 154055",
		"SPELL_CAST_START 154055",
		"SPELL_PERIODIC_DAMAGE 154043",
		"SPELL_ABSORBED 154043",
		"UNIT_DIED",
		"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3 boss4 boss5"--On a bad pull you can very much have 3-4 adds.
	)

	--TODO, had bugged transcriptor so no IEEU events. See if IEEU is better for adds joining fight.
	local warnCastDown			= mod:NewTargetNoFilterAnnounce(153954, 4)
	local warnShielding			= mod:NewTargetNoFilterAnnounce(154055, 2)

	local specWarnCastDownSoon	= mod:NewSpecialWarningSoon(153954, nil, nil, nil, 1, 2)--Everyone, becaus it can grab healer too, which affects healer/tank
	local specWarnCastDown		= mod:NewSpecialWarningSwitch(153954, "Dps", nil, nil, 3, 2)--Only dps, because it's their job to stop it.
	local specWarnLensFlareCast	= mod:NewSpecialWarningSpell(154043, nil, nil, nil, 2, 2)--If there is any way to find actual target, like maybe target scanning, this will be changed.
	local specWarnLensFlare		= mod:NewSpecialWarningGTFO(154043, nil, nil, nil, 1, 8)
	local specWarnAdd			= mod:NewSpecialWarning("specWarnAdd", "Dps", nil, nil, 1, 2)
	local specWarnShielding		= mod:NewSpecialWarningInterrupt(154055, "HasInterrupt", nil, 2, 1, 2)

	local timerLenseFlareCD		= mod:NewCDTimer(38, 154043, nil, nil, nil, 3)
	local timerCastDownCD		= mod:NewCDTimer(28, 153954, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)

	mod:AddSetIconOption("SetIconOnCastDown", 153954, true, 0, {1})

	mod.vb.lastGrab = nil
	local skyTrashMod = DBM:GetModByName("SkyreachTrash")

	function mod:CastDownTarget(targetname, uId)
		if not targetname then return end
		self.vb.lastGrab = targetname
		warnCastDown:Show(self.vb.lastGrab)
		if self.Options.SetIconOnCastDown then
			self:SetIcon(self.vb.lastGrab, 1)
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.lastGrab = nil
		timerCastDownCD:Start(15-delay)
		timerLenseFlareCD:Start(27.3-delay)
		if skyTrashMod and skyTrashMod.Options.RangeFrame and skyTrashMod.vb.debuffCount ~= 0 then--In case of bug where range frame gets stuck open from trash pulls before this boss.
			skyTrashMod.vb.debuffCount = 0--Fix variable
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 154055 then
			warnShielding:Show(args.destName)
		end
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 154055 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnShielding:Show(args.sourceName)
			specWarnShielding:Play("kickcast")
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 154043 and destGUID == UnitGUID("player") and self:AntiSpam(2) then
			specWarnLensFlare:Show(spellName)
			specWarnLensFlare:Play("watchfeet")
		end
	end
	mod.SPELL_ABSORBED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 76267 then--Solar Zealot
			if self.Options.SetIconOnCastDown and self.vb.lastGrab then
				self:SetIcon(self.vb.lastGrab, 0)
				self.vb.lastGrab = nil
			end
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 153954 then--Cast Down (4-5 sec before pre warning)
			specWarnCastDownSoon:Show()
			self:BossTargetScanner(76266, "CastDownTarget", 0.05, 15)
			specWarnCastDownSoon:Play("mobsoon")
		elseif spellId == 165834 then--Force Demon Creator to Ride Me
			--TODO, see if victom detectable here instead
			timerCastDownCD:Start()
			if self.vb.lastGrab and self.vb.lastGrab ~= UnitName("player") then
				specWarnCastDown:Show()
				specWarnCastDown:Play("helpme")
				specWarnCastDown:ScheduleVoice(2, "helpme2")
			end
		elseif spellId == 154049 then-- Call Adds
			specWarnAdd:Show()
			specWarnAdd:Play("killmob")
		elseif spellId == 154032 then--Actual Lens Flare cast. 154043 is not cast, despite SUCCESS event. It only fires if beam makes contact with a player. Then SPELL_CAST_SUCCESS and SPELL_AURA_APPLIED fire
			specWarnLensFlareCast:Show()
			specWarnLensFlareCast:Play("watchstep")
			timerLenseFlareCD:Start()
		end
	end
end
