local mod	= DBM:NewMod(1979, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(124871)
mod:SetEncounterID(2065)
mod:SetUsedIcons(1)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local warnDecimate					= mod:NewCountAnnounce(1263282, 2)

	local specWarnNullPalm				= mod:NewSpecialWarningCount(1268916, nil, nil, nil, 2, 2)
	local specWarnOozingSlam			= mod:NewSpecialWarningCount(1263399, nil, nil, nil, 2, 2)
	local specWarnVoidSlash				= mod:NewSpecialWarningCount(1263440, nil, nil, nil, 1, 2)
	local specWarnCrashingVoid			= mod:NewSpecialWarningCount(1263304, nil, nil, nil, 2, 2)

	local timerNullPalmCD				= mod:NewCDCountTimer(20.5, 1268916, nil, nil, nil, 3)
	local timerDecimateCD				= mod:NewCDCountTimer(20.5, 1263282, nil, nil, nil, 3)
	local timerOozingSlamCD				= mod:NewCDCountTimer(20.5, 1263399, nil, nil, nil, 1, nil, DBM_COMMON_L.MYTHIC_ICON)
	local timerVoidSlashCD				= mod:NewCDCountTimer(20.5, 1263440, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerCrashingVoidCD			= mod:NewCDCountTimer(20.5, 1263304, nil, nil, nil, 2)

	mod:AddPrivateAuraSoundOption(244588, true, 244588, 2, 1, "watchfeet", 8)--Void Sludge (GTFO)

	mod.vb.nullPalmCount = 0
	mod.vb.decimateCount = 0
	mod.vb.oozingSlamCount = 0
	mod.vb.voidSlashCount = 0
	mod.vb.crashingVoidCount = 0
	local badStateDetected = false

	---@param self DBMMod
	local function setFallback(self)
		specWarnNullPalm:SetAlert(223, "frontal", 15, 2)
		specWarnOozingSlam:SetAlert(225, "mobsoon", 2, 2)
		specWarnVoidSlash:SetAlert(226, "defensive", 2, 2)
		specWarnCrashingVoid:SetAlert(238, "pullin", 12, 2)
		timerNullPalmCD:SetTimeline(223)
		timerDecimateCD:SetTimeline(224)
		timerOozingSlamCD:SetTimeline(225)
		timerVoidSlashCD:SetTimeline(226)
		timerCrashingVoidCD:SetTimeline(238)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.nullPalmCount = 1
		self.vb.decimateCount = 1
		self.vb.oozingSlamCount = 1
		self.vb.voidSlashCount = 1
		self.vb.crashingVoidCount = 1
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
			if timer == 16 or timer == 103 then--Null Palm
				timerNullPalmCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "nullpalm", "nullPalmCount"))
			elseif timer == 7 or timer == 28 then--Decimate
				timerDecimateCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "decimate", "decimateCount"))
			elseif timer == 22 or timer == 102 then--Oozing Slam
				timerOozingSlamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "oozingslam", "oozingSlamCount"))
			elseif timer == 4 or timer == 40 then--Void Slash
				timerVoidSlashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "voidslash", "voidSlashCount"))
			elseif timer == 50 then--Crashing Void
				timerCrashingVoidCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "crashingvoid", "crashingVoidCount"))
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
					if eventType == "nullpalm" then
						specWarnNullPalm:Show(eventCount)
						specWarnNullPalm:Play("frontal")
					elseif eventType == "decimate" then
						warnDecimate:Show(eventCount)
					elseif eventType == "oozingslam" then
						specWarnOozingSlam:Show(eventCount)
						specWarnOozingSlam:Play("mobsoon")
					elseif eventType == "voidslash" then
						if self:IsTank() then
							specWarnVoidSlash:Show(eventCount)
							specWarnVoidSlash:Play("defensive")
						end
					elseif eventType == "crashingvoid" then
						specWarnCrashingVoid:Show(eventCount)
						specWarnCrashingVoid:Play("pullin")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 246134 244579",
		"SPELL_CAST_SUCCESS 244602",
		"SPELL_AURA_APPLIED 244657 244621",
		"SPELL_AURA_REMOVED 244657 244621",
		"SPELL_DAMAGE 244433",
	--	"CHAT_MSG_RAID_BOSS_EMOTE",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, more timer updates, warning tweaks, countdowns
	--TODO, personal alternate power and warn when extra action is ready to leave Umbra Shift
	--Void Brute
	--local warnNullPalm						= mod:NewSpellAnnounce(246134, 2, nil, "Tank")
	local warnUmbraShift					= mod:NewTargetAnnounce(244433, 3)
	local warnFixate						= mod:NewTargetAnnounce(244657, 3)
	local warnVoidTear						= mod:NewTargetAnnounce(244621, 1)

	local specWarnNullPalm					= mod:NewSpecialWarningDodge(246134, nil, nil, 2, 2, 2)
	local specWarnCoalescedVoid				= mod:NewSpecialWarningSwitch(244602, "Dps", nil, nil, 1, 2)
	local specWarnUmbraShift				= mod:NewSpecialWarningYou(244433, nil, nil, nil, 1, 5)
	local specWarnFixate					= mod:NewSpecialWarningRun(244657, nil, nil, nil, 4, 2)

	local timerNullPalmCD					= mod:NewCDTimer(10.9, 246134, nil, nil, nil, 3)
	local timerDeciminateCD					= mod:NewCDTimer(12.1, 244579, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerCoalescedVoidCD				= mod:NewCDTimer(12.1, 244602, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerUmbraShiftCD					= mod:NewCDTimer(12, 244433, nil, nil, nil, 6)
	local timerVoidTear						= mod:NewBuffActiveTimer(20, 244621, nil, nil, nil, 6)

	mod:AddSetIconOption("SetIconOnFixate", 244657, true, 0, {1})

	function mod:OnCombatStart(delay)
		timerNullPalmCD:Start(10-delay)
		timerDeciminateCD:Start(17.5-delay)
		timerCoalescedVoidCD:Start(19.5-delay)
		timerUmbraShiftCD:Start(40.5-delay)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 246134 then
			specWarnNullPalm:Show()
			specWarnNullPalm:Play("shockwave")
			timerNullPalmCD:Start()
		elseif spellId == 244579 then
			timerDeciminateCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 244602 then
			specWarnCoalescedVoid:Show()
			specWarnCoalescedVoid:Play("killmob")
			--timerCoalescedVoidCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 244657 then
			if args:IsPlayer() then
				specWarnFixate:Show()
				specWarnFixate:Play("justrun")
				specWarnFixate:ScheduleVoice(1, "keepmove")
			else
				warnFixate:Show(args.destName)
			end
			if self.Options.SetIconOnFixate then
				self:SetIcon(args.destName, 1)
			end
		elseif spellId == 244621 then--Void Tear
			warnVoidTear:Show(args.destName)
			timerVoidTear:Start()
			--Cancel Timers
			timerNullPalmCD:Stop()
			timerDeciminateCD:Stop()
			timerCoalescedVoidCD:Stop()
			timerUmbraShiftCD:Stop()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 244657 then
			if self.Options.SetIconOnFixate then
				self:SetIcon(args.destName, 0)
			end
		elseif spellId == 244621 then--Void Tear
			--Resume timers (TODO, need log, for heroic the boss died with this buff)
			--timerNullPalmCD:Start(10)
			--timerDeciminateCD:Start(17.5)
			--timerCoalescedVoidCD:Start(19.5)
			--timerUmbraShiftCD:Start(40.5)
		end
	end

	function mod:SPELL_DAMAGE(_, _, _, destName, destGUID, _, _, _, spellId)
		if spellId == 244433 then
			if destGUID == UnitGUID("player") then
				specWarnUmbraShift:Show()
				specWarnUmbraShift:Play("teleyou")
			else
				warnUmbraShift:Show(destName)
			end
		end
	end

	--[[
	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find("inv_misc_monsterhorn_03") then

		end
	end
	--]]

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 247576 then--Umbra Shift
			--timerUmbraShiftCD:Start()
		end
	end
end
