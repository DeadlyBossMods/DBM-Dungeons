local mod	= DBM:NewMod(132, "DBM-Party-Cataclysm", 3, 71)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
	mod.upgradedMPlus = true
else
	mod.statTypes = "normal,heroic"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(40177)
mod:SetEncounterID(1050)
mod:SetHotfixNoticeRev(20240614000000)
--mod:SetMinSyncRevision(20230929000000)
mod:SetZone(670)

mod:RegisterCombat("combat")

if mod:IsRetail() then
	--Retail version of mod
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 451996 456902 456900 447395 449444 449687",
		"SPELL_AURA_APPLIED 449474",
		"SPELL_AURA_REMOVED 449474",
		"SPELL_DAMAGE",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	--[[
	(ability.id = 451996 or ability.id = 456902 or ability.id = 456900 or ability.id = 447395 or ability.id = 449444 or ability.id = 449687) and type = "begincast"
	or type = "dungeonencounterstart" or type = "dungeonencounterend"
	--]]
	local warnForgeAxe			= mod:NewCountAnnounce(451996, 2)
	local warnForgeSword		= mod:NewCountAnnounce(456902, 2)
	local warnForgeMace			= mod:NewCountAnnounce(456900, 2)

	local specWarnMoltenCleave	= mod:NewSpecialWarningDodge(447395, nil, nil, nil, 2, 2)
	local specWarnMoltenFlurry	= mod:NewSpecialWarningDefensive(449444, nil, nil, nil, 2, 2)
	local specWarnMoltenSpark	= mod:NewSpecialWarningMoveAway(449474, nil, nil, nil, 1, 2)
	local yellMoltenSpark		= mod:NewShortYell(449474)
	local yellMoltenSparkFades	= mod:NewShortFadesYell(449474)
	local specWarnMoltenMace	= mod:NewSpecialWarningRun(449687, nil, nil, nil, 4, 2)
	--local specWarnGTFO			= mod:NewSpecialWarningGTFO(74987, nil, nil, nil, 1, 8)

	local timerForgeAxeCD		= mod:NewCDCountTimer(60, 451996, nil, nil, nil, 6)
	local timerMoltenCleaveCD	= mod:NewCDTimer(60, 447395, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerForgeSwordCD		= mod:NewCDCountTimer(60, 456902, nil, nil, nil, 6)
	local timerMoltenFlurryCD	= mod:NewCDTimer(60, 449444, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
	local timerForgeMaceCD		= mod:NewCDCountTimer(60, 456900, nil, nil, nil, 6)
	local timerMoltenMaceCD		= mod:NewCDTimer(60, 449687, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

	mod.vb.weaponCount = 0

	function mod:OnCombatStart(delay)
		self.vb.weaponCount = 0
		timerForgeAxeCD:Start(8.4, 1)
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 451996 then
			self.vb.weaponCount = self.vb.weaponCount + 1
			warnForgeAxe:Show(self.vb.weaponCount)
			timerMoltenCleaveCD:Start(10.9)
			timerForgeSwordCD:Start(19.5, self.vb.weaponCount+1)
		elseif args.spellId == 456902 then
			self.vb.weaponCount = self.vb.weaponCount + 1
			warnForgeSword:Show(self.vb.weaponCount)
			timerMoltenFlurryCD:Start(10.9)
			timerForgeMaceCD:Start(20.6, self.vb.weaponCount+1)
		elseif args.spellId == 456900 then
			self.vb.weaponCount = self.vb.weaponCount + 1
			warnForgeMace:Show(self.vb.weaponCount)
			timerMoltenMaceCD:Start(7.2)
			timerForgeAxeCD:Start(20.6, self.vb.weaponCount+1)
		elseif args.spellId == 447395 then
			specWarnMoltenCleave:Show()
			specWarnMoltenCleave:Play("shockwave")
		elseif args.spellId == 449444 then
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnMoltenFlurry:Show()
				specWarnMoltenFlurry:Play("defensive")
			end
		elseif args.spellId == 449687 then
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnMoltenMace:Show()
				specWarnMoltenMace:Play("justrun")
			end
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 449474 then
			if args:IsPlayer() then
				specWarnMoltenSpark:Show()
				specWarnMoltenSpark:Play("runout")
				yellMoltenSpark:Yell()
				yellMoltenSparkFades:Countdown(spellId)
			end
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellId == 449474 and args:IsPlayer() then
			yellMoltenSparkFades:Cancel()
		end
	end
else
	--Cataclysm version of mod
	mod:RegisterEventsInCombat(
		"SPELL_CAST_START 75000",
		"SPELL_AURA_APPLIED 74981 75007 74908 74976 74987",
		"SPELL_DAMAGE 90754",
		"UNIT_SPELLCAST_SUCCEEDED boss1"
	)

	local warnPickWeapon		= mod:NewCountAnnounce(75000, 3)
	local warnDualBlades		= mod:NewSpellAnnounce(74981, 3)
	local warnEncumbered		= mod:NewSpellAnnounce(75007, 3)
	local warnPhalanx			= mod:NewSpellAnnounce(74908, 3)
	local warnDisorientingRoar	= mod:NewSpellAnnounce(74976, 3)

	local specWarnGTFO			= mod:NewSpecialWarningGTFO(74987, nil, nil, nil, 1, 8)
	local specWarnEncumbered	= mod:NewSpecialWarningRun(75007, "Tank", nil, nil, 4, 2)
	local specWarnFlamingShield	= mod:NewSpecialWarningDodge(90819, nil, nil, nil, 2, 12)

	local timerDualBlades		= mod:NewBuffActiveTimer(30, 74981, nil, nil, nil, 6)
	local timerEncumbered		= mod:NewBuffActiveTimer(30, 75007, nil, nil, nil, 6)
	local timerPhalanx			= mod:NewBuffActiveTimer(30, 74908, nil, nil, nil, 6)

	mod.vb.weaponCount = 0

	function mod:OnCombatStart(delay)
		self.vb.weaponCount = 0
	end

	function mod:SPELL_CAST_START(args)
		if args.spellId == 75000 then
			self.vb.weaponCount = self.vb.weaponCount + 1
			warnPickWeapon:Show(self.vb.weaponCount)
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		local spellId = args.spellId
		if spellId == 74981 then
			warnDualBlades:Show()
			timerDualBlades:Start()
		elseif spellId == 75007 then
			if self.Options.SpecWarn75007run then
				specWarnEncumbered:Show()
				specWarnEncumbered:Play("justrun")
			else
				warnEncumbered:Show()
			end
			timerEncumbered:Start()
		elseif spellId == 74908 then
			warnPhalanx:Show()
			timerPhalanx:Start()
		elseif spellId == 74976 and self:AntiSpam(10, 1) then
			warnDisorientingRoar:Show()
		elseif spellId == 74987 and args:IsPlayer() then
			specWarnGTFO:Show(args.spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end

	function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
		if spellId == 90754 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
			specWarnGTFO:Show(spellName)
			specWarnGTFO:Play("watchfeet")
		end
	end
	--mod.SPELL_MISSED = mod.SPELL_DAMAGE

	function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
		if spellId == 75071 then--Fixate effect (cast twice during phalanx phase, when boss prepares fire breath
			specWarnFlamingShield:Show()
			specWarnFlamingShield:Play("flamejet")
		end
	end
end
