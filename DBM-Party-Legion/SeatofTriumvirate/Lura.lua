local mod	= DBM:NewMod(1982, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(124870)--124745 Greater Rift Warden
mod:SetEncounterID(2068)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local warnDiscordantbeam			= mod:NewCountAnnounce(1265426, 2)

	local specWarnDiscordantbeam		= mod:NewSpecialWarningBlizzYou(1265426, nil, nil, nil, 1, 19)
	local specWarnDirge					= mod:NewSpecialWarningCount(1265421, nil, nil, nil, 2, 2)
	local specWarnDisintegrate			= mod:NewSpecialWarningDodgeCount(1264151, nil, nil, nil, 2, 2)
	local specWarnGrimChorus			= mod:NewSpecialWarningCount(1265689, nil, nil, nil, 2, 2)
	local specWarnSymphony				= mod:NewSpecialWarningCount(1266003, nil, nil, nil, 3, 2)
	local specWarnBacklash				= mod:NewSpecialWarningCount(1266001, nil, nil, nil, 2, 2)

	local timerDirgeCD					= mod:NewCDCountTimer(20.5, 1265421, nil, nil, nil, 2)
	local timerDiscordantBeamCD			= mod:NewCDCountTimer(20.5, 1265426, nil, nil, nil, 3)
	local timerDisintegrateCD			= mod:NewCDCountTimer(20.5, 1264151, nil, nil, nil, 3)
	local timerGrimChorusCD				= mod:NewCDCountTimer(20.5, 1265689, nil, nil, nil, 2)
	local timerSymphonyCD				= mod:NewCastTimer(20.5, 1266003, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
	local timerBacklashCD				= mod:NewCastTimer(20.5, 1266001, nil, nil, nil, 2)

	--mod:AddPrivateAuraSoundOption(1265426, true, 1265426, 2, 1, "beamyou", 19)

	mod.vb.dirgeCount = 0
	mod.vb.discordantBeamCount = 0
	mod.vb.disintegrateCount = 0
	mod.vb.grimChorusCount = 0
	mod.vb.symphonyCount = 0
	mod.vb.backlashCount = 0
	-- Dirge of Despair and Symphony of the Eternal Night both have exact duration 1.5 (rounds to 2).
	-- Disambiguate by encounter-order counter: 1st=Dirge, 2nd=Symphony, 3rd+=Dirge resuming phase 2.
	local dur2Count = 0
	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnDiscordantbeam:SetAlert(250, "beamyou", 19, 2, 0)
			specWarnDirge:SetAlert(249, "aesoon", 2, 2)
			specWarnDisintegrate:SetAlert(251, "farfromline", 2, 2)
			specWarnGrimChorus:SetAlert(252, "stilldanger", 2, 2)
			specWarnSymphony:SetAlert(253, "watchstep", 3, 2)
			specWarnBacklash:SetAlert(254, "carefly", 2, 2)
		end
		timerDirgeCD:SetTimeline(249)
		timerDiscordantBeamCD:SetTimeline(250)
		timerDisintegrateCD:SetTimeline(251)
		timerGrimChorusCD:SetTimeline(252)
		timerSymphonyCD:SetTimeline(253)
		timerBacklashCD:SetTimeline(254)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		dur2Count = 0
		self.vb.dirgeCount = 1
		self.vb.discordantBeamCount = 1
		self.vb.disintegrateCount = 1
		self.vb.grimChorusCount = 1
		self.vb.symphonyCount = 1
		self.vb.backlashCount = 1
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
			if timer == 2 then--Dirge of Despair or Symphony (both exact 1.5s); alternates: odd=Dirge, even=Symphony
				dur2Count = dur2Count + 1
				if dur2Count % 2 == 1 then--odd occurrences (1, 3, 5...) = Dirge of Despair
					timerDirgeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "dirge", "dirgeCount"))
				else--even occurrences (2, 4, 6...) = Symphony of the Eternal Night
					timerSymphonyCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "symphony", "symphonyCount"))
				end
			elseif timer == 24 or timer == 17 then--Discordant Beam
				timerDiscordantBeamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "discordantbeam", "discordantBeamCount"))
			elseif timer == 12 or timer == 5 then--Disintegrate
				timerDisintegrateCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "disintegrate", "disintegrateCount"))
			elseif timer == 35 or timer == 28 then--Grim Chorus
				timerGrimChorusCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "grimchorus", "grimChorusCount"))
			elseif timer == 20 then--Backlash
				timerBacklashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "backlash", "backlashCount"))
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
					if eventType == "dirge" then
						specWarnDirge:Show(eventCount)
						specWarnDirge:Play("aesoon")
					elseif eventType == "discordantbeam" then
						warnDiscordantbeam:Show(eventCount)
						--Dispatch personal alert to fire on next ENCOUNTER_WARNING
						specWarnDiscordantbeam:Show(eventCount)
						specWarnDiscordantbeam:Play("beamyou")
					elseif eventType == "disintegrate" then
						specWarnDisintegrate:Show(eventCount)
						specWarnDisintegrate:Play("farfromline")
					elseif eventType == "grimchorus" then
						specWarnGrimChorus:Show(eventCount)
						specWarnGrimChorus:Play("stilldanger")
					elseif eventType == "symphony" then
						specWarnSymphony:Show(eventCount)
						specWarnSymphony:Play("watchstep")
					elseif eventType == "backlash" then
						specWarnBacklash:Show(eventCount)
						specWarnBacklash:Play("carefly")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 247795 245164 249009",
		"SPELL_CAST_SUCCESS 247930",
		"SPELL_AURA_APPLIED 247816 248535",
		"SPELL_AURA_REMOVED 247816"
	--	"CHAT_MSG_RAID_BOSS_EMOTE",
	--	"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, more timer work, with good english mythic or mythic+ transcriptor logs with start/stop properly used
	--TODO, start grand shift timer on phase 2 trigger on mythic/mythic+ only
	--TODO, RP timer
	local warnBacklash						= mod:NewTargetAnnounce(247816, 1)
	local warnNaarusLamen					= mod:NewTargetAnnounce(248535, 2)

	local specWarnCalltoVoid				= mod:NewSpecialWarningSwitch(247795, nil, nil, nil, 1, 2)
	local specWarnFragmentOfDespair			= mod:NewSpecialWarningSpell(245164, nil, nil, nil, 1, 2)
	local specWarnGrandShift				= mod:NewSpecialWarningDodge(249009, nil, nil, nil, 2, 2)

	--local timerCalltoVoidCD				= mod:NewAITimer(12, 247795, nil, nil, nil, 1)
	local timerGrandShiftCD					= mod:NewCDTimer(14.6, 249009, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON)
	local timerUmbralCadenceCD				= mod:NewCDTimer(10.9, 247930, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
	local timerBacklash						= mod:NewBuffActiveTimer(12.5, 247816, nil, nil, nil, 6)

	function mod:OnCombatStart(delay)
		self:SetStage(1)
		--timerCalltoVoidCD:Start(1-delay)--Done instantly
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 247795 then
			specWarnCalltoVoid:Show()
			specWarnCalltoVoid:Play("killmob")
			--timerCalltoVoidCD:Start()
		elseif spellId == 245164 and self:AntiSpam(3, 1) then
			specWarnFragmentOfDespair:Show()
			specWarnFragmentOfDespair:Play("helpsoak")
		elseif spellId == 249009 then
			specWarnGrandShift:Show()
			specWarnGrandShift:Play("watchstep")
			timerGrandShiftCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 247930 then
			timerUmbralCadenceCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 247816 then--Backlash
			warnBacklash:Show(args.destName)
			timerBacklash:Start()
			--Pause Timers?
		elseif spellId == 248535 then
			warnNaarusLamen:Show(args.destName)
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 247816 then--Backlash
			timerBacklash:Stop()
			--Resume timers?
		end
	end

	--[[
	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find("inv_misc_monsterhorn_03") then

		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 250011 then--Alleria Describes L'ura Conversation

		end
	end
	--]]
end
