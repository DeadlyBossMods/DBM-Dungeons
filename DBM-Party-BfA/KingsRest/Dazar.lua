local mod	= DBM:NewMod(2172, "DBM-Party-BfA", 3, 1041)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(136160)
mod:SetEncounterID(2143)
mod:SetZone(1762)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--Hardcode Note. Boss phases at 80% health and changes attack pattern. Signal for this is hunting leap being canceled (replaced by quaking leap in stage 2)
	local warnAerialSmash				= mod:NewCountAnnounce(1303115, 3)--Upgrade to generic special warning if aura sound doesn't work
	local warnHuntingLeap				= mod:NewCountAnnounce(269230, 3)--Upgrade to generic special warning if aura sound doesn't work
	local warnSavageMaul				= mod:NewCountAnnounce(1303488, 3)--Upgrade to generic special warning if aura sound doesn't work

	local specWarnBladeCombo			= mod:NewSpecialWarningDefensive(268586, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnGildedDestruction		= mod:NewSpecialWarningCount(1303101, nil, nil, nil, 2, 2, nil, nil, "aesoon")
	local specWarnDeadlyRoar			= mod:NewSpecialWarningCount(269369, nil, nil, nil, 2, 2, nil, nil, "fearsoon")
	local specWarnQuakingLeap			= mod:NewSpecialWarningBlizzYou(1303327, nil, nil, nil, 1, 2, nil, nil, "scatter")

	local timerAerialSmashCD			= mod:NewCDCountTimer(0, 1303115, nil, nil, nil, 3)
	local timerBladeComboCD				= mod:NewCDCountTimer(0, 268586, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerGildedDestructionCD		= mod:NewCDCountTimer(0, 1303101, nil, nil, nil, 2)
	local timerHuntingLeapCD			= mod:NewCDCountTimer(0, 269230, nil, nil, nil, 3)
	local timerDeadlyRoarCD				= mod:NewCDCountTimer(0, 269369, nil, nil, nil, 2)
	local timerQuakingLeapCD			= mod:NewCDCountTimer(0, 1303327, nil, nil, nil, 3)
	local timerSavageMaulCD				= mod:NewCDCountTimer(0, 1303488, nil, nil, nil, 3)

	mod:AddAuraSoundOption(1303101, nil, 1303115, 1, 1, "runout", 2, 0)--Aerial Smash (iffy, it wasn't in combat log)
	mod:AddAuraSoundOption(1303039, nil, 269230, 1, 3, "bleedyou", 19, 0)--Hunting Leap

	mod.vb.aerialSmashCount = 0
	mod.vb.bladeComboCount = 0
	mod.vb.gildedDestructionCount = 0
	mod.vb.huntingLeapCount = 0
	mod.vb.deadlyRoarCount = 0
	mod.vb.quakingLeapCount = 0
	mod.vb.savageMaulCount = 0
	local badStateDetected = false
	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			if self:IsTank() then
				specWarnBladeCombo:SetAlert(832, "defensive", 2, 2)
			end
			specWarnGildedDestruction:SetAlert(833, "aesoon", 2, 2)
			specWarnDeadlyRoar:SetAlert(835, "fearsoon", 2, 2)
			specWarnQuakingLeap:SetAlert(836, "scatter", 2, 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerAerialSmashCD:SetTimeline(831, onlyColor)
		timerBladeComboCD:SetTimeline(832, onlyColor)
		timerGildedDestructionCD:SetTimeline(833, onlyColor)
		timerHuntingLeapCD:SetTimeline(834, onlyColor)
		timerDeadlyRoarCD:SetTimeline(835, onlyColor)
		timerQuakingLeapCD:SetTimeline(836, onlyColor)
		timerSavageMaulCD:SetTimeline(837, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self:SetStage(1)
		self.vb.aerialSmashCount = 1
		self.vb.bladeComboCount = 1
		self.vb.gildedDestructionCount = 1
		self.vb.huntingLeapCount = 1
		self.vb.deadlyRoarCount = 1
		self.vb.quakingLeapCount = 1
		self.vb.savageMaulCount = 1
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents(
				"ENCOUNTER_TIMELINE_EVENT_ADDED",
				"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED"
			)
			setFallback(self, true)
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		self:UnregisterShortTermEvents()
	end

	do
		local function QuakingLeapCheck(self, eventCount)
			specWarnQuakingLeap:Show(eventCount, "scatter", 3)
		end

		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Confirmed against the 12.1 M+ PTR pull.
			if timer == 15 then
				timerAerialSmashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "aerialSmash", "aerialSmashCount"))
			elseif timer == 23 or timer == 38 then
				timerBladeComboCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bladeCombo", "bladeComboCount"))
			elseif (timer == 30 and self:GetStage(1)) or timer == 24 then
				timerGildedDestructionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "gildedDestruction", "gildedDestructionCount"))
			elseif timer == 8 then
				timerHuntingLeapCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "huntingLeap", "huntingLeapCount"))
			elseif timer == 10 then
				if self:GetStage(1) then
					timerHuntingLeapCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "huntingLeap", "huntingLeapCount"))
				elseif self:GetStage(2) then
					timerDeadlyRoarCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "deadlyRoar", "deadlyRoarCount"))
				else
					return
				end
			elseif timer == 14 then
				timerDeadlyRoarCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "deadlyRoar", "deadlyRoarCount"))
			elseif timer == 9 then
				local eventCount = self:TLCountStart(eventID, "quakingLeap", "quakingLeapCount")
				timerQuakingLeapCD:TLStart(timerExact, eventID, eventCount)
				--The bar is correct, but state 2 is about 4.5 seconds late; arm the ENCOUNTER_WARNING intercept one second before expiry.
				self:Schedule(timerExact - 1, QuakingLeapCheck, self, eventCount)
			elseif timer == 36 then
				timerSavageMaulCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "savageMaul", "savageMaulCount"))
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
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			if not eventState then return end
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType == "aerialSmash" and eventCount then
					warnAerialSmash:Show(eventCount)
				elseif eventType == "bladeCombo" then
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnBladeCombo:Show()
						specWarnBladeCombo:Play("defensive")
					end
				elseif eventType == "gildedDestruction" and eventCount then
					specWarnGildedDestruction:Show(eventCount)
					specWarnGildedDestruction:Play("aesoon")
				elseif eventType == "huntingLeap" and eventCount then
					warnHuntingLeap:Show(eventCount)
				elseif eventType == "deadlyRoar" and eventCount then
					specWarnDeadlyRoar:Show(eventCount)
					specWarnDeadlyRoar:Play("fearsoon")
				elseif eventType == "savageMaul" and eventCount then
					warnSavageMaul:Show(eventCount)
				end
			elseif eventState == 3 then
				local eventType = self:TLCountCancel(eventID)
				if eventType == "quakingLeap" then
					self:Unschedule(QuakingLeapCheck)
				elseif eventType == "huntingLeap" and not self:GetStage(2) then
					self:SetStage(2)
				end
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 268403 268932 268586 269369",
		"SPELL_CAST_SUCCESS 269231",
		"UNIT_DIED",
		"INSTANCE_ENCOUNTER_ENGAGE_UNIT",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--(ability.id = 268932 or ability.id = 268403 or ability.id = 268586) and type = "begincast"
	--TODO:  pull:12.0, 42.3, 19.7, 23.2 (wtf?)
	local warnGaleSlash					= mod:NewSpellAnnounce(268403, 2)
	local warnQuakingLeap				= mod:NewTargetAnnounce(268932, 2)

	local specWarnQuakingLeap			= mod:NewSpecialWarningYou(268932, nil, nil, nil, 1, 2, nil, nil, "targetyou")
	local yellQuakingLeap				= mod:NewYell(268932)
	local specWarnBladeCombo			= mod:NewSpecialWarningDefensive(268586, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnImpalingSpear			= mod:NewSpecialWarningDodge(268796, nil, nil, nil, 2, 2, nil, nil, "watchstep")
	----ADDS
	local specWarnHuntingLeap			= mod:NewSpecialWarningYou(269231, nil, nil, nil, 1, 2, nil, nil, "runaway")
	local yellHuntingLeap				= mod:NewYell(269231)
	local specWarnDeadlyRoar			= mod:NewSpecialWarningSpell(269369, nil, nil, nil, 2, 2, nil, nil, "fearsoon")
	--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

	local timerGaleSlashCD				= mod:NewCDTimer(13, 268403, nil, nil, nil, 3)
	local timerQuakingLeapCD			= mod:NewCDTimer(19.3, 268932, nil, nil, nil, 3)
	local timerBladeComboCD				= mod:NewCDTimer(14.5, 268586, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	--Adds
	local timerHuntingLeapCD			= mod:NewCDTimer(12.8, 269231, nil, nil, nil, 3)
	local timerDeathlyRoarCD			= mod:NewCDTimer(13.6, 269369, nil, nil, nil, 2)


	local seenMobs = {}

	--Handles the ICD that Boss triggers on other abilities
	local function updateAllTimers(_, ICD)
		DBM:Debug("updateAllTimers running", 3)
		if timerGaleSlashCD:GetRemaining() < ICD then
			local elapsed, total = timerGaleSlashCD:GetTime()
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerGaleSlashCD extended by: "..extend, 2)
			timerGaleSlashCD:Stop()
			timerGaleSlashCD:Update(elapsed, total+extend)
		end
		if timerQuakingLeapCD:GetRemaining() < ICD then
			local elapsed, total = timerQuakingLeapCD:GetTime()
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerQuakingLeapCD extended by: "..extend, 2)
			timerQuakingLeapCD:Stop()
			timerQuakingLeapCD:Update(elapsed, total+extend)
		end
		if timerBladeComboCD:GetRemaining() < ICD then
			local elapsed, total = timerBladeComboCD:GetTime()
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerBladeComboCD extended by: "..extend, 2)
			timerBladeComboCD:Stop()
			timerBladeComboCD:Update(elapsed, total+extend)
		end
	end

	function mod:LeapTarget(targetname)
		if not targetname then return end
		if targetname == UnitName("player") then
			specWarnQuakingLeap:Show()
			specWarnQuakingLeap:Play("targetyou")
			yellQuakingLeap:Yell()
		else
			warnQuakingLeap:Show(targetname)
		end
	end

	function mod:OnCombatStart(delay)
		timerGaleSlashCD:Start(8.4-delay)
		timerQuakingLeapCD:Start(12-delay)
		timerBladeComboCD:Start(18-delay)
	end

	function mod:OnCombatEnd()
		table.wipe(seenMobs)

	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 268403 then
			warnGaleSlash:Show()
			timerGaleSlashCD:Start()
			--updateAllTimers(self, 4.5)--Not confirmed
		elseif spellId == 268932 then
			timerQuakingLeapCD:Stop()
			timerQuakingLeapCD:Start()
			self:BossTargetScanner(args.sourceGUID, "LeapTarget", 0.05, 12, true)--0.2 seconds faster than emote still
			updateAllTimers(self, 4.5)
		elseif spellId == 268586 then
			if self:IsTanking("player", "boss1", nil, true) and self:AntiSpam(3, 1) then
				specWarnBladeCombo:Show()
				specWarnBladeCombo:Play("defensive")
			end
			timerBladeComboCD:Stop()
			timerBladeComboCD:Start()
			updateAllTimers(self, 5)
		elseif spellId == 269369 then
			specWarnDeadlyRoar:Show()
			specWarnDeadlyRoar:Play("fearsoon")
			timerDeathlyRoarCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 269231 then
			if args:IsPlayer() then
				specWarnHuntingLeap:Show()
				specWarnHuntingLeap:Play("runaway")
				yellHuntingLeap:Yell()
			end
			timerHuntingLeapCD:Start()
		end
	end

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 136984 then--Reban
			timerHuntingLeapCD:Stop()
		elseif cid == 136976 then--T'zala
			timerDeathlyRoarCD:Stop()
		end
	end

	function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
		for i = 1, 3 do
			local unitID = "boss"..i
			local GUID = UnitGUID(unitID)
			if GUID and not seenMobs[GUID] then
				seenMobs[GUID] = true
				local cid = self:GetCIDFromGUID(GUID)
				if cid == 136984 then--Reban
					timerHuntingLeapCD:Start(5)
				elseif cid == 136976 then--T'zala
					timerDeathlyRoarCD:Start(8)
				end
			end
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 269377 then--Spokey Pattern Controller
			specWarnImpalingSpear:Show()
			specWarnImpalingSpear:Play("watchstep")
		end
	end
end
