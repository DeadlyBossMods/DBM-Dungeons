local mod	= DBM:NewMod(2145, "DBM-Party-BfA", 6, 1030)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(133392)
mod:SetEncounterID(2127)
mod.onlyHighest = true--Instructs DBM health tracking to literally only store highest value seen during fight, even if it drops below that
mod:DisableBossDeathKill()
mod:SetZone(1877)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--TODO: https://www.wowhead.com/ptr/spell=1301963/cleansed has an encounter event ID of 827, but it's not visible in my logs. Healer only message?
	--TODO, add aura applied sound for https://www.wowhead.com/ptr/spell=1303446/tainted-strike ? depends on frequency of application
	--NOTE: Most of this bosses abilities are ignored by blizzard timeline and warning API, so DBM has to also ignore the mechanics since they can't be disambiguated
	local warnCleansed				= mod:NewCountAnnounce(1301963, 1)

	local specWarnDefilingTaint		= mod:NewSpecialWarningCount(1301202, nil, nil, nil, 1, 2, nil, nil, "phasechange")

	local timerStageOne				= mod:NewCDTimer(32.5, 1273408, nil, nil, nil, 6)
	local timerDefilingTaintCD		= mod:NewCDCountTimer(15, 1301202, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)

	mod:AddAuraSoundOption(1300714, true, 1300704, 1, 1, "fixateyou", 19, 0)--Fixate (or 1300714 for Shadowlash if fixate is spammy)
	mod:AddAuraSoundOption(1311981, true, 1311981, 1, 1, "poolyou", 18, 0)--Latent Hex
	mod:AddAuraSoundOption(1300877, true, 1300877, 1, 1, {"debuffyou", "stackhigh"}, {17,8}, {0,1})--Corruption (stack high alert iffy, might remove stack warning if strat is to pile em up on one person)

	mod.vb.defilingTaintCount = 0
	mod.vb.phaseCount = 0
	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnDefilingTaint:SetAlert(828, "phasechange", 2, 2)
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerStageOne:SetTimeline(354, onlyColor)
		timerDefilingTaintCD:SetTimeline(828, onlyColor)
	end
	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.defilingTaintCount = 1
		self.vb.phaseCount = 1
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
			if timer == 15 then
				timerDefilingTaintCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "defilingTaint", "defilingTaintCount"))
			elseif timerExact == 32.5 then
				timerStageOne:TLStart(timerExact, eventID, self:TLCountStart(eventID, "stageOne", "phaseCount"))
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
				if eventType == "defilingTaint" and eventCount then
					specWarnDefilingTaint:Show(eventCount)
					specWarnDefilingTaint:Play("phasechange")
				elseif eventType == "stageOne" and eventCount then
					warnCleansed:Show(eventCount)
					--warnCleansed:Play("heal")
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 268008 269686 268024 268008",
		"SPELL_AURA_REMOVED 268008 269686 274149",
		"SPELL_CAST_START 268061",
		"SPELL_CAST_SUCCESS 273677 274149",
		"CHAT_MSG_RAID_BOSS_EMOTE"
	)

	--TODO, work on Cds if adds long enough for more than 1 cast each wave
	local warnTaint						= mod:NewSpellAnnounce(273677, 2)
	local warnPulse						= mod:NewSpellAnnounce(268024, 3)
	local warnLifeForce					= mod:NewSpellAnnounce(274149, 1)

	local specWarnChainLightning		= mod:NewSpecialWarningInterrupt(268061, nil, nil, nil, 1, 2, nil, nil, "kickcast")
	local specWarnRainofToads			= mod:NewSpecialWarningSpell(269688, nil, nil, nil, 2, 2, nil, nil, "mobsoon")
	local specWarnPlague				= mod:NewSpecialWarningDispel(269686, "RemoveDisease", nil, nil, 1, 2, nil, nil, "helpdispel")
	local specWarnSnakeCharm			= mod:NewSpecialWarningDispel(268008, "RemoveMagic", nil, 2, 1, 2, nil, nil, "helpdispel")

	--local timerRainofToadsCD			= mod:NewCDTimer(20, 269688, nil, nil, nil, 1)--More work needed
	local timerPlague					= mod:NewTargetTimer(10, 269686, nil, "RemoveDisease", nil, 5, nil, DBM_COMMON_L.DISEASE_ICON)
	local timerPulseCD					= mod:NewCDTimer(15, 268024, nil, "Healer", nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
	--local timerLifeForce				= mod:NewBuffActiveTimer(20, 274149, nil, nil, nil, 6, nil, DBM_COMMON_L.HEALER_ICON)

	mod:AddNamePlateOption("NPAuraOnSnakeCharm", 268008)

	function mod:OnCombatStart(delay)
		timerPulseCD:Start(10-delay)
		--timerRainofToadsCD:Start(1-delay)
		if self.Options.NPAuraOnSnakeCharm then
			DBM:FireEvent("BossMod_EnableHostileNameplates")
		end
	end

	function mod:OnCombatEnd()
		if self.Options.NPAuraOnSnakeCharm then
			DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 268008 then
			if self.Options.NPAuraOnSnakeCharm then
				DBM.Nameplate:Show(true, args.destGUID, spellId, nil, 15)
			end
		elseif spellId == 269686 and self:CheckDispelFilter("disease") then
			specWarnPlague:Show(args.destName)
			specWarnPlague:Play("helpdispel")
			timerPlague:Start(args.destName)
		elseif spellId == 268024 and self:AntiSpam(3, 1) then
			warnPulse:Show()
			timerPulseCD:Start()
		elseif spellId == 268008 and self:AntiSpam(3, 3) and self:CheckDispelFilter("magic") then
			specWarnSnakeCharm:Show(args.destName)
			specWarnSnakeCharm:Play("helpdispel")
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 268008 then
			if self.Options.NPAuraOnSnakeCharm then
				DBM.Nameplate:Hide(true, args.destGUID, spellId)
			end
		elseif spellId == 269686 then
			timerPlague:Stop(args.destName)
		elseif spellId == 274149 then--Life Force Ending
			timerPulseCD:Start(9.4)
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 268061 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnChainLightning:Show(args.sourceName)
			specWarnChainLightning:Play("kickcast")
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 273677 and self:AntiSpam(3, 2) then
			warnTaint:Show()
		elseif spellId == 274149 then
			timerPulseCD:Stop()
			warnLifeForce:Show()
			--timerLifeForce:Start()
		end
	end

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find("spell:269688") and self:AntiSpam(5, 4) then
			specWarnRainofToads:Show()
			specWarnRainofToads:Play("mobsoon")
			--timerRainofToadsCD:Start()
		end
	end
end
