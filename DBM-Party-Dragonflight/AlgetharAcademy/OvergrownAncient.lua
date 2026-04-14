local mod	= DBM:NewMod(2512, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186951)
mod:SetEncounterID(2563)
mod:SetHotfixNoticeRev(20230103000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2526)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

do
	--Allowed in both
	mod:RegisterSafeEvents(
		"CHAT_MSG_MONSTER_SAY"
	)

	--<38.95 21:51:16> [CHAT_MSG_MONSTER_SAY] Perfect, we are just about--wait, Ichistrasz! There is too much life magic! What are you doing?#Professor Mystakria###Omegal##0#0##0#3723#nil#0#fa
	--<56.01 21:51:33> [DBM_Debug] ENCOUNTER_START event fired: 2563 Overgrown Ancient 8 5#nil", -- [250]
	local timerRP = mod:NewRPTimer(17)
	function mod:CHAT_MSG_MONSTER_SAY(msg)
		if self:issecretvalue(msg) then return end
		if (msg == L.TreeRP or msg:find(L.TreeRP)) then
			self:SendSync("TreeRP")--Syncing to help unlocalized clients
		end
	end
	function mod:OnSync(msg)
		if msg == "TreeRP" and self:AntiSpam(10, 2) then
			timerRP:Start()
		end
	end
end

if DBM:IsPostMidnight() then
	--Note, no eventID for healing touch so no timer or alert for it sadly
	--Midnight private aura replacements
