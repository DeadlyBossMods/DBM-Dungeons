local mod	= DBM:NewMod(2509, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(194181)
mod:SetEncounterID(2562)
mod:SetHotfixNoticeRev(20221015000000)
mod:SetMinSyncRevision(20221015000000)
mod:SetZone(2526)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

if DBM:IsPostMidnight() then
	--NOTE: Once again no private auras to hook up for Mana Bombs
	--Midnight private aura replacements
--	mod:AddPrivateAuraSoundOption(386181, true, 386181, 1)

	local specWarnArcaneOrbs			= mod:NewSpecialWarningCount(385974, nil, nil, DBM_COMMON_L.ORBS, 2, 2)
	local specWarnManaBombs				= mod:NewSpecialWarningCount(386173, nil, nil, DBM_COMMON_L.POOL, 2, 2)
	local specWarnArcaneExpulsion		= mod:NewSpecialWarningCount(385958, nil, "Tank|Healer", nil, 1, 2)
	local specWarnArcaneFissure			= mod:NewSpecialWarningCount(388537, nil, nil, DBM_COMMON_L.AOEDAMAGE, 2, 2)

	local timerArcaneOrbsCD				= mod:NewCDCountTimer(20.5, 385974, DBM_COMMON_L.ORBS.." (%s)", nil, nil, 5)
	local timerManaBombsCD				= mod:NewCDCountTimer(20.5, 386173, DBM_COMMON_L.POOLS.." (%s)", nil, nil, 3)
	local timerArcaneExpulsionCD		= mod:NewCDCountTimer(20.5, 385958, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerArcaneFissureCD			= mod:NewCDCountTimer(20.5, 388537, DBM_COMMON_L.AOEDAMAGE.." (%s)", nil, nil, 2)

	mod.vb.orbCount = 0
	mod.vb.bombCount = 0
	mod.vb.expulsionCount = 0
	mod.vb.fissureCount = 0

	local badStateDetected = false
	local eighteenCount = 1

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called when user has disabled DBM bars and is ONLY using timeline, therefor we must enable SetTimeline calls even in hardcodes
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnArcaneOrbs:SetAlert(274, "catchballs", 2)
			specWarnManaBombs:SetAlert(275, "scattersoon", 2)
			if self:IsTank() then
				specWarnArcaneExpulsion:SetAlert(276, "defensive", 2)
			end
			specWarnArcaneFissure:SetAlert(277, "aesoon", 2)
		end
		timerArcaneOrbsCD:SetTimeline(274)
		timerManaBombsCD:SetTimeline(275)
		timerArcaneExpulsionCD:SetTimeline(276)
		timerArcaneFissureCD:SetTimeline(277)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.orbCount = 1
		self.vb.bombCount = 1
		self.vb.expulsionCount = 1
		self.vb.fissureCount = 1
		badStateDetected = false
		eighteenCount = 1
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
		self:UnregisterShortTermEvents()
		eighteenCount = 1
	end

	do
		---@param self DBMMod
		---@param timer number
		---@param timerExact number
		---@param eventID number
		local function timersAll(self, timer, timerExact, eventID)
			--Logic confirmed against VexamusKill1/VexamusKill2 M+ pulls.
			--Each ~44s cycle batch-adds: Expulsion (5s), Fissure (40s), Orbs (2s), Mana Bombs (15s)
			--After each first-of-pair fires, a second cast is added with duration 18s in order: Orbs 2nd, Expulsion 2nd, Mana Bombs 2nd
			--eighteenCount is a global modulo-3 counter (starts at 1, incremented after branch)
			if timer == 2 then--Arcane Orbs first of pair
				timerArcaneOrbsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "orbs", "orbCount"))
			elseif timer == 5 then--Arcane Expulsion first of pair
				timerArcaneExpulsionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "expulsion", "expulsionCount"))
			elseif timer == 15 then--Mana Bombs first of pair
				timerManaBombsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bombs", "bombCount"))
			elseif timer == 18 then--Second cast: Orbs (% 3 == 1), Expulsion (% 3 == 2), Mana Bombs (% 3 == 0)
				if eighteenCount % 3 == 1 then--Arcane Orbs second of pair
					timerArcaneOrbsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "orbs", "orbCount"))
				elseif eighteenCount % 3 == 2 then--Arcane Expulsion second of pair
					timerArcaneExpulsionCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "expulsion", "expulsionCount"))
				elseif eighteenCount % 3 == 0 then--Mana Bombs second of pair
					timerManaBombsCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bombs", "bombCount"))
				end
				eighteenCount = eighteenCount + 1
			elseif timer == 40 then--Arcane Fissure
				timerArcaneFissureCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "fissure", "fissureCount"))
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
					if eventType == "orbs" then
						specWarnArcaneOrbs:Show(eventCount)
						specWarnArcaneOrbs:Play("catchballs")
					elseif eventType == "bombs" then
						specWarnManaBombs:Show(eventCount)
						specWarnManaBombs:Play("scattersoon")
					elseif eventType == "expulsion" then
						if self:IsTank() then
							specWarnArcaneExpulsion:Show(eventCount)
							specWarnArcaneExpulsion:Play("defensive")
						end
					elseif eventType == "fissure" then
						specWarnArcaneFissure:Show(eventCount)
						specWarnArcaneFissure:Play("aesoon")
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 388537 386173 385958",
		"SPELL_CAST_SUCCESS 387691 388537",
		"SPELL_AURA_APPLIED 386181",
		"SPELL_AURA_REMOVED 386181",
		"SPELL_PERIODIC_DAMAGE 386201",
		"SPELL_PERIODIC_MISSED 386201",
		"SPELL_ENERGIZE 386088"
	)
	mod:RegisterEvents(
		"CHAT_MSG_MONSTER_SAY"
	)

	--TODO, find a log where orb actually hits boss to see affect on all timers, not just fissure
	--TODO, review energy updating. it doesn't check out quite right. boss got 20 energy from 1 orb, timere reduced by 5.6 seconds (should have been 8)
	--TODO, review a long heroic pull again without M0 or + mechanics involved to see true CDs with less spell queuing?
	--[[
	(ability.id = 388537 or ability.id = 386173 or ability.id = 385958) and type = "begincast"
	 or ability.id = 387691 and type = "cast"
	 or ability.id = 386088 and not type = "damage"
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	local warnArcaneOrbs							= mod:NewCountAnnounce(385974, 3)
	local warnManaBombs								= mod:NewTargetNoFilterAnnounce(386173, 3)

	local specWarnArcaneFissure						= mod:NewSpecialWarningDodgeCount(388537, nil, nil, nil, 1, 2)
	local specWarnManaBomb							= mod:NewSpecialWarningMoveAway(386181, nil, nil, nil, 1, 2)
	local yellManaBomb								= mod:NewYell(386181)
	local yellManaBombFades							= mod:NewShortFadesYell(386181)
	local specWarnArcaneExpulsion					= mod:NewSpecialWarningDefensive(385958, nil, nil, nil, 1, 2)
	local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

	local timerRP									= mod:NewRPTimer(19.8)
	local timerArcaneOrbsCD							= mod:NewCDCountTimer(16.8, 385974, nil, nil, nil, 5)
	local timerArcaneFissureCD						= mod:NewCDCountTimer(40.7, 388537, nil, nil, nil, 3)
	local timerManaBombsCD							= mod:NewCDCountTimer(19.4, 386173, nil, nil, nil, 3)
	local timerArcaneExpulsionCD					= mod:NewCDTimer(19.4, 385958, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

	mod:AddInfoFrameOption(391977, true)

	--mod:GroupSpells(386173, 386181)--Mana Bombs with Mana Bomb

	mod.vb.orbCount = 0
	mod.vb.manaCount = 0
	mod.vb.fissureCount = 0

	function mod:OnCombatStart(delay)
		self.vb.orbCount = 0
		self.vb.manaCount = 0
		self.vb.fissureCount = 0
		timerArcaneOrbsCD:Start(2.1-delay, 1)
		timerArcaneExpulsionCD:Start(12.1-delay)
		timerManaBombsCD:Start(22.1-delay, 1)
		timerArcaneFissureCD:Start(40.7-delay, 1)
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(DBM:GetSpellName(391977))
			DBM.InfoFrame:Show(5, "playerdebuffstacks", 391977)
		end
	end

	function mod:OnCombatEnd()
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 388537 then
			self.vb.fissureCount = self.vb.fissureCount + 1
			specWarnArcaneFissure:Show(self.vb.fissureCount)
			specWarnArcaneFissure:Play("aesoon")
			specWarnArcaneFissure:ScheduleVoice(1.5, "watchstep")
			--Add 3.5 to existing manabomb and expulsion timers (Working Theory, need longer logs/larger sample)
			--It seems to hold so far though, and if they are also energy based it would make sense since he doesn't gain energy for 3 seccond cast
			--Of course if they are energy based, it also means the timers need to be corrected by SPELL_ENERGIZE as well :\
			timerManaBombsCD:AddTime(3.5, self.vb.manaCount+1)
			timerArcaneExpulsionCD:AddTime(3.5)
		elseif spellId == 386173 then
			--23.9, 26.7, 23, 26.7, 23
			--24.3, 26.7, 23, 26.7, 26.7
			self.vb.manaCount = self.vb.manaCount + 1
			--Timers only perfect alternate if boss execution is perfect, if any orbs hit boss alternation is broken
	--		if self.vb.manaCount % 2 == 0 then
				timerManaBombsCD:Start(23, self.vb.manaCount+1)
	--		else
	--			timerManaBombsCD:Start(26.7, self.vb.manaCount+1)
	--		end
		elseif spellId == 385958 then
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnArcaneExpulsion:Show()
				specWarnArcaneExpulsion:Play("defensive")
			end
			timerArcaneExpulsionCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 387691 then
			self.vb.orbCount = self.vb.orbCount + 1
			warnArcaneOrbs:Show(self.vb.orbCount)
			--2, 21, 24.2, 20.6, 23.6, 20, 24.3
			--Timers only perfect alternate if boss execution is perfect, if any orbs hit boss alternation is broken
	--		if self.vb.orbCount % 2 == 0 then
				timerArcaneOrbsCD:Start(20, self.vb.orbCount+1)
	--		else
	--			timerArcaneOrbsCD:Start(23.6, self.vb.orbCount+1)
	--		end
		elseif spellId == 388537 then
			timerArcaneFissureCD:Start(nil, self.vb.fissureCount+1)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 386181 then
			warnManaBombs:CombinedShow(0.3, args.destName)
			if args:IsPlayer() then
				specWarnManaBomb:Show()
				specWarnManaBomb:Play("runout")
				yellManaBomb:Yell()
				yellManaBombFades:Countdown(spellId)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 386181 then
			if args:IsPlayer() then
				yellManaBombFades:Cancel()
			end
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 386201 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:SPELL_ENERGIZE(_, _, _, _, destGUID, _, _, _, spellId, _, _, amount)
		if spellId == 386088 and destGUID == UnitGUID("boss1") then
			DBM:Debug("SPELL_ENERGIZE fired on Boss. Amount: "..amount)
			local bossPower = UnitPower("boss1")
			bossPower = bossPower / 2.5--2.5 energy per second, making it every ~40 seconds
			local remaining = 40-bossPower
			if remaining > 0 then
				local newTimer = 40-remaining
				timerArcaneFissureCD:Update(newTimer, 40, self.vb.fissureCount+1)
			else
				timerArcaneFissureCD:Stop()
			end
		end
	end


	--"<35.27 21:00:04> [CHAT_MSG_MONSTER_SAY] Ah! Here we are! Ahem--long ago, members of the blue dragonflight accidentally overloaded an arcane elemental and created a powerful construct named Vexamus that quickly started to wreak havoc!#Professor Maxdormu
	--"<55.05 21:00:23> [ENCOUNTER_START] 2562#Vexamus#8#5", -- [268]
	--<38.95 21:51:16> [CHAT_MSG_MONSTER_SAY] Perfect, we are just about--wait, Ichistrasz! There is too much life magic! What are you doing?#Professor Mystakria###Omegal##0#0##0#3723#nil#0#fa
	--<56.01 21:51:33> [DBM_Debug] ENCOUNTER_START event fired: 2563 Overgrown Ancient 8 5#nil", -- [250]
	function mod:CHAT_MSG_MONSTER_SAY(msg)
		if (msg == L.VexRP or msg:find(L.VexRP)) then
			self:SendSync("VexRP")--Syncing to help unlocalized clients
		end
	end

	function mod:OnSync(msg, targetname)
		if msg == "VexRP" and self:AntiSpam(10, 2) then
			timerRP:Start()
		end
	end
end
