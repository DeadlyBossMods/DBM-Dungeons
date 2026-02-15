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
	--Custom Sounds on cast/cooldown expiring
	mod:AddCustomAlertSoundOption(388796, true, 2)--Germinate
	mod:AddCustomAlertSoundOption(388923, true, 2)--Burst Forth
	mod:AddCustomAlertSoundOption(388623, true, 1)--Branch Out
--	mod:AddCustomAlertSoundOption(396640, true, 2)--Healing Touch
	mod:AddCustomAlertSoundOption(388544, true, 1)--Barkbreaker
	--Custom timer colors, countdowns, and disables
	mod:AddCustomTimerOptions(388796, nil, 3, 0)
	mod:AddCustomTimerOptions(388923, nil, 3, 0)
	mod:AddCustomTimerOptions(388623, nil, 1, 0)
--	mod:AddCustomTimerOptions(396640, nil, 4, 0)
	mod:AddCustomTimerOptions(388544, nil, 5, 0)
	--Midnight private aura replacements
--	mod:AddPrivateAuraSoundOption(433740, true, 433740, 1

	function mod:OnLimitedCombatStart()
		self:DisableSpecialWarningSounds()

		self:EnableAlertOptions(388544, 282, "defensive", 2)
		self:EnableAlertOptions(388623, 283, "bigmob", 2)
		self:EnableAlertOptions(388796, 284, "watchstep", 2)
		self:EnableAlertOptions(388923, 285, "aesoon", 2)

		self:EnableTimelineOptions(388544, 282)
		self:EnableTimelineOptions(388623, 283)
		self:EnableTimelineOptions(388796, 284)
		self:EnableTimelineOptions(388923, 285)
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
