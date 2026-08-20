local mod	= DBM:NewMod(2503, "DBM-Party-Dragonflight", 7, 1202)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(190484, 190485)
mod:SetEncounterID(2623)
mod:SetZone(2521)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20230109000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--TODO, infernospit has two IDs, 381602 for timer and 381605 for debuff alert an one is cast alert (889 vs 894).
	--local warnWindsofChange						= mod:NewCountAnnounce(381517, 3)--Not actually a count timer, but has best localized text (disabled until hardcode)

	local specWarnInfernoSpit						= mod:NewSpecialWarningBlizzYou(381602, nil, nil, nil, 2, 18, nil, nil, "poolyou")--381605
	local specWarnRoaringFirebreath					= mod:NewSpecialWarningDodge(381525, nil, nil, nil, 2, 2, nil, nil, "breathsoon")
	local specWarnStormslam							= mod:NewSpecialWarningDefensive(381512, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnInterruptingCloudburst			= mod:NewSpecialWarningCast(381516, "SpellCaster", nil, nil, 2, 2, 4, nil, "stopcast")

	local timerInfernoSpitCD						= mod:NewCDCountTimer(0, 381602, nil, nil, nil, 2)
	local timerRoaringFirebreathCD					= mod:NewCDCountTimer(0, 381525, nil, nil, nil, 3)
	local timerWindsofChangeCD						= mod:NewCDCountTimer(0, 381517, nil, nil, nil, 3)
	local timerStormslamCD							= mod:NewCDCountTimer(0, 381512, nil, "Tank|RemoveMagic|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.MAGIC_ICON)
	local timerInterruptingCloudburstCD				= mod:NewCDCountTimer(0, 381516, nil, nil, nil, 2, nil, DBM_COMMON_L.MYTHIC_ICON)

--	mod:AddAuraSoundOption(381862, true, 381602, 1, 1, "poolyou", 18, 0)--Infernospit Debuff (ENCOUNTER_WARNING intercept is used)
	mod:AddAuraSoundOption(384773, true, 384773, 1, 2, "watchfeet", 8, 0)--Flaming Embers

	local badStateDetected = false
	local nextTwentyIsFirebreath = true
	local nextSixteenIsFirebreath = true
	local windsEventIDs = {}
	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnInfernoSpit:SetAlert({889, 894}, "poolyou", 18, 2, 0)
			specWarnRoaringFirebreath:SetAlert(890, "breathsoon", 2)
			if self:IsTank() then
				specWarnStormslam:SetAlert(888, "defensive", 2)
			end
			if self:IsSpellCaster() then
				specWarnInterruptingCloudburst:SetAlert(885, "stopcast", 2)
			end
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerInfernoSpitCD:SetTimeline({889, 894}, onlyColor)
		timerRoaringFirebreathCD:SetTimeline(890, onlyColor)
		timerWindsofChangeCD:SetTimeline(887, onlyColor)
		timerStormslamCD:SetTimeline(888, onlyColor)
		timerInterruptingCloudburstCD:SetTimeline(885, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self:TLBatchReset()
		self:SetStage(1)
		self.vb.infernospitCount = 1
		self.vb.firebreathCount = 1
		self.vb.stormslamCount = 1
		self.vb.windsCount = 1
		self.vb.cloudburstCount = 1
		nextTwentyIsFirebreath = true
		nextSixteenIsFirebreath = true
		windsEventIDs = {}
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents("ENCOUNTER_TIMELINE_EVENT_ADDED", "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
			setFallback(self, true)
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		self:TLBatchReset()
		windsEventIDs = {}
		self:UnregisterShortTermEvents()
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		if eventInfo.source ~= 0 or eventInfo.duration == 0 or badStateDetected then return end
		local eventID = eventInfo.id
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if eventState ~= 0 then return end
		--Transition batches can resend an active event ID with a new positive duration.
		if self:TLBatchTrackLatest(eventID, eventID) == eventID then return end
		local timerExact = eventInfo.duration
		local timer = math.floor(timerExact + 0.5)
		local handled = false
		if self:GetStage(1) then
			if timer == 1 or (timer == 20 and nextTwentyIsFirebreath) then
				if timer == 20 then
					nextTwentyIsFirebreath = false
				end
				timerRoaringFirebreathCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "firebreath", "firebreathCount"))
				handled = true
			elseif timer == 5 or timer == 23 then
				timerStormslamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "stormslam", "stormslamCount"))
				handled = true
			elseif timer == 10 or timer == 22 then
				windsEventIDs[eventID] = true
				timerWindsofChangeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "winds", "windsCount"))
				handled = true
			elseif timer == 12 or (timer == 20 and not nextTwentyIsFirebreath) then
				if timer == 20 then
					nextTwentyIsFirebreath = true
				end
				timerInfernoSpitCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "infernospit", "infernospitCount"))
				handled = true
			elseif timer == 21 or timer == 25 then
				timerInterruptingCloudburstCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "cloudburst", "cloudburstCount"))
				handled = true
			end
		else
			if timer == 5 or (timer == 16 and nextSixteenIsFirebreath) then
				if timer == 16 then
					nextSixteenIsFirebreath = false
				end
				timerRoaringFirebreathCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "firebreath", "firebreathCount"))
				handled = true
			elseif timer == 13 or (timer == 16 and not nextSixteenIsFirebreath) then
				if timer == 16 then
					nextSixteenIsFirebreath = true
				end
				timerInfernoSpitCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "infernospit", "infernospitCount"))
				handled = true
			elseif timer == 22 then
				windsEventIDs[eventID] = true
				timerWindsofChangeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "winds", "windsCount"))
				handled = true
			elseif timer == 23 then
				timerStormslamCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "stormslam", "stormslamCount"))
				handled = true
			elseif timer == 25 then
				timerInterruptingCloudburstCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "cloudburst", "cloudburstCount"))
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

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		local eventState = C_EncounterTimeline.GetEventState(eventID)
		if not eventState then return end
		self:TLBatchUntrack(eventID)
		if eventState == 2 then
			local eventType, eventCount = self:TLCountFinish(eventID)
			if eventType == "infernospit" and eventCount then
				specWarnInfernoSpit:Show(eventCount, "poolyou", 5)
			elseif eventType == "firebreath" and eventCount then
				specWarnRoaringFirebreath:Show()
				specWarnRoaringFirebreath:Play("breathsoon")
			elseif eventType == "stormslam" and eventCount then
				if self:IsTank() then
					specWarnStormslam:Show()
					specWarnStormslam:Play("defensive")
				end
			elseif eventType == "cloudburst" and eventCount and self:IsSpellCaster() then
				specWarnInterruptingCloudburst:Show()
				specWarnInterruptingCloudburst:Play("stopcast")
			end
		elseif eventState == 3 then
			if windsEventIDs[eventID] and self:GetStage(1) then
				self:SetStage(2)
			end
			self:TLCountCancel(eventID)
		end
		windsEventIDs[eventID] = nil
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 381605 381602 381525 381517 381512 385558 381516",
		"SPELL_CAST_SUCCESS 381517",
		"SPELL_AURA_APPLIED 381515 181089 381862",
		"UNIT_DIED"
	)

	--[[
	(ability.id = 381605 or ability.id = 381602 or ability.id = 381525 or ability.id = 381517 or ability.id = 381512 or ability.id = 385558 or ability.id = 381516) and type = "begincast"
	 or type = "death" and (target.id = 193435 or target.id = 190484 or target.id = 190485)
	 or ability.id = 181089
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	DBM:RegisterAltSpellName(381517, 227878)--Winds of Change -> Winds
	--Kyrakka
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(25365))
	local warnFlamespit								= mod:NewTargetNoFilterAnnounce(381605, 3)
	local warnInfernoCore							= mod:NewYouAnnounce(381862, 4)

	local yellFlamespit								= mod:NewYell(381605)
	local specWarnInfernoCore						= mod:NewSpecialWarningMoveAway(381862, nil, nil, nil, 1, 2, nil, nil, "runout")
	local specWarnRoaringFirebreath					= mod:NewSpecialWarningDodge(381525, nil, nil, nil, 2, 2, nil, nil, "breathsoon")

	local timerFlamespitCD							= mod:NewCDTimer(15.7, 381605, nil, nil, nil, 3)
	local timerRoaringFirebreathCD					= mod:NewCDTimer(18, 381525, nil, nil, nil, 3)
	--Erkhart Stormvein
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(25369))
	local warnWindsofChange							= mod:NewCountAnnounce(381517, 3)--Not actually a count timer, but has best localized text
	local warnCloudburst							= mod:NewSpellAnnounce(385558, 3)

	local specWarnStormslam							= mod:NewSpecialWarningDefensive(381512, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnStormslamDispel					= mod:NewSpecialWarningDispel(381512, "RemoveMagic", nil, nil, 1, 2, nil, nil, "helpdispel")
	local specWarnInterruptingCloudburst			= mod:NewSpecialWarningCast(381516, "SpellCaster", nil, nil, 2, 2, 4, nil, "stopcast")

	local timerWindsofChangeCD						= mod:NewCDCountTimer(15.8, 381517, nil, nil, nil, 3)
	local timerStormslamCD							= mod:NewCDTimer(17, 381512, nil, "Tank|RemoveMagic", nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.MAGIC_ICON)
	local timerCloudburstCD							= mod:NewCDTimer(18.8, 385558, nil, nil, nil, 2)--Used for both mythic and non mythic versions of spell

	mod:AddInfoFrameOption(381862, false)--Infernocore

	mod.vb.windDirection = 0
	mod.vb.mainGUID = nil
	mod.vb.dragonAlive = true

	function mod:SpitTarget(targetname)
		if not targetname then return end
		warnFlamespit:Show(targetname)
		if targetname == UnitName("player") then
			yellFlamespit:Yell()
		end
	end

	--Count started at 0 because count is incremented in success event not start
	local directions = {
		[0] = L.North,
		[1] = L.West,
		[2] = L.South,
		[3] = L.East
	}

	local function scanBosses(self, delay)
		for i = 1, 2 do
			local unitID = "boss"..i
			if UnitExists(unitID) then
				local cid = self:GetUnitCreatureId(unitID)
				local bossGUID = UnitGUID(unitID)
				if cid == 190484 then--Kyrakka
					timerRoaringFirebreathCD:Start(1.1-delay, bossGUID)
					timerFlamespitCD:Start(16.1-delay, bossGUID)--17-24?
				else--Erkhart Stormvein
					self.vb.mainGUID = bossGUID
					timerStormslamCD:Start(4-delay, bossGUID)
					timerCloudburstCD:Start(8.4-delay, bossGUID)
				end
			end
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.windDirection = 0
		self:SetStage(1)
		timerWindsofChangeCD:Start(17.1-delay, L.North)
		self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss guids
		self.vb.dragonAlive = true
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(DBM:GetSpellName(381862))
			DBM.InfoFrame:Show(5, "playerdebuffremaining", 381862)
		end
	end

	function mod:OnCombatEnd()
		self.vb.mainGUID = nil
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 381605 or spellId == 381602 then--One is for bosses split and one is for bosses combined.
			self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "SpitTarget", 0.1, 8, true)
			timerFlamespitCD:Start(self:GetStage(1) and 21.1 or 15, args.sourceGUID)
		elseif spellId == 381525 then
			specWarnRoaringFirebreath:Show()
			specWarnRoaringFirebreath:Play("breathsoon")
			timerRoaringFirebreathCD:Start(18, args.sourceGUID)--18-27
		elseif spellId == 381517 then
			---@diagnostic disable-next-line: param-type-mismatch
			warnWindsofChange:Show(directions[self.vb.windDirection])
		elseif spellId == 381512 then
			if self:IsTanking("player", nil, nil, true, args.sourceGUID) then--Using GUID check because might be boss1 or boss2
				specWarnStormslam:Show()
				specWarnStormslam:Play("defensive")
			end
			timerStormslamCD:Start(nil, args.sourceGUID)--self:GetStage(1) and 10 or 14
		elseif spellId == 385558 or spellId == 381516 then
			if spellId == 381516 and self.Options.SpecWarn381516cast then--Mythic
				specWarnInterruptingCloudburst:Show()
				specWarnInterruptingCloudburst:Play("stopcast")
			else--Normal/Heroic
				warnCloudburst:Show()
			end
			timerCloudburstCD:Start(nil, args.sourceGUID)
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 381517 then--Here because boss can stutter cast and start cast over
			self.vb.windDirection = self.vb.windDirection + 1
			if self.vb.windDirection == 4 then
				self.vb.windDirection = 0
			end
			timerWindsofChangeCD:Start(nil, directions[self.vb.windDirection])
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 381515 and self:CheckDispelFilter("magic") then
			specWarnStormslamDispel:Show(args.destName)
			specWarnStormslamDispel:Play("helpdispel")
		elseif spellId == 181089 then
			self:SetStage(2)
			--Timers reset by staging
			if self.vb.dragonAlive and self:AntiSpam(3, 1) then--Erkhart
				--restart apparently broken here (because of GUID?)
				--Manually stop/start
				timerFlamespitCD:Stop()
				timerFlamespitCD:Start(3.5, UnitGUID)
				timerRoaringFirebreathCD:Stop()
				timerRoaringFirebreathCD:Start(9.6, UnitGUID)
			end
			--Rest not reset
		elseif spellId == 381862 and args:IsPlayer() then
			if self.Options.SpecWarn381862moveaway and self:AntiSpam(3, 2) then
				specWarnInfernoCore:Show()
				specWarnInfernoCore:Play("runout")
			else
				warnInfernoCore:Show()
			end
		end
	end

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 190484 then--Kyrakka
			self.vb.dragonAlive = false
			timerFlamespitCD:Stop(args.destGUID)
			timerRoaringFirebreathCD:Stop(args.destGUID)
			if self.vb.mainGUID then
				--In season 4, bosses cloudburst Cd resets on dragon death, he basically instant casts it even if it was JUST cast
				timerCloudburstCD:Stop(self.vb.mainGUID)
			end
		elseif cid == 190485 then--Erkhart
			timerWindsofChangeCD:Stop(args.destGUID)
			timerStormslamCD:Stop(args.destGUID)
			timerCloudburstCD:Stop(args.destGUID)
		end
	end
end
