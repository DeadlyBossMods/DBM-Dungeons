local mod	= DBM:NewMod(101, "DBM-Party-Cataclysm", 9, 65)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

if (wowToc >= 100200) then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else--TODO, refine for cata classic since no timewalker there
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40586)
mod:SetEncounterID(1045)

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
