local mod	= DBM:NewMod(1208, "DBM-Party-WoD", 5, 556)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

if (wowToc >= 100200) then
	mod.upgradedMPlus = true
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(82682)
mod:SetEncounterID(1751)
mod:SetHotfixNoticeRev(20231020000000)
--mod:SetMinSyncRevision(20211203000000)

mod:RegisterCombat("combat")

if (wowToc >= 100200) then
	--Patch 10.2 or later
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 428139 427863",
		"SPELL_AURA_APPLIED 427899 428082",
		"SPELL_PERIODIC_DAMAGE 426991",
		"SPELL_PERIODIC_MISSED 426991"
	)

	--[[
	(ability.id = 428139) and type = "begincast"
	 or (ability.id = 428177 or ability.id = 427899 or ability.id = 428082) and type = "applybuff"
	 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	 or (ability.id = 427899 or ability.id = 428082) and type = "begincast"
	--NOTE, You can detect cinder and glacial earlier on main boss with cast start, BUT spore image only has applied.
	--NOTE, sometimes boss bugs and starts casting random shit at random times (ie breaks order)
	--For consistency sake, applied is used for both. Spacial has cast start for both so that's used for both
	--TODO, visit warning types for each type, just to avoid double special alerts for overlaps which basically
	--TODO, target scan who the boss is targetting during arcane to see who furthest distance is?
	--]]
	local warnCinderboltStorm							= mod:NewSpellAnnounce(427899, 4)

	local specWarnGlacialFusion							= mod:NewSpecialWarningDodge(428082, nil, nil, nil, 2, 2)
	local specWarnSpetialCompression					= mod:NewSpecialWarningCount(428139, nil, nil, nil, 2, 13)
	local specWarnFrostbolt								= mod:NewSpecialWarningInterrupt(427863, "HasInterrupt", nil, nil, 1, 2)--Prio frostbolt interrupts over other two, because of slow
	local specWarnGTFO									= mod:NewSpecialWarningGTFO(426991, nil, nil, nil, 1, 8)

	local timerCinderboltStormCD						= mod:NewCDTimer(60, 427899, nil, nil, nil, 2)
	local timerGlacialFusionCD							= mod:NewCDTimer(60, 428082, nil, nil, nil, 3)
	local timerSpetialCompressionCD						= mod:NewCDTimer(60, 428139, nil, nil, nil, 5)
