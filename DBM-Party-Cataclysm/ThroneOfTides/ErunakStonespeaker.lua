local mod	= DBM:NewMod(103, "DBM-Party-Cataclysm", 9, 65)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

if (wowToc >= 100200) then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else
	mod.statTypes = "normal,heroic"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40825, 40788)
mod:SetMainBossID(40788)-- 40788 = Mindbender Ghur'sha
mod:SetEncounterID(1046)

mod:RegisterCombat("combat")

if (wowToc >= 100200) then
	--Patch 10.2 or later
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 429051 429037 429172",
		"SPELL_CAST_SUCCESS 429173 429048",
		"SPELL_AURA_APPLIED 429048"
	--	"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--[[
(ability.id = 429051 or ability.id = 429037 or ability.id = 429172) and type = "begincast"
 or (ability.id = 429173 or ability.id = 429048) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	--TODO, better Stage 2 detection, mind rot is kind of a crappy solution but it's all i could find on WCL
	--TODO longer stage 2s to get repeat timer for fear
	--Erunak Stonespeaker
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(2194))
	local warnFlameShock								= mod:NewTargetNoFilterAnnounce(429048, 3)

	local specWarnEarthfury								= mod:NewSpecialWarningDodge(429051, nil, nil, nil, 2, 2)
	local specWarnStormflurryTotem						= mod:NewSpecialWarningSwitchCount(429037, "-Healer", nil, nil, 1, 2)

	--local specWarnGTFO								= mod:NewSpecialWarningGTFO(409058, nil, nil, nil, 1, 8)

	local timerEarthfuryCD								= mod:NewCDTimer(32.7, 429051, nil, nil, nil, 3)
	local timerStormflurryTotemCD						= mod:NewCDCountTimer(26.6, 429037, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerFlameShockCD								= mod:NewCDTimer(6, 429048, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)

	--Mindbender Ghur'sha
	mod:AddTimerLine(DBM:EJ_GetSectionInfo(2199))
	local warnPhase2									= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)

	local specWarnTerrifyingVision						= mod:NewSpecialWarningMoveTo(429172, nil, nil, nil, 2, 13)

	local timerTerrifyingVisionCD						= mod:NewCDTimer(100, 429172, nil, nil, nil, 2)

	mod.vb.totemCount = 0

	function mod:OnCombatStart(delay)
		self:SetStage(1)
		self.vb.totemCount = 0
		timerFlameShockCD:Start(6-delay)
		timerStormflurryTotemCD:Start(12.1-delay, 1)
		timerEarthfuryCD:Start(20.3-delay)
	end

	--function mod:OnCombatEnd()
	--	if self.Options.RangeFrame then
	--		DBM.RangeCheck:Hide()
	--	end
	--end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 429051 then
			specWarnEarthfury:Schedule(2)--2.5 second cast, I want alert at 2 so it is just slightly faster than using success
			specWarnEarthfury:ScheduleVoice(2, "keepmove")
			timerEarthfuryCD:Start()
		elseif spellId == 429037 then
			self.vb.totemCount = self.vb.totemCount + 1
			specWarnStormflurryTotem:Show(self.vb.totemCount)
			specWarnStormflurryTotem:Play("attacktotem")
			timerStormflurryTotemCD:Start(nil, self.vb.totemCount+1)
		elseif spellId == 429172 then
			specWarnTerrifyingVision:Show(DBM_COMMON_L.BREAK_LOS)
			specWarnTerrifyingVision:Play("breaklos")
--			timerTerrifyingVisionCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 429173 and self:GetStage(1) then
			self:SetStage(2)
			timerEarthfuryCD:Stop()
			timerStormflurryTotemCD:Stop()
			timerFlameShockCD:Stop()
			warnPhase2:Show()
			warnPhase2:Play("ptwo")
			timerTerrifyingVisionCD:Start(7.2)
		elseif spellId == 429048 then
			timerFlameShockCD:Start()
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 429048 and args:IsPlayer() or self:CheckDispelFilter("magic") then
			warnFlameShock:Show(args.destName)
		end
	end

	--[[
	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 405814 then

		end
	end
	--]]
