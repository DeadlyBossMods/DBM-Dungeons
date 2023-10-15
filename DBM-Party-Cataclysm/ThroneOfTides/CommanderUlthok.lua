local mod	= DBM:NewMod(102, "DBM-Party-Cataclysm", 9, 65)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

if (wowToc >= 100200) then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else--TODO, refine for cata classic since no timewalker there
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40765)
mod:SetEncounterID(1044)

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
		"SPELL_AURA_APPLIED 76094 76100 76026",
		"SPELL_CAST_START 76047 76100"
	)

	--TODO, GTFO for void zones
	local warnDarkFissure		= mod:NewSpellAnnounce(76047, 4)
	local warnSqueeze			= mod:NewTargetNoFilterAnnounce(76026, 3)
	local warnEnrage			= mod:NewSpellAnnounce(76100, 2, nil, "Tank")

	local specWarnCurse			= mod:NewSpecialWarningDispel(76094, "RemoveCurse", nil, 2, 1, 2)
	local specWarnFissure		= mod:NewSpecialWarningDodge(76047, "Tank", nil, nil, 1, 2)

	local timerDarkFissureCD	= mod:NewCDTimer(18.4, 76047, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerSqueeze			= mod:NewTargetTimer(6, 76026, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
	local timerSqueezeCD		= mod:NewCDTimer(29, 76026, nil, nil, nil, 3)
	local timerEnrage			= mod:NewBuffActiveTimer(10, 76100, nil, "Tank|Healer", 2, 5)

	function mod:SPELL_AURA_APPLIED(args)
		if args.spellId == 76094 and self:CheckDispelFilter("curse") then
			specWarnCurse:Show(args.destName)
			specWarnCurse:Play("helpdispel")
		elseif args.spellId == 76100 then
			timerEnrage:Start()
		elseif args.spellId == 76026 then
			warnSqueeze:Show(args.destName)
			timerSqueeze:Start(args.destName)
			timerSqueezeCD:Start()
		end
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 76047 then
			if self.Options.SpecWarn76047dodge then
				specWarnFissure:Show()
				specWarnFissure:Play("shockwave")
			else
				warnDarkFissure:Show()
			end
			timerDarkFissureCD:Start()
		elseif args.spellId == 76100 then
			warnEnrage:Show()
		end
	end
end
