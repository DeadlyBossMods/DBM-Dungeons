local mod	= DBM:NewMod(609, "DBM-Party-WotLK", 15, 278)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,mythic,challenge,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(36476)
mod:SetEncounterID(2001)
mod:SetZone(658)
if not DBM:IsPostMidnight() then
	mod:SetUsedIcons(8)
end

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then

	mod:RegisterSafeEventsInCombat(
		"UNIT_SPELLCAST_START boss2"
	)

	--Note. https://www.wowhead.com/spell=1282138/shade-bomb is ignored on purpose to avoid spam
	local warnGetEmIck					= mod:NewCountAnnounce(1264363, 3)

	local specWarnShadeShift			= mod:NewSpecialWarningSwitchCount(1264027, nil, nil, nil, 1, 2)
	local specWarnPlagueExpulsion		= mod:NewSpecialWarningDodgeCount(1264336, nil, nil, nil, 2, 2)
	local specWarnBlightSmash			= mod:NewSpecialWarningCount(1264287, nil, nil, nil, 1, 18)
	local specWarnLumberingFixation		= mod:NewSpecialWarningBlizzYou(1264453, nil, nil, nil, 1, 19)

	local timerGetEmIckCD				= mod:NewCDCountTimer(20.5, 1264363, nil, nil, nil, 3, nil, DBM_COMMON_L.IMPORTANT_ICON)--Get 'Em, Ick! (parent of Lumbering Fixation)
	local timerShadeShiftCD				= mod:NewCDCountTimer(20.5, 1264027, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerPlagueExpulsionCD		= mod:NewCDCountTimer(20.5, 1264336, nil, nil, nil, 3)
	local timerBlightSmashCD			= mod:NewCDCountTimer(20.5, 1264287, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	--local timerLumberingFixationCD		= mod:NewCDCountTimer(20.5, 1264453, nil, nil, nil, 3)--Lumbering Fixation (child of Get 'Em, Ick!)

	--Midnight private aura replacements
	--mod:AddPrivateAuraSoundOption(1264453, true, 1264363, 1, 1, "fixateyou", 19)--Lumbering Fixation
	mod:AddPrivateAuraSoundOption(1264299, true, 1264299, 2, 2, "watchfeet", 8)--Blight (GTFO)

	mod.vb.getEmCount = 0
	mod.vb.shadeCount = 0
	mod.vb.plagueCount = 0
	mod.vb.smashCount = 0
	mod.vb.fixateCount = 0
	mod.vb.sickemActive = false
	local badStateDetected = false
	local recurringNineteenCount = 0

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		--Blizz API fallbacks
		if not dontSetAlerts then
			specWarnShadeShift:SetAlert(204, "killmob", 2)
			specWarnPlagueExpulsion:SetAlert(205, "watchstep", 2, 2)
			if self:IsTank() then
				specWarnBlightSmash:SetAlert(206, "poolyou", 18, 2)
			end
			specWarnLumberingFixation:SetAlert(561, "fixateyou", 19, 2, 0)
		end
		timerGetEmIckCD:SetTimeline(203)
		timerShadeShiftCD:SetTimeline(204)
		timerPlagueExpulsionCD:SetTimeline(205)
		timerBlightSmashCD:SetTimeline(206)
		--timerLumberingFixationCD:SetTimeline(561)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.getEmCount = 1
		self.vb.shadeCount = 1
		self.vb.plagueCount = 1
		self.vb.smashCount = 1
		self.vb.sickemActive = false
		recurringNineteenCount = 0
		if DBM.Options.HardcodedTimer and not badStateDetected then
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
		recurringNineteenCount = 0
		self:UnregisterShortTermEvents()
	end

	function mod:UNIT_SPELLCAST_START()
		--UNIT_SPELLCAST_START cast by boss2 during Get 'Em, Ick! is always for Lumbering Fixation switching targets
		--Next event will be ENCOUNTER_WARNING for the victim
		if self.vb.sickemActive then
			self.vb.fixateCount = self.vb.fixateCount + 1
			specWarnLumberingFixation:Show(self.vb.fixateCount, "fixateyou")
		end
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Logic confirmed against M+ logs. Cycle: Blight Smash(11/19), Plague Expulsion(21/19), Get 'Em, Ick!(50), Shade Shift(29).
			if timer == 11 then--Blight Smash opener
				timerBlightSmashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "smash", "smashCount"))
			elseif timer == 21 then--Plague Expulsion opener
				timerPlagueExpulsionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "plague", "plagueCount"))
			elseif timer == 50 then--Get 'Em, Ick!
				timerGetEmIckCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "getem", "getEmCount"))
				self.vb.sickemActive = false
			elseif timer == 29 then--Shade Shift (28.75 rounded)
				timerShadeShiftCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "shade", "shadeCount"))
			elseif timer == 19 then--Alternates Blight Smash then Plague Expulsion in verified pulls
				recurringNineteenCount = recurringNineteenCount + 1
				if recurringNineteenCount % 2 == 1 then
					timerBlightSmashCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "smash", "smashCount"))
				else
					timerPlagueExpulsionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "plague", "plagueCount"))
				end
			else--Reached end of chain without finding a valid timer, this means hardcode mod has failed, so we need to disable hardcoded features and fall back to blizz API
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

		--Note, bar state changing and canceling is handled by core
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
					if eventType == "shade" then
						specWarnShadeShift:Show(eventCount)
						specWarnShadeShift:Play("killmob")
					elseif eventType == "plague" then
						specWarnPlagueExpulsion:Show(eventCount)
						specWarnPlagueExpulsion:Play("watchstep")
					elseif eventType == "smash" then
						if self:IsTank() then
							specWarnBlightSmash:Show(eventCount)
							specWarnBlightSmash:Play("poolyou")
						end
					elseif eventType == "getem" then
						warnGetEmIck:Show(eventCount)
						--Arm scanning for Lumbering Fixation casts
						self.vb.sickemActive = true
						self.vb.fixateCount = 0
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else

	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 68987 68989 69012",
		"SPELL_AURA_APPLIED 69029",
		"SPELL_AURA_REMOVED 69029",
		"SPELL_PERIODIC_DAMAGE 69024",
		"SPELL_PERIODIC_MISSED 69024",
		"UNIT_AURA_UNFILTERED"
	)

	local warnPursuitCast			= mod:NewCastAnnounce(68987, 3)
	local warnPursuit				= mod:NewTargetNoFilterAnnounce(68987, 4)

	local specWarnToxic				= mod:NewSpecialWarningMove(69024, nil, nil, nil, 1, 2)
	local specWarnMines				= mod:NewSpecialWarningSpell(69015, nil, nil, nil, 2, 2)
	local specWarnPursuit			= mod:NewSpecialWarningRun(68987, nil, nil, 2, 4, 2)
	local specWarnPoisonNova		= mod:NewSpecialWarningRun(68989, "Melee", nil, 2, 4, 2)

	local timerSpecialCD			= mod:NewCDSpecialTimer(20)--Every 20-22 seconds. In rare cases he skips a special though and goes 40 seconds. unsure of cause
	local timerPursuitCast			= mod:NewCastTimer(5, 68987, nil, nil, nil, 3)
	local timerPursuitConfusion		= mod:NewBuffActiveTimer(12, 69029, nil, nil, nil, 5)
	local timerPoisonNova			= mod:NewCastTimer(5, 68989, nil, "Melee", 2, 2)

	mod:AddSetIconOption("SetIconOnPursuitTarget", 68987, true, 0, {8})
	--mod:GroupSpells(68987, 69029)

	local pursuit = DBM:GetSpellName(68987)
	local pursuitTable = {}

	function mod:OnCombatStart(delay)
		table.wipe(pursuitTable)
		timerSpecialCD:Start()
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 68987 then					-- Pursuit
			warnPursuitCast:Show()
			timerPursuitCast:Start()
			timerSpecialCD:Start()
		elseif spellId == 68989 then				-- Poison Nova
			timerPoisonNova:Start()
			specWarnPoisonNova:Show()
			specWarnPoisonNova:Play("runout")
			timerSpecialCD:Start()
		elseif spellId == 69012 then				--Explosive Barrage
			specWarnMines:Show()
			specWarnMines:Play("watchstep")
			timerSpecialCD:Start(22)--Will be 2 seconds longer because of how long barrage lasts
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 69029 then					-- Pursuit Confusion
			timerPursuitConfusion:Start()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellId == 69029 then					-- Pursuit Confusion
			timerPursuitConfusion:Cancel()
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
		if spellId == 69024 and destGUID == UnitGUID("player") and self:AntiSpam() then
			specWarnToxic:Show()
			specWarnToxic:Play("runaway")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_AURA_UNFILTERED(uId)
		local isPursuitDebuff = DBM:UnitDebuff(uId, pursuit)
		local name = DBM:GetUnitFullName(uId) or "UNKNOWN"
		if not isPursuitDebuff and pursuitTable[name] then
			pursuitTable[name] = nil
			if self.Options.SetIconOnPursuitTarget then
				self:SetIcon(name, 0)
			end
		elseif isPursuitDebuff and not pursuitTable[name] then
			pursuitTable[name] = true
			if UnitIsUnit(uId, "player") then
				specWarnPursuit:Show()
				specWarnPursuit:Play("justrun")
			else
				warnPursuit:Show(name)
			end
			if self.Options.SetIconOnPursuitTarget then
				self:SetIcon(name, 8)
			end
		end
	end
end