else
	--10.1.7 on retail, and Cataclysm classic if it happens (if it doesn't happen old version of mod will be retired)
	mod:RegisterEventsInCombat(
		"SPELL_AURA_APPLIED 76170 76165 76207 76307 76339",
		"SPELL_AURA_REMOVED 76170 76616",
		"SPELL_CAST_START 76171 84931 76307",
		"SPELL_CAST_SUCCESS 76234",
		"UNIT_DIED"
	)

	local warnMagmaSplash		= mod:NewTargetNoFilterAnnounce(76170, 3, nil, "Healer", 2)
	local warnEmberstrike		= mod:NewTargetNoFilterAnnounce(76165, 3, nil, "Healer", 2)
	local warnEarthShards		= mod:NewTargetAnnounce(84931, 2)
	local warnPhase2			= mod:NewPhaseAnnounce(2)
	local warnEnslave			= mod:NewTargetNoFilterAnnounce(76207, 2)
	local warnMindFog			= mod:NewSpellAnnounce(76234, 3)
	local warnAgony				= mod:NewSpellAnnounce(76339, 3)

	local specWarnLavaBolt		= mod:NewSpecialWarningInterrupt(76171, nil, nil, nil, 1, 2)
	local specWarnAbsorbMagic	= mod:NewSpecialWarningReflect(76307, "SpellCaster", nil, nil, 1, 2)
	local specWarnEarthShards	= mod:NewSpecialWarningYou(84931, nil, nil, nil, 1, 2)
	local yellEarthShards		= mod:NewShortYell(84931)

	local timerMagmaSplash		= mod:NewBuffActiveTimer(10, 76170, nil, "Healer", nil, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.MAGIC_ICON)
	local timerAbsorbMagic		= mod:NewBuffActiveTimer(3, 76307, nil, "SpellCaster", 2, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerMindFog			= mod:NewBuffActiveTimer(20, 76234, nil, nil, nil, 3)

	local magmaTargets = {}
	mod.vb.magmaCount = 0

	local function showMagmaWarning()
		warnMagmaSplash:Show(table.concat(magmaTargets, "<, >"))
		table.wipe(magmaTargets)
		timerMagmaSplash:Start()
	end

	function mod:EarthShardsTarget(targetname, uId)
		if not targetname then return end
		if targetname == UnitName("player") then
			specWarnEarthShards:Show()
			specWarnEarthShards:Play("targetyou")
			yellEarthShards:Yell()
		else
			warnEarthShards:Show(targetname)
		end
	end

	function mod:OnCombatStart(delay)
		table.wipe(magmaTargets)
		self.vb.magmaCount = 0
	end

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 76170 then
			self.vb.magmaCount = self.vb.magmaCount + 1
			magmaTargets[#magmaTargets + 1] = args.destName
			self:Unschedule(showMagmaWarning)
			self:Schedule(0.3, showMagmaWarning)
		elseif args.spellId == 76165 then
			warnEmberstrike:Show(args.destName)
		elseif args.spellId == 76207 then
			warnEnslave:Show(args.destName)
		elseif args.spellId == 76307 then
			timerAbsorbMagic:Start()
		elseif args.spellId == 76339 then
			warnAgony:Show()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellId == 76170 then
			self.vb.magmaCount = self.vb.magmaCount - 1
			if self.vb.magmaCount == 0 then
				timerMagmaSplash:Cancel()
			end
		elseif args.spellId == 76616 then
			if args.destName == L.name then
				warnPhase2:Show(2)
			end
		end
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 76171 and self:CheckInterruptFilter(args.sourceGUID, false, true, true) then
			specWarnLavaBolt:Show(args.sourceName)
			specWarnLavaBolt:Play("kickcast")
		elseif args.spellId == 84931 then
			self:BossTargetScanner(args.sourceGUID, "EarthShardsTarget", 0.1, 6)
		elseif args.spellId == 76307 then
			specWarnAbsorbMagic:Show(args.sourceName)
			specWarnAbsorbMagic:Play("stopattack")
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellId == 76234 then
			warnMindFog:Show()
			timerMindFog:Start()
		end
	end

	function mod:UNIT_DIED(args)
		if self:GetCIDFromGUID(args.destGUID) == 40788 then
			DBM:EndCombat(self)
		end
	end
end
