local mod	= DBM:NewMod(101, "DBM-Party-Cataclysm", 9, 65)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

if (wowToc >= 100200) then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
	mod.sendMainBossGUID = true
else
	mod.statTypes = "normal,heroic"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40586)
mod:SetEncounterID(1045)
mod:SetZone(643)

mod:RegisterCombat("combat")

if (wowToc >= 100200) then
	--Patch 10.2 or later
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 75683 428054 427771 428374 428263 428293 428103",
		"SPELL_AURA_APPLIED 428329",
		"SPELL_AURA_REMOVED 75683",
		"UNIT_DIED"
	)

	--[[
(ability.id = 75683 or ability.id = 428054 or ability.id = 427771 or ability.id = 428374 or ability.id = 428293) and type = "begincast"
 or ability.id = 75683 and type = "removebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (ability.id = 428263 or ability.id = 428103) and type = "begincast"
	--]]
	--TODO, CD of honor guards Trident Flurry for nameplate timers
	--TODO, add auto marking?
	--TODO, longer pulls, boss feels kinda undertuned even on 20s to even see geyers or shock blast get used twice
	local warnShockBlast								= mod:NewTargetNoFilterAnnounce(428054, 3)
	local warnGeyser									= mod:NewSpellAnnounce(427771, 2)
	local warnFocusedTempest							= mod:NewTargetNoFilterAnnounce(428374, 3)

	local specWarnShockBlast							= mod:NewSpecialWarningMoveAway(428054, nil, nil, nil, 1, 2)
	local yellShockBlast								= mod:NewShortYell(428054)
	local specWarnFocusedTempest						= mod:NewSpecialWarningCount(428374, nil, nil, nil, 2, 2)
	local specWarnWaterbolt								= mod:NewSpecialWarningInterrupt(428263, "HasInterrupt", nil, nil, 1, 2)
	local specWarnTridentFlurry							= mod:NewSpecialWarningDodge(428293, nil, nil, nil, 2, 2)
	local specWarnFrostbolt								= mod:NewSpecialWarningInterrupt(428103, "HasInterrupt", nil, nil, 1, 2)
	local specWarnIcyVeins								= mod:NewSpecialWarningDispel(428329, "MagicDispeller", nil, nil, 1, 2)
	--local specWarnGTFO								= mod:NewSpecialWarningGTFO(409058, nil, nil, nil, 1, 8)

	local timerShockBlastCD								= mod:NewCDTimer(49, 428054, nil, nil, nil, 3)
	local timerGeyserCD									= mod:NewCDTimer(49, 427771, nil, nil, nil, 3)
	local timerFocusedTempestCD							= mod:NewCDTimer(14.5, 428374, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)--14.5-16.9
	--local timerTridentFlurryCD							= mod:NewAITimer(49, 428293, nil, nil, nil, 3)

	--mod:AddRangeFrameOption("5/6/10")
	--mod:AddSetIconOption("SetIconOnSinSeeker", 335114, true, false, {1, 2, 3})

	mod.vb.tempestCount = 0

	function mod:ShockBlastTarget(targetname, uId)
		if not targetname then return end
		if targetname == UnitName("player") then
			specWarnShockBlast:Show()
			specWarnShockBlast:Play("runout")
			yellShockBlast:Yell()
		else
			warnShockBlast:Show(targetname)
		end
	end

	function mod:OnCombatStart(delay)
		self:SetStage(1)
		self.vb.tempestCount = 0
		timerFocusedTempestCD:Start(7.2-delay)
		timerGeyserCD:Start(16.1-delay)
		timerShockBlastCD:Start(19.7-delay)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 75683 then
			self:SetStage(2)
			timerShockBlastCD:Stop()
			timerGeyserCD:Stop()
			timerFocusedTempestCD:Stop()
		elseif spellId == 428054 then
