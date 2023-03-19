local mod	= DBM:NewMod("UnderrotTrash", "DBM-Party-BfA", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true


mod:RegisterEvents(
	"SPELL_CAST_START 272609 266106 265019 265089 265091 265433 265540 272183 278961 265523 278755 265568 265487 272592 265081 272180",
	"SPELL_AURA_APPLIED 265568 266107 266209",
	"SPELL_CAST_SUCCESS 265523"
)

--TODO, verify dark omen can actually be stunned/CCed
local warnGiftOfGhuun				= mod:NewCastAnnounce(265091, 3)
local warnDarkReconstitution		= mod:NewCastAnnounce(265089, 3)
local warnDarkOmen					= mod:NewCastAnnounce(265568, 3, nil, nil, nil, nil, nil, 3)
local warnSonicSreech				= mod:NewCastAnnounce(266106, 3)
local warnRaiseDead					= mod:NewCastAnnounce(272183, 3)
local warnShadowBoltVolley			= mod:NewCastAnnounce(265487, 3)
local warnWitheringCurse			= mod:NewCastAnnounce(265433, 3)
local warnAbyssalReach				= mod:NewCastAnnounce(272592, 2)
local warnWarcry					= mod:NewCastAnnounce(265081, 4)

--local yellArrowBarrage			= mod:NewYell(200343)
local specWarnMaddeningGaze			= mod:NewSpecialWarningDodge(272609, nil, nil, nil, 2, 2)
local specWarnSavageCleave			= mod:NewSpecialWarningDodge(265019, nil, nil, nil, 2, 2)
local specWarnRottenBile			= mod:NewSpecialWarningDodge(265540, nil, nil, nil, 2, 2)
local specWarnDarkOmen				= mod:NewSpecialWarningMoveAway(265568, nil, nil, nil, 1, 2)
local yellDarkOmen					= mod:NewShortYell(265568)
local specWarnThirstforBlood		= mod:NewSpecialWarningRun(266107, nil, nil, nil, 4, 2)
local specWarnSonicScreech			= mod:NewSpecialWarningInterrupt(266106, "HasInterrupt", nil, nil, 1, 2)
local specWarnDarkReconstituion		= mod:NewSpecialWarningInterrupt(265089, "HasInterrupt", nil, nil, 1, 2)
local specWarnGiftofGhuun			= mod:NewSpecialWarningInterrupt(265091, "HasInterrupt", nil, nil, 1, 2)
local specWarnShadowBoltVolley		= mod:NewSpecialWarningInterrupt(265487, "HasInterrupt", nil, nil, 1, 2)
local specWarnWitheringCurse		= mod:NewSpecialWarningInterrupt(265433, "HasInterrupt", nil, nil, 1, 2)
local specWarnRaiseDead				= mod:NewSpecialWarningInterrupt(272183, "HasInterrupt", nil, nil, 1, 2)
local specWarnDecayingMind			= mod:NewSpecialWarningInterrupt(278961, "HasInterrupt", nil, nil, 1, 2)
local specWarnHarrowingDespair		= mod:NewSpecialWarningInterrupt(278755, "HasInterrupt", nil, nil, 1, 2)
local specWarnSpiritDrainTotem		= mod:NewSpecialWarningInterrupt(265523, "HasInterrupt", nil, nil, 1, 2)
local specWarnDeathBolt				= mod:NewSpecialWarningInterrupt(272180, "HasInterrupt", nil, nil, 1, 2)
local specWarnWickedFrenzy			= mod:NewSpecialWarningDispel(266209, "RemoveEnrage", nil, nil, 1, 2)
local specWarnSpiritDrainTotemKill	= mod:NewSpecialWarningDodge(265523, nil, nil, nil, 2, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 272609 and self:AntiSpam(3, 2) then
		specWarnMaddeningGaze:Show()
		specWarnMaddeningGaze:Play("shockwave")
	elseif spellId == 265019 and self:AntiSpam(3, 2) then
		specWarnSavageCleave:Show()
		specWarnSavageCleave:Play("shockwave")
	elseif spellId == 265540 and self:AntiSpam(3, 2) then
		specWarnRottenBile:Show()
		specWarnRottenBile:Play("shockwave")
	elseif spellId == 266106 then
		if self.Options.SpecWarn266106interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSonicScreech:Show(args.sourceName)
			specWarnSonicScreech:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnSonicSreech:Show()
		end
	elseif spellId == 265089 then
		if self.Options.SpecWarn265089interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDarkReconstituion:Show(args.sourceName)
			specWarnDarkReconstituion:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnDarkReconstitution:Show()
		end
	elseif spellId == 265091 then
		if self.Options.SpecWarn265091interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGiftofGhuun:Show(args.sourceName)
			specWarnGiftofGhuun:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnGiftOfGhuun:Show()
		end
	elseif spellId == 265433 then
		if self.Options.SpecWarn265433interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnWitheringCurse:Show(args.sourceName)
			specWarnWitheringCurse:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnWitheringCurse:Show()
		end
	elseif spellId == 272183 then
		if self.Options.SpecWarn272183interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRaiseDead:Show(args.sourceName)
			specWarnRaiseDead:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnRaiseDead:Show()
		end
	elseif spellId == 278961 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDecayingMind:Show(args.sourceName)
		specWarnDecayingMind:Play("kickcast")
	elseif spellId == 265523 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSpiritDrainTotem:Show(args.sourceName)
		specWarnSpiritDrainTotem:Play("kickcast")
	elseif spellId == 278755 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnHarrowingDespair:Show(args.sourceName)
		specWarnHarrowingDespair:Play("kickcast")
	elseif spellId == 272180 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDeathBolt:Show(args.sourceName)
		specWarnDeathBolt:Play("kickcast")
	elseif spellId == 265568 and self:AntiSpam(3, 5) then
		warnDarkOmen:Show()
		warnDarkOmen:Play("crowdcontrol")
	elseif spellId == 265487 then
		if self.Options.SpecWarn265487interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnShadowBoltVolley:Show(args.sourceName)
			specWarnShadowBoltVolley:Play("kickcast")
		elseif self:AntiSpam(2, 5) then
			warnShadowBoltVolley:Show()
		end
	elseif spellId == 272592 and self:AntiSpam(3, 6) then--Lower prio dodge but still mild alert worthy
		warnAbyssalReach:Show()
	elseif spellId == 265081 and self:AntiSpam(3, 5) then
		warnWarcry:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 265568 and args:IsPlayer() and not DBM:UnitDebuff("player", spellId) then
		specWarnDarkOmen:Show()
		specWarnDarkOmen:Play("range5")
		yellDarkOmen:Yell()
	elseif spellId == 266107 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnThirstforBlood:Show()
		specWarnThirstforBlood:Play("justrun")
	elseif spellId == 266209 and self:AntiSpam(3, 5) then
		specWarnWickedFrenzy:Show(args.destName)
		specWarnWickedFrenzy:Play("enrage")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 265523 and self:AntiSpam(3, 2) then
		specWarnSpiritDrainTotemKill:Show()
		specWarnSpiritDrainTotemKill:Play("watchstep")
	end
end
