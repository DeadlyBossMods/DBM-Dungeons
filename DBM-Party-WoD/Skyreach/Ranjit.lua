local mod	= DBM:NewMod(965, "DBM-Party-WoD", 7, 476)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(75964)
mod:SetEncounterID(1698)

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	local warnGaleSurge				= mod:NewCountAnnounce(1252733, 2)

	local specWarnFanofBlades		= mod:NewSpecialWarningCount(153757, nil, nil, nil, 2, 2)
	local specWarnWindChakram		= mod:NewSpecialWarningCount(1258148, nil, nil, nil, 2, 15)
	local specWarnChakramVortex		= mod:NewSpecialWarningCount(156793, nil, nil, nil, 2, 2)

	local timerGaleSurgeCD			= mod:NewCDCountTimer(20.5, 1252733, nil, nil, nil, 3)
	local timerFanofBladesCD		= mod:NewCDCountTimer(20.5, 153757, nil, nil, nil, 2)
	local timerWindChakramCD		= mod:NewCDCountTimer(20.5, 1258148, nil, nil, nil, 3)
	local timerChakramVortexCD		= mod:NewCDCountTimer(20.5, 156793, nil, nil, nil, 6)

	--Midnight private aura replacements
	mod:AddPrivateAuraSoundOption(1252733, true, 1252733, 1, 1, "debuffyou", 17)--Gale Surge

	mod.vb.galeSurgeCount = 0
	mod.vb.fanofBladesCount = 0
	mod.vb.windChakramCount = 0
	mod.vb.chakramVortexCount = 0
	local badStateDetected = false

	---@param self DBMMod
	local function setFallback(self)
		specWarnFanofBlades:SetAlert(299, "aesoon", 2, 2)
		specWarnWindChakram:SetAlert(300, "frontal", 15, 2)
		specWarnChakramVortex:SetAlert(301, "watchstep", 2, 2)
		timerGaleSurgeCD:SetTimeline(298)
		timerFanofBladesCD:SetTimeline(299)
		timerWindChakramCD:SetTimeline(300)
		timerChakramVortexCD:SetTimeline(301)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.galeSurgeCount = 1
		self.vb.fanofBladesCount = 1
		self.vb.windChakramCount = 1
		self.vb.chakramVortexCount = 1
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
			if timer == 5 then--Gale Surge
				timerGaleSurgeCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "galeSurge", "galeSurgeCount"))
			elseif timer == 12 or timer == 20 then--Fan of Blades
				timerFanofBladesCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fanofBlades", "fanofBladesCount"))
			elseif timer == 10 or timer == 18 then--Wind Chakram
				timerWindChakramCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "windChakram", "windChakramCount"))
			elseif timer == 35 then--Chakram Vortex
				timerChakramVortexCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "chakramVortex", "chakramVortexCount"))
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
					if eventType == "galeSurge" then
						warnGaleSurge:Show(eventCount)
					elseif eventType == "fanofBlades" then
						specWarnFanofBlades:Show(eventCount)
						specWarnFanofBlades:Play("aesoon")
					elseif eventType == "windChakram" then
						specWarnWindChakram:Show(eventCount)
						specWarnWindChakram:Play("frontal")
					elseif eventType == "chakramVortex" then
						specWarnChakramVortex:Show(eventCount)
						specWarnChakramVortex:Play("watchstep")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 153544 156793 153315",
		"SPELL_CAST_SUCCESS 165731",
		"SPELL_PERIODIC_DAMAGE 154043 153759",
		"SPELL_ABSORBED 154043 153759",
		"RAID_BOSS_EMOTE"
	)

	local warnSpinningBlade		= mod:NewSpellAnnounce(153544, 3)
	local warnWindFall			= mod:NewSpellAnnounce(153315, 2)
	local warnPiercingRush		= mod:NewTargetNoFilterAnnounce(165731, 2)--EJ shows tank warning but in my encounter it could target anyone. If this changes I'll tweak the default to tank/healer
	local warnLensFlare			= mod:NewSpellAnnounce(154043, 3)

	local specWarnFourWinds		= mod:NewSpecialWarningSpell(156793, nil, nil, nil, 2, 2)
	local specWarnWindFallMove	= mod:NewSpecialWarningMove(153315, nil, nil, nil, 1, 8)
	local specWarnLensFlare		= mod:NewSpecialWarningSpell(154043, nil, nil, nil, 2)
	local specWarnLensFlareMove	= mod:NewSpecialWarningMove(154043, nil, nil, nil, 1, 8)

	local timerFourWinds		= mod:NewBuffActiveTimer(18, 156793)
	local timerFourWindsCD		= mod:NewCDTimer(30, 156793)

	local skyTrashMod = DBM:GetModByName("SkyreachTrash")

	function mod:OnCombatStart(delay)
		timerFourWindsCD:Start(-delay)
		if skyTrashMod and skyTrashMod.Options.RangeFrame and skyTrashMod.vb.debuffCount ~= 0 then--In case of bug where range frame gets stuck open from trash pulls before this boss.
			skyTrashMod.vb.debuffCount = 0--Fix variable
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 153544 then
			warnSpinningBlade:Show()
		elseif spellId == 156793 then
			specWarnFourWinds:Show()
			timerFourWinds:Start()
			timerFourWindsCD:Start()
			specWarnFourWinds:Play("wwsoon")
		elseif spellId == 153315 then
			warnWindFall:Show()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellId == 165731 then
			warnPiercingRush:Show(args.destName)
		end
	end

	function mod:RAID_BOSS_EMOTE(msg)
		warnLensFlare:Show()
		specWarnLensFlare:Show()
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, _, _, _, overkill)
		if spellId == 154043 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
			specWarnLensFlareMove:Show()
			specWarnLensFlareMove:Play("watchfeet")
		elseif spellId == 153759 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
			specWarnWindFallMove:Show()
			specWarnWindFallMove:Play("watchfeet")
		end
	end
	mod.SPELL_ABSORBED = mod.SPELL_PERIODIC_DAMAGE
end
