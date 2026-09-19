local mod	= DBM:NewMod("Kruul", "DBM-Challenges", 3)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(117933, 117198)--Variss, Kruul
mod:SetEncounterID(3596)
mod:SetBossHPInfoToHighest()
mod.soloChallenge = true

mod:RegisterCombat("combat")
mod:SetReCombatTime(20, 5)--Basically killing of recombat restriction. mage tower lets you spam retry, we want the mod to let you

if DBM:IsRestricted() then
	--local warnHolyWard					= mod:NewCastAnnounce(233473, 1)
	--local warnDecay						= mod:NewStackAnnounce(234422, 3)
	--local warnShadowSweep					= mod:NewSpellAnnounce(234441, 3)
	--local warnTormentingEye				= mod:NewSpellAnnounce(234428, 2)--Hardcode Only
	--local warnNetherHorrors				= mod:NewSpellAnnounce(235110, 2)
	--local warnInfernal					= mod:NewSpellAnnounce(235112, 2)

	--local specWarnDecay					= mod:NewSpecialWarningStack(234422, nil, 5, nil, nil, 1, 6, nil, nil, "stackhigh")
	local specWarnDrainLife					= mod:NewSpecialWarningInterrupt(234423, nil, nil, 2, 3, 2, nil, nil, "kickcast")
	--local specWarnSmash					= mod:NewSpecialWarningDodge(234631, nil, nil, nil, 1, 2, nil, nil, "shockwave")
	local specWarnAnnihilate				= mod:NewSpecialWarningDefensive(236572, nil, nil, nil, 1, 2, nil, nil, "defensive")
	--local specWarnTwistedReflection		= mod:NewSpecialWarningInterrupt(234676, nil, nil, nil, 3, 2, nil, nil, "kickcast")
	local specWarnNetherStomp				= mod:NewSpecialWarningDodge(234672, nil, nil, nil, 3, 2, nil, nil, "runout")

	local timerDrainLifeCD					= mod:NewCDCountTimer(30, 234423, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
	--local timerHolyWardCD					= mod:NewCDCountTimer(30, 233473, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
	--local timerHolyWard					= mod:NewCDCountTimer(30, 233473, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
	local timerTormentingEyeCD				= mod:NewCDCountTimer(30, 234428, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerNetherHorrorsCD				= mod:NewCDCountTimer(30, 235110, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerInfernalCD					= mod:NewCDCountTimer(30, 235112, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerShadowSweepCD				= mod:NewCDCountTimer(30, 234920, nil, nil, nil, 3)
	local timerAnnihilateCD					= mod:NewCDCountTimer(30, 236572, nil, nil, nil, 3, nil, DBM_COMMON_L.TANK_ICON)

	local badStateDetected = false

	---@param self DBMMod
	---@param dontSetAlerts boolean? Called on engage when we only want to set timeline parameters and not touch encounter alerts
	local function setFallback(self, dontSetAlerts)
		if not dontSetAlerts then
			specWarnDrainLife:SetAlert(913, "kickcast", 2)
			specWarnAnnihilate:SetAlert(919, "defensive", 2)
			specWarnNetherStomp:SetAlert(917, "runout", 2, 4, 0)--Confirm this works
		end
		local onlyColor = not DBM.Options.HideDBMBars and not badStateDetected
		timerDrainLifeCD:SetTimeline(913, onlyColor)
		timerTormentingEyeCD:SetTimeline(914, onlyColor)
		timerNetherHorrorsCD:SetTimeline(915, onlyColor)
		timerInfernalCD:SetTimeline(916, onlyColor)
		timerShadowSweepCD:SetTimeline(920, onlyColor)
		timerAnnihilateCD:SetTimeline(919, onlyColor)
	end

	function mod:OnLimitedCombatStart()
		self:TLCountReset()
		badStateDetected = true--TEMP, REMOVE ME IN HARDCODE
		if DBM.Options.HardcodedTimer and not badStateDetected then
			self:IgnoreBlizzardAPI()
			self:RegisterShortTermEvents("ENCOUNTER_TIMELINE_EVENT_ADDED", "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED")
			setFallback(self, true)
		else
			setFallback(self)
		end
	end

	function mod:OnCombatEnd()
		self:TLCountReset()
		self:UnregisterShortTermEvents()
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_ADDED(eventInfo)
		--Timeline routing will be added after event durations are verified.
	end

	function mod:ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED(eventID)
		--Timeline completion handling will be added with the event routing.
	end
else
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 234423 233473 234631 241717 236537 236572 234676",
		"SPELL_CAST_SUCCESS 236572",
		"SPELL_AURA_APPLIED 234422",
		"SPELL_AURA_APPLIED_DOSE 234422",
		"UNIT_DIED",
		"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3"
	)

	--Tank
	-- Stack warning? what amounts switch from reg warning to special warning?
	-- Improve timers still with more data?
	--Tank (Kruul)
	local warnHolyWard				= mod:NewCastAnnounce(233473, 1)
	local warnDecay					= mod:NewStackAnnounce(234422, 3)
	local warnShadowSweep			= mod:NewSpellAnnounce(234441, 3)
	----Add Spawns
	local warnTormentingEye			= mod:NewSpellAnnounce(234428, 2)
	local warnNetherAberration		= mod:NewSpellAnnounce(235110, 2)
	local warnInfernal				= mod:NewSpellAnnounce(235112, 2)

	--Tank
	local specWarnDecay				= mod:NewSpecialWarningStack(234422, nil, 5, nil, nil, 1, 6, nil, nil, "stackhigh")
	local specWarnDrainLife			= mod:NewSpecialWarningInterrupt(234423, nil, nil, 2, 3, 2, nil, nil, "kickcast")
	local specWarnSmash				= mod:NewSpecialWarningDodge(234631, nil, nil, nil, 1, 2, nil, nil, "shockwave")
	local specWarnAnnihilate		= mod:NewSpecialWarningDefensive(236572, nil, nil, nil, 1, 2, nil, nil, "defensive")
	local specWarnTwistedReflection	= mod:NewSpecialWarningInterrupt(234676, nil, nil, nil, 3, 2, nil, nil, "kickcast")

	--Tank
	local timerDrainLifeCD			= mod:NewCDTimer(24.3, 234423, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON, nil, 2, 4)
	local timerHolyWardCD			= mod:NewCDTimer(33, 233473, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
	local timerHolyWard				= mod:NewCastTimer(8, 233473, nil, false, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
	local timerTormentingEyeCD		= mod:NewCDTimer(15.4, 234428, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)--15.4-19.4
	local timerNetherHorrorsCD	= mod:NewCDTimer(35, 235110, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON, nil, 1, 4)
	local timerInfernalCD			= mod:NewCDTimer(65, 235112, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON, nil, 3, 4)
	--Phase 2
	local timerShadowSweepCD		= mod:NewCDTimer(20, 234441, nil, nil, nil, 3)--20-27
	local timerAnnihilateCD			= mod:NewCDCountTimer(27, 236572, nil, nil, nil, 3, nil, DBM_COMMON_L.TANK_ICON, nil, 2, 4)

	mod.vb.annihilateCast = 0
	local activeBossGUIDS = {}

	function mod:OnCombatStart(delay)
		self:SetStage(1)
		self.vb.annihilateCast = 0
		timerTormentingEyeCD:Start(3.8)--3.8-5
		timerDrainLifeCD:Start(5)--5-9?
		timerHolyWardCD:Start(8)--8-16
		timerNetherHorrorsCD:Start(9.6)--9.6-12.3
		timerInfernalCD:Start(37.5)--37-43
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 234423 then
			specWarnDrainLife:Show(args.sourceName)
			specWarnDrainLife:Play("kickcast")
			timerDrainLifeCD:Start()
		elseif spellId == 233473 then
			warnHolyWard:Show()
			timerHolyWard:Start()
			timerHolyWardCD:Start()
		elseif (spellId == 234631 or spellId == 241717 or spellId == 236537) and self:AntiSpam(2.5, 1) then
			specWarnSmash:Show()
			specWarnSmash:Play("shockwave")
		elseif spellId == 236572 then
			specWarnAnnihilate:Show()
			specWarnAnnihilate:Play("defensive")
		elseif spellId == 234676 then
			specWarnTwistedReflection:Show(args.sourceName)
			specWarnTwistedReflection:Play("kickcast")
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellId == 236572 then--Timer here, boss sometimes stutter casts/interrupts his own annihilate cast to do soething else, then returns to annihilate 4-5 seconds later
			self.vb.annihilateCast = self.vb.annihilateCast + 1
			timerAnnihilateCD:Start(25, self.vb.annihilateCast+1)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 234422 then
			local amount = args.amount or 1
			if amount >= 5 then
				specWarnDecay:Show(amount)
				if amount > 10 then
					specWarnDecay:Play("runout")
				else
					specWarnDecay:Play("stackhigh")
				end
			elseif amount % 2 == 0 then
				warnDecay:Show(args.destName, amount)
			end
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

	function mod:UNIT_DIED(args)
		if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe
			DBM:EndCombat(self, true)
		end
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 117933 then--Variss
			self:SetStage(2)
			timerDrainLifeCD:Stop()
			timerTormentingEyeCD:Stop()
			timerNetherHorrorsCD:Stop()
			timerInfernalCD:Stop()
			--timerAnnihilateCD:Start(16.5, 1)--16-28?, too variable, disabled for now
			--Does holy ward reset here? reset timer here if it does
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 234428 then--Summon Tormenting Eye
			warnTormentingEye:Show()
			timerTormentingEyeCD:Start()
		elseif spellId == 235110 then--Nether Aberration
			warnNetherAberration:Show()
			if self.vb.phase == 2 then
				timerNetherHorrorsCD:Start(30)
			else
				timerNetherHorrorsCD:Start()--35
			end
		elseif spellId == 235112 then--Smoldering Infernal Summon
			warnInfernal:Show()
			timerInfernalCD:Start()
		elseif spellId == 234920 then
			warnShadowSweep:Show()
			timerShadowSweepCD:Start()
		elseif spellId == 233456 then--Kill Credit
			DBM:EndCombat(self)
		end
	end
end