--	local timerComboCD									= mod:NewCDComboTimer(20)--Use on mythic instead?

	mod.vb.pullCount = 0
	mod.vb.comboCount = 0

	--local grip = DBM:GetSpellName(56689)

	--Fire alone (no previos yet, arcane in future combos)
	--Frost + Previous (fire)
	--Arcane + Previous (frost)
	--Repeats
	--This hardcoded function is required because sometimes boss and add invert who casts what (ie it's right combo, but the previous and current are inverted)
	local function comboHandler(self)
		self.vb.comboCount = self.vb.comboCount + 1
		--Fire alone first time (fire + arcane for 4)
		if self.vb.comboCount % 3 == 1 then
			--So next is Frost + Fire
			timerGlacialFusionCD:Start(18.4)
			timerCinderboltStormCD:Start(18.4)
			--timerComboCD:Start(DBM_COMMON_L.AOEDAMAGE, DBM_COMMON_L.ORBS)
		--Frost + Previous (fire)
		elseif self.vb.comboCount % 3 == 2 then
			--So next is Arcane + Frost
			timerSpetialCompressionCD:Start(18.4)
			timerGlacialFusionCD:Start(18.4)
			--timerComboCD:Start(grip, DBM_COMMON_L.ORBS)
		--Arcane + Previous (frost)
		else
			--So next is fire + arcane
			timerCinderboltStormCD:Start(19.4)
			timerSpetialCompressionCD:Start(19.4)
			--timerComboCD:Start(DBM_COMMON_L.AOEDAMAGE, grip)
		end
	end

	function mod:OnCombatStart(delay)
		self.vb.pullCount = 0
		self.vb.comboCount = 0
		timerCinderboltStormCD:Start(3)
		if not self:IsMythic() then--Mythic schedulers timers differently
			timerGlacialFusionCD:Start(24.1)
			timerSpetialCompressionCD:Start(43.7)
		end
		--Haven't seen bug in a while, guess print did it's job. Will remove if no one reports further problems with this boss for a while.
		--DBM:AddMsg("This boss is very buggy and blizzard has ignored bug reports on the bugs. Sol sometimes resets her rotation back to cinder at random. Now, I've decided to reinstate showing what next rotation is SUPPOSED TO BE but if it's wrong don't complain to me, complain to blizzard for not fixing rotation bug")
	end

	function mod:OnCombatEnd(wipe, secondRun)
		if not wipe and not secondRun then
			local EverBloomTrash = DBM:GetModByName("EverBloomTrash")
			EverBloomTrash:PortalRP()
		end
	end

	--Another great log with variances
	--https://www.warcraftlogs.com/reports/79WcKGf4znd8qgj2#pins=2%24Off%24%23244F4B%24expression%24%09(ability.id%20%3D%20428139)%20and%20type%20%3D%20%22begincast%22%0A%09%20or%20(ability.id%20%3D%20428177%20or%20ability.id%20%3D%20427899%20or%20ability.id%20%3D%20428082)%20and%20type%20%3D%20%22applybuff%22%0A%09%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events&boss=61279&difficulty=10&wipes=2

	--boss first / add second
	--expected:
	--fire alone
	--ice and fire
	--arcane and ice
	--fire and arcane

	--wtf:
	--Fire alone
	--ice and fire
	--fire and arcane
	--ice and fire
	--https://www.warcraftlogs.com/reports/4ftYFxqJajW3PvVb#fight=6&pins=2%24Off%24%23244F4B%24expression%24%09(ability.id%20%3D%20428139)%20and%20type%20%3D%20%22begincast%22%0A%09%20or%20(ability.id%20%3D%20428177%20or%20ability.id%20%3D%20427899%20or%20ability.id%20%3D%20428082)%20and%20type%20%3D%20%22applybuff%22%0A%09%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 428139 then
			self.vb.pullCount = self.vb.pullCount + 1
			specWarnSpetialCompression:Show(self.vb.pullCount)
			specWarnSpetialCompression:Play("pullin")
			if self:IsMythic() then
				if args:GetSrcCreatureID() == 82682 then--Source is Boss
					comboHandler(self)
				end
			else
				timerSpetialCompressionCD:Start(60)
			end
		elseif spellId == 427863 then
			if self:CheckInterruptFilter(args.sourceGUID, false, true) then
				specWarnFrostbolt:Show(args.sourceName)
				specWarnFrostbolt:Play("kickcast")
			end
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 427899 then
			warnCinderboltStorm:Show()
			if self:IsMythic() then
				if args:GetSrcCreatureID() == 82682 then--Source is Boss
					comboHandler(self)
				end
			else
				timerCinderboltStormCD:Start(60)
			end
		elseif spellId == 428082 then
			specWarnGlacialFusion:Show()
			specWarnGlacialFusion:Play("watchorb")
			if self:IsMythic() then
				if args:GetSrcCreatureID() == 82682 then--Source is Boss
					comboHandler(self)
				end
			else
				timerGlacialFusionCD:Start(60)
			end
		end
	end

	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 426991 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 168885",
		"SPELL_AURA_APPLIED 166492 166572 166726 166475 166476 166477",
		"SPELL_INTERRUPT"
	)

	--10.1.7 on retail, and classic if it happens (if it doesn't happen old version of mod will be retired)
	local warnFrostPhase			= mod:NewSpellAnnounce(166476, 2, nil, nil, nil, nil, nil, 2)
	local warnArcanePhase			= mod:NewSpellAnnounce(166477, 2, nil, nil, nil, nil, nil, 2)

	local specWarnParasiticGrowth	= mod:NewSpecialWarningCount(168885, "Tank")--No voice ideas for this
	--local specWarnFireBloom			= mod:NewSpecialWarningSpell(166492, nil, nil, nil, 2)
	local specWarnFrozenRainMove	= mod:NewSpecialWarningMove(166726, nil, nil, nil, 1, 8)

	local timerParasiticGrowthCD	= mod:NewCDCountTimer(11.5, 168885, nil, "Tank|Healer", 2, 5, nil, DBM_COMMON_L.TANK_ICON)--Every 12 seconds unless comes off cd during fireball/frostbolt, then cast immediately after.

	mod.vb.ParasiteCount = 0

	function mod:OnCombatStart(delay)
		self.vb.ParasiteCount = 0
		timerParasiticGrowthCD:Start(32.5-delay, 1)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 168885 then
			self.vb.ParasiteCount = self.vb.ParasiteCount + 1
			specWarnParasiticGrowth:Show(self.vb.ParasiteCount)
			timerParasiticGrowthCD:Stop()
			timerParasiticGrowthCD:Start(nil, self.vb.ParasiteCount+1)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		--if args:IsSpellID(166492, 166572) and self:AntiSpam(12) then--Because the dumb spell has no cast Id, we can only warn when someone gets hit by one of rings.
			--specWarnFireBloom:Show()
			--specWarnFireBloom:Play("firecircle")
		if spellId == 166726 and args:IsPlayer() and self:AntiSpam(2) then--Because dumb spell has no cast Id, we can only warn when people get debuff from standing in it.
			specWarnFrozenRainMove:Show()
			specWarnFrozenRainMove:Play("watchfeet")
		elseif spellId == 166476 then
			warnFrostPhase:Show()
			warnFrostPhase:Play("ptwo")
		elseif spellId == 166477 then
			warnArcanePhase:Show()
			warnArcanePhase:Play("pthree")
		end
	end

	function mod:SPELL_INTERRUPT(args)
		if type(args.extraSpellId) == "number" and args.extraSpellId == 168885 then
			timerParasiticGrowthCD:Stop()
			self.vb.ParasiteCount = 0
			timerParasiticGrowthCD:Start(30, 1)
		end
	end
end
