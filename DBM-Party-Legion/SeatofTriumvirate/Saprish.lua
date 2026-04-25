local mod	= DBM:NewMod(1980, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(124872)
mod:SetEncounterID(2066)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local warnPhaseDash					= mod:NewCountAnnounce(1280064, 2)
	local warnShadowPounce				= mod:NewCountAnnounce(245738, 2)

	local specWarnVoidBomb				= mod:NewSpecialWarningCount(247175, nil, nil, nil, 1, 2)
	local specWarnOverload				= mod:NewSpecialWarningCount(1263523, nil, nil, nil, 2, 2)

	local timerVoidBombCD				= mod:NewCDCountTimer(20.5, 247175, nil, nil, nil, 3, nil, DBM_COMMON_L.IMPORTANT_ICON)
	local timerPhaseDashCD				= mod:NewCDCountTimer(20.5, 1280064, nil, nil, nil, 3)
	local timerShadowPounceCD			= mod:NewCDCountTimer(20.5, 245738, nil, nil, nil, 3)
	local timerOverloadCD				= mod:NewCDCountTimer(20.5, 1263523, nil, nil, nil, 2)

	mod:AddCustomAlertSoundOption(248831, "HasInterrupt", 2)--Dread Screech
	mod:AddPrivateAuraSoundOption(1280064, true, 1280064, 1, 1, "lineyou", 17)--Phase Dash
	mod:AddPrivateAuraSoundOption(245742, true, 245742, 2, 1, "targetyou", 2)--Shadow Pounce

	mod.vb.voidBombCount = 0
	mod.vb.phaseDashCount = 0
	mod.vb.shadowPounceCount = 0
	mod.vb.overloadCount = 0
	local overloadBuggedEventIDs = {}
	local state3FinishTolerance = 2
	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnVoidBomb:SetAlert(234, "bombsoon", 1, 2)
			specWarnOverload:SetAlert(243, "aesoon", 2, 2)
		end
		timerVoidBombCD:SetTimeline(234)
		timerPhaseDashCD:SetTimeline(235)
		timerShadowPounceCD:SetTimeline(237)
		timerOverloadCD:SetTimeline(243)
	end

	function mod:OnLimitedCombatStart()
		-- No timeline event exists for Dread Screech; keep legacy warning object
		self:EnableAlertOptions(248831, 236, "kickcast", 2, 2, 0)

		self:TLCountReset()
		overloadBuggedEventIDs = {}
		self.vb.voidBombCount = 1
		self.vb.phaseDashCount = 1
		self.vb.shadowPounceCount = 1
		self.vb.overloadCount = 1
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
		overloadBuggedEventIDs = {}
		self:UnregisterShortTermEvents()
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Logic confirmed against M+ only
			if timer == 4 or timer == 12 then--Shadow Pounce (opener 4s, regular 12s)
				timerShadowPounceCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "shadowpounce", "shadowPounceCount"))
			elseif timer == 6 or timer == 10 then--Void Bomb (short 6s, long 10s)
				timerVoidBombCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "voidbomb", "voidBombCount"))
			elseif timer == 20 then--Phase Dash
				timerPhaseDashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "phasedash", "phaseDashCount"))
			elseif timer == 32 then--Overload
				overloadBuggedEventIDs[eventID] = GetTime() + timerExact
				timerOverloadCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "overload", "overloadCount"))
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
				overloadBuggedEventIDs[eventID] = nil
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType and eventCount then
					if eventType == "voidbomb" then
						specWarnVoidBomb:Show(eventCount)
						specWarnVoidBomb:Play("bombsoon")
					elseif eventType == "phasedash" then
						warnPhaseDash:Show(eventCount)
					elseif eventType == "shadowpounce" then
						warnShadowPounce:Show(eventCount)
					elseif eventType == "overload" then
						specWarnOverload:Show(eventCount)
						specWarnOverload:Play("aesoon")
					end
				end
			elseif eventState == 3 then
				local expectedOverloadEnd = overloadBuggedEventIDs[eventID]
				if expectedOverloadEnd and math.abs(GetTime() - expectedOverloadEnd) <= state3FinishTolerance then
					overloadBuggedEventIDs[eventID] = nil
					local eventType, eventCount = self:TLCountFinish(eventID)
					if eventType == "overload" and eventCount then
						specWarnOverload:Show(eventCount)
						specWarnOverload:Play("aesoon")
					end
				else
					self:TLCountCancel(eventID)
				end
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 245802 248831",
		"SPELL_CAST_SUCCESS 247245",
		"SPELL_AURA_APPLIED 247245",
	--	"SPELL_AURA_REMOVED 247245",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, see if swoop/screech target can be identified
	--Void Hunter
	local warnUmbralFlanking				= mod:NewTargetAnnounce(247245, 3)
	local warnVoidTrap						= mod:NewSpellAnnounce(246026, 3, nil, nil, nil, nil, nil, 2)
	--local warnDreadScreech					= mod:NewCastAnnounce(248831, 2)

	--local specWarnHuntersRush				= mod:NewSpecialWarningDefensive(247145, nil, nil, nil, 1, 2)
	local specWarnOverloadTrap				= mod:NewSpecialWarningDodge(247206, nil, nil, nil, 2, 2)
	local specWarnUmbralFlanking			= mod:NewSpecialWarningMoveAway(247245, nil, nil, nil, 1, 2)
	local yellUmbralFlanking				= mod:NewYell(247245)
	local specWarnRavagingDarkness			= mod:NewSpecialWarningDodge(245802, nil, nil, nil, 2, 2)
	local specWarnDreadScreech				= mod:NewSpecialWarningInterrupt(248831, "HasInterrupt", nil, nil, 1, 2)

	local timerVoidTrapCD					= mod:NewCDTimer(15.8, 246026, nil, nil, nil, 3)
	local timerOverloadTrapCD				= mod:NewCDTimer(20.6, 247206, nil, nil, nil, 3)
	local timerRavagingDarknessCD			= mod:NewCDTimer(8.8, 245802, nil, nil, nil, 3)
	local timerUmbralFlankingCD				= mod:NewCDTimer(35.2, 247245, nil, nil, nil, 3)
	local timerScreechCD					= mod:NewCDTimer(15.4, 248831, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON)

	function mod:OnCombatStart(delay)
		timerRavagingDarknessCD:Start(5.5-delay)
		timerVoidTrapCD:Start(8.8-delay)
		timerOverloadTrapCD:Start(12.5-delay)
		timerUmbralFlankingCD:Start(20.4-delay)
		if self:IsHard() then
			--Stuff
			timerScreechCD:Start(6.2-delay)
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 245802 then
			specWarnRavagingDarkness:Show()
			specWarnRavagingDarkness:Play("watchstep")
			timerRavagingDarknessCD:Start()
		elseif spellId == 248831 then
			specWarnDreadScreech:Show(args.sourceName)
			specWarnDreadScreech:Play("kickcast")
			timerScreechCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 247245 then
			timerUmbralFlankingCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 247245 then
			warnUmbralFlanking:CombinedShow(0.3, args.destName)
			if args:IsPlayer() then
				specWarnUmbralFlanking:Show()
				specWarnUmbralFlanking:Play("scatter")
				yellUmbralFlanking:Yell()
			end
	--	elseif spellId == 247145 then
	--		if self:IsTanking("player", "boss1", nil, true) then
	--			specWarnHuntersRush:Show()
	--			specWarnHuntersRush:Play("defensive")
	--		end
		end
	end

	--[[
	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 247245 then

		end
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find("inv_misc_monsterhorn_03") then

		end
	end
	--]]

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 247175 then--Void Trap
			warnVoidTrap:Show()
			warnVoidTrap:Play("watchstep")
			timerVoidTrapCD:Start()
		elseif spellId == 247206 then--Overload Trap
			specWarnOverloadTrap:Show()
			specWarnOverloadTrap:Play("watchstep")
			timerOverloadTrapCD:Start()
		end
	end
end
