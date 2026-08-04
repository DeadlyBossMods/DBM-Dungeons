local mod	= DBM:NewMod(2143, "DBM-Party-BfA", 6, 1030)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(133384)
mod:SetEncounterID(2125)
mod:SetZone(1877)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--TODO, better log that tracks UTC
	--NOTE: https://www.wowhead.com/ptr/spell=1293154/tempest-breath has an ID of 730 but is not in journal and has no log evidence
	local specWarnBurrow			= mod:NewSpecialWarningCount(264172, nil, nil, nil, 2, 2, nil, nil, "phasechange")
	local specWarnKnotofSnakes		= mod:NewSpecialWarningSwitch(1290029, "-Healer", nil, nil, 1, 2, nil, nil, "targetchange")
	local specWarnThunderspit		= mod:NewSpecialWarningBlizzYou(1289109, nil, nil, nil, 1, 2, nil, nil, "runout")
	local specWarnHatch				= mod:NewSpecialWarningCount(1289205, nil, nil, nil, 1, 2, nil, nil, "mobsoon")
	local specWarnLightningBite		= mod:NewSpecialWarningDefensive(1290797, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnSerpentStorm		= mod:NewSpecialWarningCount(1293048, nil, nil, nil, 2, 2, nil, nil, "carefly")

	local timerBurrowCD				= mod:NewCDCountTimer(30, 264172, nil, nil, nil, 3)
	local timerKnotofSnakesCD		= mod:NewCDCountTimer(30, 1290029, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerThunderspitCD		= mod:NewCDCountTimer(30, 1289109, nil, nil, nil, 3)
	local timerHatchCD				= mod:NewCDCountTimer(30, 1289205, nil, nil, nil, 1)
	local timerLightningBiteCD		= mod:NewCDCountTimer(30, 1290797, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerSerpentStormCD		= mod:NewCDCountTimer(30, 1293048, nil, nil, nil, 2)

	mod:AddAuraSoundOption(1289589, true, 1289589, 1, 2, "watchfeet", 8, 0)--Lingering Storm

	mod.vb.burrowCount = 0
	mod.vb.knotofSnakesCount = 0
	mod.vb.ThunderspitCount = 0
	mod.vb.hatchCount = 0
	mod.vb.lightningBiteCount = 0
	mod.vb.serpentStormCount = 0
	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnBurrow:SetAlert(701, "phasechange", 2, 2)
			specWarnKnotofSnakes:SetAlert(702, "targetchange", 2, 2)
			specWarnThunderspit:SetAlert(703, "runout", 2, 2, 0)
			specWarnHatch:SetAlert(704, "mobsoon", 2, 2)
			if self:IsTank() then
				specWarnLightningBite:SetAlert(705, "defensive", 2, 2)
			end
			specWarnSerpentStorm:SetAlert(706, "carefly", 2, 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerBurrowCD:SetTimeline(701, onlyColor)
		timerKnotofSnakesCD:SetTimeline(702, onlyColor)
		timerThunderspitCD:SetTimeline(703, onlyColor)
		timerHatchCD:SetTimeline(704, onlyColor)
		timerLightningBiteCD:SetTimeline(705, onlyColor)
		timerSerpentStormCD:SetTimeline(706, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.burrowCount = 1
		self.vb.knotofSnakesCount = 1
		self.vb.ThunderspitCount = 1
		self.vb.hatchCount = 1
		self.vb.lightningBiteCount = 1
		self.vb.serpentStormCount = 1
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
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Confirmed against the 12.1 M+ PTR pull.
			if timer == 5 then
				timerLightningBiteCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "lightningBite", "lightningBiteCount"))
			elseif timer == 13 then
				timerKnotofSnakesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "knotofSnakes", "knotofSnakesCount"))
			elseif timer == 25 then
				timerThunderspitCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "Thunderspit", "ThunderspitCount"))
			elseif timer == 36 then
				timerSerpentStormCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "serpentStorm", "serpentStormCount"))
			elseif timer == 44 then
				timerHatchCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "hatch", "hatchCount"))
			elseif timer == 49 then
				timerBurrowCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "burrow", "burrowCount"))
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
			if C_EncounterTimeline.GetEventState(eventID) ~= 0 then return end
			local timerExact = eventInfo.duration
			local timer = math.floor(timerExact + 0.5)
			if not badStateDetected then
				timersAll(self, timer, timerExact, eventID)
			end
		end

		function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
			local eventState = C_EncounterTimeline.GetEventState(eventID)
			if not eventState then return end
			if eventState == 2 then
				local eventType, eventCount = self:TLCountFinish(eventID)
				if eventType == "burrow" and eventCount then
					specWarnBurrow:Show(eventCount)
					specWarnBurrow:Play("phasechange")
				elseif eventType == "knotofSnakes" then
					specWarnKnotofSnakes:Show()
					specWarnKnotofSnakes:Play("targetchange")
				elseif eventType == "Thunderspit" and eventCount then
					specWarnThunderspit:Show(eventCount, "runout")
				elseif eventType == "hatch" and eventCount then
					specWarnHatch:Show(eventCount)
					specWarnHatch:Play("mobsoon")
				elseif eventType == "lightningBite" then
					if self:IsTanking("player", "boss1", nil, true) then
						specWarnLightningBite:Show()
						specWarnLightningBite:Play("defensive")
					end
				elseif eventType == "serpentStorm" and eventCount then
					specWarnSerpentStorm:Show(eventCount)
					specWarnSerpentStorm:Play("carefly")
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 272657 263914 264239 264233",
		"SPELL_AURA_APPLIED 267050 263957 263958",
		"SPELL_AURA_REMOVED 267050",
		"SPELL_PERIODIC_DAMAGE 263927",
		"SPELL_PERIODIC_MISSED 263927",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--TODO, can eggs be attacked during hatch to reduce add spawns? if so change to special switch warning
	--TODO, remove hatch nameplate aura if they don't have nameplates
	--TODO, add new class info for "HasStun" so can be used on specWarnKnotofSnakes
	--TODO, timers for breath and blind are inconsistent with burrows.
	local warnHatch						= mod:NewCastAnnounce(264239, 3)
	local warnBurrow					= mod:NewSpellAnnounce(264206, 2, nil, nil, nil, nil, nil, nil, true)

	local specWarnHadotoxinOther		= mod:NewSpecialWarningDispel(263957, "RemovePoison", nil, nil, 1, 2, nil, nil, "helpdispel")
	local specWarnNoxiousBreath			= mod:NewSpecialWarningDodge(272657, nil, nil, nil, 2, 2, nil, nil, "watchstep")
	local specWarnBlindingSand			= mod:NewSpecialWarningLookAway(263914, nil, nil, nil, 2, 2, nil, nil, "turnaway")
	local specWarnKnotofSnakes			= mod:NewSpecialWarningSwitch(263958, "-Healer", nil, nil, 1, 2, nil, nil, "killmob")
	local specWarnKnotofSnakesYou		= mod:NewSpecialWarningYou(263958, nil, nil, nil, 1, 2, nil, nil, "targetyou")
	local yellKnotofSnakes				= mod:NewYell(263958)
	local specWarnGTFO					= mod:NewSpecialWarningGTFO(263927, nil, nil, nil, 1, 8, nil, nil, "watchfeet")

	local timerNoxiousBreathCD			= mod:NewCDTimer(89.3, 272657, nil, nil, nil, 3)
	local timerHatch					= mod:NewCastTimer(35, 264239, nil, nil, nil, 1)--even need a CD bar or just cast bar?
	--local timerBurrowCD					= mod:NewCDTimer(13, 264206, nil, nil, nil, 6)--Health based apparently
	--local timerBurrowEnds				= mod:NewBuffActiveTimer(13, 264206, nil, nil, nil, 6)

	mod:AddNamePlateOption("NPAuraOnObscured", 267050)


	function mod:OnCombatStart(delay)
		timerNoxiousBreathCD:Start(6-delay)
		--timerBurrowCD:Start(15.2-delay)
		if self.Options.NPAuraOnObscured then
			DBM:FireEvent("BossMod_EnableHostileNameplates")
		end
	end

	function mod:OnCombatEnd()
		if self.Options.NPAuraOnObscured then
			DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 263957 and self:CheckDispelFilter("poison") then
			specWarnHadotoxinOther:Show(args.destName)
			specWarnHadotoxinOther:Play("helpdispel")
		elseif spellId == 267050 then--Obscured
			if self.Options.NPAuraOnObscured then
				DBM.Nameplate:Show(true, args.destGUID, spellId)
			end
		elseif spellId == 263958 then
			if args:IsPlayer() then
				specWarnKnotofSnakesYou:Show()
				specWarnKnotofSnakesYou:Play("targetyou")
				yellKnotofSnakes:Yell()
			else
				specWarnKnotofSnakes:Show()
				specWarnKnotofSnakes:Play("killmob")
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 267050 then--Obscured
			if self.Options.NPAuraOnObscured then
				DBM.Nameplate:Hide(true, args.destGUID, spellId)
			end
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 272657 then
			specWarnNoxiousBreath:Show()
			specWarnNoxiousBreath:Play("watchstep")
			--timerNoxiousBreathCD:Start()
		elseif spellId == 263914 then
			specWarnBlindingSand:Show(args.sourceName)
			specWarnBlindingSand:Play("turnaway")
		elseif (spellId == 264239 or spellId == 264233) then--Hatch
			if self:AntiSpam(3, 1) then
				warnHatch:Show()--Cast instantly when burrow ends
				timerHatch:Start()
				--timerBurrowCD:Start(18)
			end
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 263927 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
		if spellId == 264172 then--Summon (cast when he burrows)
			timerNoxiousBreathCD:Stop()
			warnBurrow:Show()
			warnBurrow:Play("phasechange")
		end
	end
end