--	mod:AddPrivateAuraSoundOption(433740, true, 433740, 1)

	local specWarnGerminate				= mod:NewSpecialWarningCount(388796, nil, nil, nil, 2, 2)
	local specWarnBurstForth			= mod:NewSpecialWarningCount(388923, nil, nil, nil, 2, 2)
	local specWarnBranchOut				= mod:NewSpecialWarningCount(388623, nil, nil, nil, 1, 2)
	local specWarnBarkbreaker			= mod:NewSpecialWarningCount(388544, nil, "Tank|Healer", nil, 1, 2)

	local timerGerminateCD				= mod:NewCDCountTimer(20.5, 388796, nil, nil, nil, 3)
	local timerBurstForthCD				= mod:NewCDCountTimer(20.5, 388923, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
	local timerBranchOutCD				= mod:NewCDCountTimer(20.5, 388623, nil, nil, nil, 1)
	local timerBarkbreakerCD			= mod:NewCDCountTimer(20.5, 388544, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

	mod.vb.germinateCount = 0
	mod.vb.burstForthCount = 0
	mod.vb.branchOutCount = 0
	mod.vb.barkCount = 0

	local badStateDetected = false

	---@param self DBMMod
	local function setFallback(self)
		if self:IsTank() then
			specWarnBarkbreaker:SetAlert(282, "defensive", 2)
		end
		specWarnBranchOut:SetAlert(283, "bigmob", 2)
		specWarnGerminate:SetAlert(284, "watchstep", 2)
		specWarnBurstForth:SetAlert(285, "aesoon", 2)
		timerBarkbreakerCD:SetTimeline(282)
		timerBranchOutCD:SetTimeline(283)
		timerGerminateCD:SetTimeline(284)
		timerBurstForthCD:SetTimeline(285)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		self.vb.germinateCount = 1
		self.vb.burstForthCount = 1
		self.vb.branchOutCount = 1
		self.vb.barkCount = 1
		badStateDetected = false
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
			--Logic confirmed against OvergrownAncientKill1/OvergrownAncientKill2 M+ pulls.
			if timer == 9 then--Barkbreaker first of pair (9s)
				timerBarkbreakerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bark", "barkCount"))
			elseif timer == 18 then--Germinate odd casts (18s)
				timerGerminateCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "germinate", "germinateCount"))
			elseif timer == 28 then--Barkbreaker second of pair (28s)
				timerBarkbreakerCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "bark", "barkCount"))
			elseif timer == 30 then--Branch Out
				timerBranchOutCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "branchOut", "branchOutCount"))
			elseif timer == 33 then--Germinate even casts (33s)
				timerGerminateCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "germinate", "germinateCount"))
			elseif timer == 55 then--Burst Forth
				timerBurstForthCD:TLStart(timerExact, eventID, self:TLCountStart(eventID, "burstForth", "burstForthCount"))
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
					if eventType == "germinate" then
						specWarnGerminate:Show(eventCount)
						specWarnGerminate:Play("watchstep")
					elseif eventType == "burstForth" then
						specWarnBurstForth:Show(eventCount)
						specWarnBurstForth:Play("aesoon")
					elseif eventType == "branchOut" then
						specWarnBranchOut:Show(eventCount)
						specWarnBranchOut:Play("bigmob")
					elseif eventType == "bark" then
						if self:IsTank() then
							specWarnBarkbreaker:Show(eventCount)
							specWarnBarkbreaker:Play("defensive")
						end
					end
				end
			elseif eventState == 3 then
				self:TLCountCancel(eventID)
			end
		end
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 388923 388623 396640 388544",
		"SPELL_AURA_APPLIED 388796 389033",
		"SPELL_AURA_APPLIED_DOSE 389033",
		"SPELL_AURA_REMOVED 389033",
		"SPELL_AURA_REMOVED_DOSE 389033",
		"UNIT_DIED"
	)


	--TODO, do stuff with Splinterbark/Abunance mythic mechanic? Seems self explanatory. You get a bleedd on spawn, and clear it on death with target goal to be "don't ignore adds"
	--[[
	(ability.id = 388923 or ability.id = 388623 or ability.id = 396640 or ability.id = 388544) and type = "begincast"
	 or ability.id = 388796 and type = "applybuff"
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	local warnHealingTouch							= mod:NewCastAnnounce(396640, 3)
	local warnLasherToxin							= mod:NewStackAnnounce(389033, 2, nil, "Tank|Healer|RemoveDisease")

	local specWarnGerminate							= mod:NewSpecialWarningDodge(388796, nil, nil, nil, 2, 2)
	local specWarnLasherToxin						= mod:NewSpecialWarningStack(389033, nil, 12, nil, nil, 1, 6)
	local specWarnBurstForth						= mod:NewSpecialWarningSpell(388923, nil, nil, nil, 2, 2)
	local specWarnBranchOut							= mod:NewSpecialWarningDodge(388623, nil, nil, nil, 2, 2)
	local specWarnHealingTouch						= mod:NewSpecialWarningInterrupt(396640, "HasInterrupt", nil, nil, 1, 2)
	local specWarnBarkbreaker						= mod:NewSpecialWarningDefensive(388544, nil, nil, nil, 1, 2)

	local timerGerminateCD							= mod:NewCDCountTimer(29.1, 388796, nil, nil, nil, 3)
	local timerBurstForthCD							= mod:NewCDTimer(58.2, 388923, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)--Assumed it's on same cycle as branch out, CD not confirmed
	local timerBranchOutCD							= mod:NewCDTimer(58.2, 388623, nil, nil, nil, 3)
	local timerHealingTouchCD						= mod:NewCDTimer(12, 396640, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--First cast only, after that it's iffy
	local timerBarkbreakerCD						= mod:NewCDCountTimer(27.9, 388544, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.HEALER_ICON)

	mod:AddInfoFrameOption(389033, "Tank|Healer|RemovePoison")

	local toxinStacks = {}
	mod.vb.germinateCount = 0
	mod.vb.barkCount = 0

	function mod:OnCombatStart(delay)
		table.wipe(toxinStacks)
		self.vb.germinateCount = 0
		self.vb.barkCount = 0
		timerBarkbreakerCD:Start(9.3-delay, 1)
		timerGerminateCD:Start(18.2-delay, 1)
		timerBranchOutCD:Start(30-delay)
		timerBurstForthCD:Start(56-delay)
		if self.Options.InfoFrame and self:IsMythic() then
			DBM.InfoFrame:SetHeader(DBM:GetSpellName(389033))
			DBM.InfoFrame:Show(5, "table", toxinStacks, 1)
		end
	end

	function mod:OnCombatEnd()
		table.wipe(toxinStacks)
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 388923 then
			specWarnBurstForth:Show()
			specWarnBurstForth:Play("aesoon")
			timerBurstForthCD:Start()

			--The other possible timer explanation
			--timerBarkbreakerCD:Restart(6, self.vb.barkCount+1)
			--timerGerminateCD:Restart(15.7, self.vb.germinateCount+1)
		elseif spellId == 388623 then
			specWarnBranchOut:Show()
			specWarnBranchOut:Play("watchstep")
			specWarnBranchOut:ScheduleVoice(2.5, "bigmob")
			timerBranchOutCD:Start()
			timerHealingTouchCD:Start(5)--Add guid not known yet here, so it'll assign first timer to boss1 :\
		elseif spellId == 396640 then
			timerHealingTouchCD:Start(nil, args.sourceGUID)
			if self.Options.SpecWarn396640interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
				specWarnHealingTouch:Show(args.sourceName)
				specWarnHealingTouch:Play("kickcast")
			else
				warnHealingTouch:Show()
			end
		elseif spellId == 388544 then
			self.vb.barkCount = self.vb.barkCount + 1
			timerBarkbreakerCD:Start(27.9, self.vb.barkCount+1)
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnBarkbreaker:Show()
				specWarnBarkbreaker:Play("defensive")
			end
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 388796 then
			self.vb.germinateCount = self.vb.germinateCount + 1
			specWarnGerminate:Show()
			specWarnGerminate:Play("watchstep")
			if self.vb.germinateCount % 2 == 0 then
				timerGerminateCD:Start(25, self.vb.germinateCount+1)
			else
				timerGerminateCD:Start(33.6, self.vb.germinateCount+1)
			end
		elseif spellId == 389033 then
			local amount = args.amount or 1
			toxinStacks[args.destName] = amount
			if self.Options.InfoFrame then
				DBM.InfoFrame:UpdateTable(toxinStacks, 0.2)
			end
			if args:IsPlayer() and amount >= (self:IsTank() and 20 or 12) and self:AntiSpam(3.5, 1) then
				specWarnLasherToxin:Show(amount)
				specWarnLasherToxin:Play("stackhigh")
			elseif amount % 8 == 0 then
				warnLasherToxin:Show(args.destName, amount)
			end
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 389033 then
			toxinStacks[args.destName] = nil
			if self.Options.InfoFrame then
				DBM.InfoFrame:UpdateTable(toxinStacks, 0.2)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED_DOSE(args)
		local spellId = args.spellId
		if spellId == 389033 then
			toxinStacks[args.destName] = args.amount or 1
			if self.Options.InfoFrame then
				DBM.InfoFrame:UpdateTable(toxinStacks, 0.2)
			end
		end
	end

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 196548 then--Ancient Branch
			timerHealingTouchCD:Stop(args.destGUID)
		end
	end
end
