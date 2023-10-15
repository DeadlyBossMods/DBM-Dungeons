local mod	= DBM:NewMod(103, "DBM-Party-Cataclysm", 9, 65)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

if (wowToc >= 100200) then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else--TODO, refine for cata classic since no timewalker there
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40825, 40788)
mod:SetMainBossID(40788)-- 40788 = Mindbender Ghur'sha
mod:SetEncounterID(1046)

mod:RegisterCombat("combat")

if (wowToc >= 100200) then
	--Patch 10.2 or later
	mod:RegisterEventsInCombat(
	--	"SPELL_CAST_START",
	--	"SPELL_CAST_SUCCESS",
	--	"SPELL_AURA_APPLIED",
	--	"SPELL_AURA_APPLIED_DOSE",
	--	"SPELL_AURA_REMOVED",
	--	"SPELL_AURA_REMOVED_DOSE",
	--	"SPELL_PERIODIC_DAMAGE",
	--	"SPELL_PERIODIC_MISSED",
	--	"UNIT_DIED",
	--	"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--[[

	--]]
	--mod:AddTimerLine(DBM:EJ_GetSectionInfo(22309))
	--local warnPhase									= mod:NewPhaseChangeAnnounce(2, nil, nil, nil, nil, nil, 2)
	--local warnSpreadshot								= mod:NewSpellAnnounce(334404, 3)

	--local specWarnSinseeker							= mod:NewSpecialWarningYou(335114, nil, nil, nil, 3, 2)
	--local yellSinseeker								= mod:NewShortYell(335114)
	--local specWarnPyroBlast							= mod:NewSpecialWarningInterrupt(396040, "HasInterrupt", nil, nil, 1, 2)
	--local specWarnGTFO								= mod:NewSpecialWarningGTFO(409058, nil, nil, nil, 1, 8)

	--local timerSinseekerCD							= mod:NewAITimer(49, 335114, nil, nil, nil, 3)
	--local timerSpreadshotCD							= mod:NewAITimer(11.8, 334404, nil, nil, nil, 2, nil, DBM_COMMON_L.TANK_ICON)

	--mod:AddRangeFrameOption("5/6/10")
	--mod:AddSetIconOption("SetIconOnSinSeeker", 335114, true, false, {1, 2, 3})

	--function mod:OnCombatStart(delay)

	--end

	--function mod:OnCombatEnd()
	--	if self.Options.RangeFrame then
	--		DBM.RangeCheck:Hide()
	--	end
	--end

	--[[
	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 335114 then
	--		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--
	--		end
		end
	end
	--]]

	--[[
	function mod:SPELL_CAST_SUCCESS(args)
		local spellId = args.spellId
		if spellId == 334945 then

		end
	end
	--]]

	--[[
	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 334971 then

		end
	end
	--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
	--]]

	--[[
	function mod:SPELL_AURA_REMOVED(args)
		local spellId = args.spellId
		if spellId == 334945 then

		end
	end
	--mod.SPELL_AURA_REMOVED_DOSE = mod.SPELL_AURA_REMOVED
	--]]

	--[[
	function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 409058 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

	function mod:UNIT_DIED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if cid == 165067 then

		end
	end

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