--			self:BossUnitTargetScanner("boss1", "DisgorgeTarget", 1.1, true)--Allow tank true (use this maybe instead of legacy scanner?
			self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ShockBlastTarget", 0.1, 5, true)
--			timerShockBlastCD:Start()
		elseif spellId == 427771 then
			warnGeyser:Show()
--			timerGeyserCD:Start()
		elseif spellId == 428374 then
			self.vb.tempestCount = self.vb.tempestCount + 1
			specWarnFocusedTempest:Show(self.vb.tempestCount)
			specWarnFocusedTempest:Play("aesoon")
			timerFocusedTempestCD:Start()
		elseif spellId == 428263 then
			if self:CheckInterruptFilter(args.sourceGUID, false, true) then
				specWarnWaterbolt:Show(args.sourceName)
				specWarnWaterbolt:Play("kickcast")
			end
		elseif spellId == 428103 then
			if self:CheckInterruptFilter(args.sourceGUID, false, true) then
				specWarnFrostbolt:Show(args.sourceName)
				specWarnFrostbolt:Play("kickcast")
			end
		elseif spellId == 428293 then
			specWarnTridentFlurry:Show()
			specWarnTridentFlurry:Play("shockwave")
			--timerTridentFlurryCD:Start(nil, args.sourceGUID)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 428329 and not args:IsDestTypePlayer() and self:AntiSpam(3, 1) then
			specWarnIcyVeins:Show(args.destName)
			specWarnIcyVeins:Play("helpdispel")
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 75683 then
			self:SetStage(1)
			timerFocusedTempestCD:Start(2.4)
			timerShockBlastCD:Start(24.2)
			timerGeyserCD:Start(27.9)
		end
	end

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 40633 then--Honor Guard
			--timerTridentFlurryCD:Stop(args.destGUID)
		end
	end
else
	--10.1.7 on retail, and Cataclysm classic if it happens (if it doesn't happen old version of mod will be retired)
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 80564",
		"SPELL_AURA_REMOVED 75690 80564",
		"SPELL_CAST_START 75863 76008",
		"SPELL_CAST_SUCCESS 75700 75722",
		"UNIT_HEALTH boss1"
	)

	local warnWaterspout		= mod:NewSpellAnnounce(75863, 3)
	local warnWaterspoutSoon	= mod:NewSoonAnnounce(75863, 2)
	local warnGeyser			= mod:NewSpellAnnounce(75722, 3)
	local warnFungalSpores		= mod:NewTargetNoFilterAnnounce(80564, 3, nil, "RemoveDisease", 2)

	local specWarnShockBlast	= mod:NewSpecialWarningInterrupt(76008, nil, nil, nil, 1, 2)

	local timerWaterspout		= mod:NewBuffActiveTimer(60, 75863, nil, nil, nil, 6)
	local timerShockBlastCD		= mod:NewCDTimer(13, 76008, nil, "HasInterrupt", 2, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	local timerGeyser			= mod:NewCastTimer(5, 75722, nil, nil, nil, 3)
	local timerFungalSpores		= mod:NewBuffFadesTimer(15, 80564, nil, "RemoveDisease", 2, 5, nil, DBM_COMMON_L.DISEASE_ICON)

	local sporeTargets = {}
	mod.vb.sporeCount = 0
	local preWarnedWaterspout = false

	function mod:OnCombatStart()
		table.wipe(sporeTargets)
		self.vb.sporeCount = 0
		preWarnedWaterspout = false
	end

	local function showSporeWarning()
		warnFungalSpores:Show(table.concat(sporeTargets, "<, >"))
		table.wipe(sporeTargets)
		timerFungalSpores:Start()
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 80564 then
			self.vb.sporeCount = self.vb.sporeCount + 1
			sporeTargets[#sporeTargets + 1] = args.destName
			self:Unschedule(showSporeWarning)
			self:Schedule(0.3, showSporeWarning)
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellId == 75690 then
			timerWaterspout:Cancel()
			timerShockBlastCD:Start(13)
		elseif args.spellId == 80564 then
			self.vb.sporeCount = self.vb.sporeCount - 1
			if self.vb.sporeCount == 0 then
				timerFungalSpores:Cancel()
			end
		end
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 75863 then
			warnWaterspout:Show()
			timerWaterspout:Start()
			timerShockBlastCD:Cancel()
		elseif args.spellId == 76008 then
			if self:CheckInterruptFilter(args.sourceGUID, false, true, true) then
				specWarnShockBlast:Show(args.sourceName)
				specWarnShockBlast:Play("kickcast")
			end
			timerShockBlastCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args:IsSpellID(75700, 75722) then
			warnGeyser:Show()
			timerGeyser:Start()
		end
	end

	function mod:UNIT_HEALTH(uId)
		local h = UnitHealth(uId) / UnitHealthMax(uId) * 100
		if (h > 80) or (h > 45 and h < 60) then
			preWarnedWaterspout = false
		elseif (h < 75 and h > 72 or h < 41 and h > 38) and not preWarnedWaterspout then
			preWarnedWaterspout = true
			warnWaterspoutSoon:Show()
		end
	end
end
