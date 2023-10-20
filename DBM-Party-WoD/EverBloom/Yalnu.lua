local mod	= DBM:NewMod(1210, "DBM-Party-WoD", 5, 556)
local L		= mod:GetLocalizedStrings()
local wowToc = DBM:GetTOC()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"

if (wowToc >= 100200) then
	mod.upgradedMPlus = true
	mod.sendMainBossGUID = true
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(83846)
mod:SetEncounterID(1756)

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
	--10.1.7 on retail, and classic if it happens (if it doesn't happen old version of mod will be retired)
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 169179 169613",
		"SPELL_CAST_SUCCESS 169251",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	local warnFontofLife			= mod:NewSpellAnnounce(169120, 3)--Does this need a switch warning too?

	local specWarnColossalBlow		= mod:NewSpecialWarningDodge(169179, nil, nil, nil, 2, 2)
	local specWarnEntanglement		= mod:NewSpecialWarningSwitch(169251, "Dps", nil, nil, 1, 2)
	local specWarnGenesis			= mod:NewSpecialWarningSpell(169613, nil, nil, nil, 1, 12)--Everyone. "Switch" is closest generic to "run around stomping flowers"

	--Only timers that were consistent, others are all over the place.
	local timerFontOfLife			= mod:NewNextTimer(15, 169120, nil, nil, nil, 1)
	local timerGenesis				= mod:NewCastTimer(17, 169613, nil, nil, nil, 5)
	local timerGenesisCD			= mod:NewNextTimer(60.5, 169613, nil, nil, nil, 6)

	function mod:OnCombatStart(delay)
		--timerFontOfLife:Start(-delay)
		--timerGenesisCD:Start(25-delay)
	end

	function mod:SPELL_CAST_START(args)
		local spellId = args.spellId
		if spellId == 169179 then
			specWarnColossalBlow:Show()
			specWarnColossalBlow:Play("shockwave")
		elseif spellId == 169613 then
			specWarnGenesis:Show()
			specWarnGenesis:Play("runoverflowers")
			timerGenesis:Start()
			timerGenesisCD:Start()
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellId == 169251 then
			specWarnEntanglement:Show()
			specWarnEntanglement:Play("targetchange")
		end
	end

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 169120 then
			warnFontofLife:Show()
			timerFontOfLife:Start()
		end
	end
end
