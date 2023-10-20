local mod	= DBM:NewMod(1208, "DBM-Party-WoD", 5, 556)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

if (wowToc >= 100200) then
	mod.upgradedMPlus = true
	mod.sendMainBossGUID = true
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(82682)
mod:SetEncounterID(1751)

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

	--local warnSpreadshot								= mod:NewSpellAnnounce(334404, 3)

	--local specWarnSinseeker							= mod:NewSpecialWarningYou(335114, nil, nil, nil, 3, 2)
	--local yellSinseeker								= mod:NewShortYell(335114)
	--local specWarnPyroBlast							= mod:NewSpecialWarningInterrupt(396040, "HasInterrupt", nil, nil, 1, 2)
	--local specWarnGTFO								= mod:NewSpecialWarningGTFO(409058, nil, nil, nil, 1, 8)

	--local timerSinseekerCD							= mod:NewAITimer(49, 335114, nil, nil, nil, 3)
	--local timerSpreadshotCD							= mod:NewAITimer(11.8, 334404, nil, nil, nil, 2, nil, DBM_COMMON_L.TANK_ICON)

	--mod:AddRangeFrameOption("5/6/10")
	--mod:AddInfoFrameOption(407919, true)
	--mod:AddSetIconOption("SetIconOnSinSeeker", 335114, true, false, {1, 2, 3})

	function mod:OnCombatStart(delay)

	end

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
