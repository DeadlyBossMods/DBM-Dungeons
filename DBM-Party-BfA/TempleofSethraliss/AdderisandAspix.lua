local mod	= DBM:NewMod(2142, "DBM-Party-BfA", 6, 1030)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(133379, 133944)
mod:SetEncounterID(2124)
mod:SetUsedIcons(8)
mod:SetZone(1877)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--Aspix
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18484))

	local specWarnThunderandLightning	= mod:NewSpecialWarningBlizzTarget(1288049, nil, nil, nil, 1, 2, nil, nil, "helpsoak")
	local specWarnOverload				= mod:NewSpecialWarningDefensive(1311804, nil, nil, nil, 1, 2, nil, nil, "defensive")

	local timerThunderandLightningCD	= mod:NewCDCountTimer(30, 1288049, nil, nil, nil, 3)
	local timerOverloadCD				= mod:NewCDCountTimer(30, 1311804, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

	mod:AddAuraSoundOption(1288074, true, 1288049, 1, 1, "gathershare", 2, 0)--Thunder and Lightning

	--Adderis
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18485))

	local specWarnTempestWinds				= mod:NewSpecialWarningBlizzYou(1311805, nil, nil, nil, 2, 18, nil, nil, "poolyou")
	local specWarnGaleForce					= mod:NewSpecialWarningBlizzYou(1289059, nil, nil, nil, 1, 13, nil, nil, "pushbackincoming")

	local timerTempestWindsCD				= mod:NewCDCountTimer(30, 1311805, nil, nil, nil, 3)
	local timerGaleForceCD					= mod:NewCDCountTimer(30, 1289059, nil, nil, nil, 3)

	--mod:AddAuraSoundOption(1289754, true, 1311805, 1, 1, "poolyou", 18, 0)--Tempest Winds (iffy, wasn't combat logged)

	mod.vb.thunderAndLightningCount = 0
	mod.vb.overloadCount = 0
	mod.vb.tempestWindsCount = 0
	mod.vb.galeForceCount = 0
	local badStateDetected = false
	local nextFortyTwoTimer = 1
	local nextNineteenTimer = 1
	local adderisDead = false
	local aspixDead = false
	local activeEventByType = {}
	local batchTimerValues = {
		[1] = true,
		[4] = true,
		[21] = true,
		[31] = true,
	}

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnThunderandLightning:SetAlert({689,720}, "helpsoak", 2, 2)--Group notifier?
			--specWarnThunderandLightning:SetAlert(720, "gathershare", 2, 4, 0)--Personal notifier?
			if self:IsTank() then
				specWarnOverload:SetAlert(690, "defensive", 2, 2)
			end
			specWarnTempestWinds:SetAlert({691,713}, "watchstep", 2, 2, 0)
			specWarnGaleForce:SetAlert({692,718}, "pushbackincoming", 2, 3, 0)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerThunderandLightningCD:SetTimeline({689,720}, onlyColor)
		timerOverloadCD:SetTimeline(690, onlyColor)
		timerTempestWindsCD:SetTimeline({691,713}, onlyColor)
		timerGaleForceCD:SetTimeline({692,718}, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self:TLBatchReset()
		self.vb.thunderAndLightningCount = 1
		self.vb.overloadCount = 1
		self.vb.tempestWindsCount = 1
		self.vb.galeForceCount = 1
		nextFortyTwoTimer = 1
		nextNineteenTimer = 1
		adderisDead = false
		aspixDead = false
		activeEventByType = {}
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
		activeEventByType = {}
		self:UnregisterShortTermEvents()
	end

	do
		local fortyTwoTimers = {
			"galeForce",
			"thunderAndLightning",
			"tempestWinds",
			"overload",
		}

		local function startTimer(self, timerObject, timerExact, eventID, eventType, countKey)
			activeEventByType[eventType] = eventID
			timerObject:TLStart(timerExact, eventID, self:TLCountStart(eventID, eventType, countKey))
		end

		local function startBatchTimer(self, timer, timerObject, timerExact, eventID, eventType, countKey)
			if self:TLBatchStart(timer, timerObject, timerExact, eventID, eventType, countKey, batchTimerValues) then
				activeEventByType[eventType] = eventID
			end
		end

		local function timersAll(self, timer, timerExact, eventID)
			if timer == 42 then
				--Every transition resumes this four-event batch in this fixed order.
				local eventType = fortyTwoTimers[nextFortyTwoTimer]
				nextFortyTwoTimer = nextFortyTwoTimer % #fortyTwoTimers + 1
				if eventType == "galeForce" then
					startTimer(self, timerGaleForceCD, timerExact, eventID, eventType, "galeForceCount")
				elseif eventType == "thunderAndLightning" then
					startTimer(self, timerThunderandLightningCD, timerExact, eventID, eventType, "thunderAndLightningCount")
				elseif eventType == "tempestWinds" then
					startTimer(self, timerTempestWindsCD, timerExact, eventID, eventType, "tempestWindsCount")
				else
					startTimer(self, timerOverloadCD, timerExact, eventID, eventType, "overloadCount")
				end
			elseif timer == 9 or timer == 4 then
				adderisDead = false
				startBatchTimer(self, timer, timerThunderandLightningCD, timerExact, eventID, "thunderAndLightning", "thunderAndLightningCount")
			elseif timer == 36 then
				adderisDead = false
				startTimer(self, timerOverloadCD, timerExact, eventID, "overload", "overloadCount")
			elseif timer == 31 then
				--Overload is exactly 31; Gale Force is 31.082 in the final transition batch.
				if timerExact > 31.05 then
					aspixDead = false
					startBatchTimer(self, timer, timerGaleForceCD, timerExact, eventID, "galeForce", "galeForceCount")
				else
					adderisDead = false
					startBatchTimer(self, timer, timerOverloadCD, timerExact, eventID, "overload", "overloadCount")
				end
			elseif timer == 26 or timer == 21 or timer == 12 then
				aspixDead = false
				startBatchTimer(self, timer, timerTempestWindsCD, timerExact, eventID, "tempestWinds", "tempestWindsCount")
			elseif timer == 5 or timer == 1 then
				aspixDead = false
				startBatchTimer(self, timer, timerGaleForceCD, timerExact, eventID, "galeForce", "galeForceCount")
			elseif timer == 19 then
				if not aspixDead then
					--Adderis died: Gale Force then Tempest Winds.
					if nextNineteenTimer == 1 then
						startTimer(self, timerGaleForceCD, timerExact, eventID, "galeForce", "galeForceCount")
					else
						startTimer(self, timerTempestWindsCD, timerExact, eventID, "tempestWinds", "tempestWindsCount")
					end
				elseif not adderisDead then
					--Aspix died: Thunder and Lightning then Overload.
					if nextNineteenTimer == 1 then
						startTimer(self, timerThunderandLightningCD, timerExact, eventID, "thunderAndLightning", "thunderAndLightningCount")
					else
						startTimer(self, timerOverloadCD, timerExact, eventID, "overload", "overloadCount")
					end
				end
				nextNineteenTimer = nextNineteenTimer % 2 + 1
			else
				return
			end
			return true
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
			if eventInfo.source ~= 0 then return end
			local eventID = eventInfo.id
			if C_EncounterTimeline.GetEventState(eventID) ~= 0 then return end
			local timerExact = eventInfo.duration
			if not timersAll(self, math.floor(timerExact + 0.5), timerExact, eventID) and not badStateDetected then
				badStateDetected = true
				self:ResumeBlizzardAPI()
				self:UnregisterShortTermEvents()
				setFallback(self)
				DBM:Debug("|cffff0000Failed to match encounter timeline events to expected timers, falling back to Blizzard API|r", nil, nil, nil, true)
			end
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
			if not eventID then return end
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			self:TLBatchUntrack(eventID)
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType and eventCount then
					if activeEventByType[eventType] == eventID then
						activeEventByType[eventType] = nil
					end
					if eventType == "thunderAndLightning" then
						specWarnThunderandLightning:Show(eventCount, "helpsoak")
					elseif eventType == "overload" and self:IsTank() then
						specWarnOverload:Show()
						specWarnOverload:Play("defensive")
					elseif eventType == "tempestWinds" then
						specWarnTempestWinds:Show(eventCount, "poolyou")
						specWarnTempestWinds:Play("poolyou")
					elseif eventType == "galeForce" then
						specWarnGaleForce:Show(eventCount, "pushbackincoming")
						specWarnGaleForce:Play("pushbackincoming")
					end
				end
			elseif eventState == 3 then
				local eventType = self:TLCountCancel(eventID)
				if eventType and activeEventByType[eventType] == eventID then
					activeEventByType[eventType] = nil
					if eventType == "thunderAndLightning" or eventType == "overload" then
						adderisDead = true
					elseif eventType == "tempestWinds" or eventType == "galeForce" then
						aspixDead = true
					end
				end
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 263246 263371",
		"SPELL_AURA_REMOVED 263246 263371",
		"SPELL_CAST_START 263257 263318 263775 263234 263309 263365",
		"SPELL_CAST_SUCCESS 263371 263424 263425",
		"UNIT_DIED",
		"UNIT_SPELLCAST_SUCCEEDED boss1 boss2",
		"UNIT_TARGET_UNFILTERED"
	)

	--TODO, target scan/warn Gale Force target if possible
	--TODO, get a LONG pull so timer work can be actually figured out. VIDEO too
	--General
	local warnLightningShield			= mod:NewTargetNoFilterAnnounce(263246, 3)

	mod:AddInfoFrameOption(263246, true)
	mod:AddSetIconOption("SetIconOnNoLit", 263246, true, 5, {8})
	--Aspix
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18484))
	----Lighting
	local warnConduction				= mod:NewTargetAnnounce(263371, 2)

	local specWarnJolt					= mod:NewSpecialWarningInterrupt(263318, "HasInterrupt", nil, nil, 1, 2, nil, nil, "kickcast")
	local specWarnConduction			= mod:NewSpecialWarningMoveAway(263371, nil, nil, nil, 3, 2, nil, nil, "runout")
	local yellConduction				= mod:NewYell(263371)
	local yellConductionFades			= mod:NewShortFadesYell(263371)
	local specWarnStaticShock			= mod:NewSpecialWarningSpell(263257, nil, nil, nil, 2, 2, nil, nil, "aesoon")

	local timerConductionCD				= mod:NewCDTimer(13, 263371, nil, nil, nil, 3)--NYI
	local timerStaticShockCD			= mod:NewCDTimer(13, 263257, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
	----Wind
	local specWarnGust					= mod:NewSpecialWarningInterrupt(263775, "HasInterrupt", nil, nil, 1, 2, nil, nil, "kickcast")
	local specWarnGaleForce				= mod:NewSpecialWarningSpell(263776, nil, nil, nil, 2, 2, nil, nil, "specialsoon")

	local timerGaleForceCD				= mod:NewCDTimer(14.5, 263776, nil, nil, nil, 3, nil, DBM_COMMON_L.HEROIC_ICON)
	--Adderis
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(18485))
	----Lightning
	local specWarnPearlofThunder		= mod:NewSpecialWarningRun(263365, nil, nil, nil, 4, 2, nil, nil, "justrun")

	local timerArcDashCD				= mod:NewCDTimer(23, 263424, nil, nil, nil, 3)
	----Wind
	local specWarnCycloneStrike			= mod:NewSpecialWarningYou(263573, nil, nil, nil, 3, 2, nil, nil, "targetyou")
	local specWarnCycloneStrikeOther	= mod:NewSpecialWarningDodge(263573, nil, nil, nil, 3, 2, nil, nil, "shockwave")
	local yellCycloneStrike				= mod:NewYell(263573)

	local timerArcingBladeCD			= mod:NewCDTimer(13.4, 263234, nil, nil, nil, 5, nil, DBM_COMMON_L.HEROIC_ICON)
	local timerCycloneStrikeCD			= mod:NewCDTimer(13.3, 263573, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)

	mod.vb.noLitShield = nil

	function mod:CycloneTarget(targetname)
		if not targetname then return end
		if targetname == UnitName("player") then
			specWarnCycloneStrike:Show()
			specWarnCycloneStrike:Play("targetyou")
			yellCycloneStrike:Yell()
		else
			specWarnCycloneStrikeOther:Show()
			specWarnCycloneStrikeOther:Play("shockwave")
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.noLitShield = nil
		--Adderis should be in winds, Aspix timers started by Lightning Shield buff
		timerCycloneStrikeCD:Start(8.5-delay)
		if not self:IsNormal() then
			timerArcingBladeCD:Start(7.3-delay)
		end
		--Aspix
	--	timerArcDashCD:Start(14-delay)--Can be used instantly on pull, so no timer
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(DBM_CORE_L.INFOFRAME_POWER)
			DBM.InfoFrame:Show(3, "enemypower", 10)
		end
	end

	function mod:OnCombatEnd()
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 263246 then--Lightning Shield
			warnLightningShield:Show(args.destName)
			warnLightningShield:Play("targetchange")
			local cid = self:GetCIDFromGUID(args.destGUID)
			--Start lightning timers and stop wind
			if cid == 133379 then--Adderis
				timerArcingBladeCD:Stop()
				timerCycloneStrikeCD:Stop()
				--timerArcDashCD:Start(11.2)
			elseif cid == 133944 then--Aspix
				timerConductionCD:Start(11.6)
				timerStaticShockCD:Start(20)
				if not self:IsNormal() then
					--No Doubt wrong
					timerGaleForceCD:Stop()
					timerGaleForceCD:Start(26)
				end
			end
		elseif spellId == 263371 then
			if args:IsPlayer() then
				specWarnConduction:Show()
				specWarnConduction:Play("runout")
				yellConduction:Yell()
				yellConductionFades:Countdown(5)
			else
				warnConduction:Show(args.destName)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 263246 then--Lightning Shield
			self.vb.noLitShield = args.destGUID
			local cid = self:GetCIDFromGUID(args.destGUID)
			--Start wind timers and stop lightning
			if cid == 133379 then--Adderis
				--timerArcDashCD:Stop()
				--timerCycloneStrikeCD:Start(2)
				if not self:IsNormal() then
					--timerArcingBladeCD:Start(2)
				end
			elseif cid == 133944 then--Aspix
				timerConductionCD:Stop()
				timerStaticShockCD:Stop()
			end
		elseif spellId == 263371 then
			if args:IsPlayer() then
				yellConductionFades:Cancel()
			end
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 263257 then
			specWarnStaticShock:Show()
			specWarnStaticShock:Play("aesoon")
			--timerStaticShockCD:Start()
		elseif spellId == 263318 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnJolt:Show(args.sourceName)
			specWarnJolt:Play("kickcast")
		elseif spellId == 263775 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGust:Show(args.sourceName)
			specWarnGust:Play("kickcast")
		elseif spellId == 263234 then
			timerArcingBladeCD:Start()
		elseif spellId == 263309 then
			timerCycloneStrikeCD:Start()
			self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "CycloneTarget", 0.04, 16)--give 0.2 delay before scan start.
		elseif spellId == 263365 then
			specWarnPearlofThunder:Show()
			specWarnPearlofThunder:Play("justrun")
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 263371 then
			--timerConductionCD:Start()
		elseif spellId == 263425 and self:AntiSpam(3, 1) then--263424?
			timerArcDashCD:Start()
		end
	end

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 133379 then--Adderis
			timerArcDashCD:Stop()
			timerCycloneStrikeCD:Stop()
			timerArcingBladeCD:Stop()
		elseif cid == 133944 then--Aspix
			timerConductionCD:Stop()
			timerStaticShockCD:Stop()
			timerGaleForceCD:Stop()
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
		if spellId == 263776 then--Gale Force
			specWarnGaleForce:Show()
			specWarnGaleForce:Play("specialsoon")
			timerGaleForceCD:Start()
		end
	end

	do
		local function TrySetTarget(self)
			if DBM:GetRaidRank() >= 1 then
				for uId in DBM:GetGroupMembers() do
					if UnitGUID(uId.."target") == self.vb.noLitShield then
						self.vb.noLitShield = nil
						local icon = GetRaidTargetIndex(uId)
						if not icon then
							self:SetIcon(uId.."target", 8)
							break
						end
					end
					if not (self.vb.noLitShield) then
						break
					end
				end
			end
		end

		function mod:UNIT_TARGET_UNFILTERED()
			if self.Options.SetIconOnNoLit and self.vb.noLitShield then
				TrySetTarget(self)
			end
		end
	end
end
