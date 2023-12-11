local mod	= DBM:NewMod("WaycrestTrash", "DBM-Party-BfA", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(1862)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 263959 265881 265876 265368 266036 278551 265759 264038 263905 265407 263961 267824 265372 265371 426541 264390 260699 264050 265352 264150 265760 278444 263943 271174 265346 264407",
	"SPELL_CAST_SUCCESS 264556 271175 264105 265880",--257260
	"SPELL_AURA_APPLIED 265880 264105 265368 264390 257260 263943",
	"SPELL_AURA_REMOVED 265880 264105",
	"UNIT_DIED"
)

--[[
(ability.id = 263959 or ability.id = 265881 or ability.id = 265876 or ability.id = 265368 or ability.id = 266036 or ability.id = 278551 or ability.id = 265759 or ability.id = 264038 or ability.id = 263905 or ability.id = 265407 or ability.id = 263961 or ability.id = 267824 or ability.id = 265372 or ability.id = 265371 or ability.id = 426541 or ability.id = 264390 or ability.id = 260699 or ability.id = 264050 or ability.id = 265352 or ability.id = 264150 or ability.id = 265760 or ability.id = 278444 or ability.id = 263943 or ability.id = 271174 or ability.id = 265346 or ability.id = 264407) and type = "begincast"
 or (ability.id = 264556 or ability.id = 271175 or ability.id = 264105 or ability.id = 265880 or ability.id = 257260) and type = "cast"
--]]
--TODO, Ravaging Leap announce? not like target scan is doable since it's instant cast, anyways, and warning who already got hit isn't useful.
--TODO, Dark Leap trash version?
local warnSoulVolley				= mod:NewCastAnnounce(263959, 4)--Off Interrupt for HIgh prio
local warnRuinousVolley				= mod:NewCastAnnounce(265876, 4)--Off Interrupt for HIgh prio
local warnSpellbind					= mod:NewCastAnnounce(264390, 4)--Off Interrupt for HIgh prio
local warnToadBlight				= mod:NewCastAnnounce(265352, 4)
local warnInfest					= mod:NewCastAnnounce(278444, 4)--Off Interrupt for HIgh prio
local warnRetch						= mod:NewCastAnnounce(271174, 4)--Off Interrupt for HIgh prio
local warnPallidGlare				= mod:NewCastAnnounce(265346, 4)--Off Interrupt for HIgh prio
local warnHorrificVisage			= mod:NewCastAnnounce(264407, 4)--Off Interrupt for HIgh prio
local warnFocusedStrike				= mod:NewSpellAnnounce(265371, 3, nil, nil, "Tank")
local warnTearingStrike				= mod:NewSpellAnnounce(264556, 3, nil, nil, "Tank")
local warnEtch						= mod:NewTargetNoFilterAnnounce(263943, 3)

local specWarnShadowCleave			= mod:NewSpecialWarningDodge(265372, nil, nil, nil, 2, 2)
local specWarnSplinterSpike			= mod:NewSpecialWarningDodge(265759, nil, nil, nil, 2, 2)
local specWarnUproot				= mod:NewSpecialWarningDodge(264038, nil, nil, nil, 2, 2)
local specWarnShatter				= mod:NewSpecialWarningDodge(264150, nil, nil, nil, 2, 2)
local specWarnMarkingCleave			= mod:NewSpecialWarningDodge(263905, "Tank", nil, 2, 1, 2)
local specWarnWardingCandle			= mod:NewSpecialWarningMove(263961, "Tank", nil, nil, 1, 2)
local specWarnDreadMark				= mod:NewSpecialWarningMoveAway(265880, nil, nil, nil, 1, 2)
local yellDreadMark					= mod:NewYell(265880)
local yellDreadMarkFades			= mod:NewShortFadesYell(265880)
local specWarnRunicMark				= mod:NewSpecialWarningMoveAway(264105, nil, nil, nil, 1, 2)
local yellRunicMark					= mod:NewYell(264105)
local yellRunicMarkFades			= mod:NewShortFadesYell(264105)
local specWarnSoulVolley			= mod:NewSpecialWarningInterrupt(263959, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnRuinousVolley			= mod:NewSpecialWarningInterrupt(265876, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnSpiritedDefense		= mod:NewSpecialWarningInterrupt(265368, "HasInterrupt", nil, nil, 1, 2)
local specWarnDrainEssence			= mod:NewSpecialWarningInterrupt(266036, "HasInterrupt", nil, nil, 1, 2)
local specWarnInfectedThorn			= mod:NewSpecialWarningInterrupt(264050, "HasInterrupt", nil, nil, 1, 2)
local specWarnSoulFetish			= mod:NewSpecialWarningInterrupt(278551, "HasInterrupt", nil, nil, 1, 2)
local specWarnDinnerBell			= mod:NewSpecialWarningInterrupt(265407, "HasInterrupt", nil, nil, 1, 2)
local specWarnScarSoul				= mod:NewSpecialWarningInterrupt(267824, "HasInterrupt", nil, nil, 1, 2)
local specWarnRunicBolt				= mod:NewSpecialWarningInterrupt(426541, false, nil, nil, 1, 2)--Secondary, spellbind is prio
local specWarnSpellbind				= mod:NewSpecialWarningInterrupt(264390, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnSoulBolt				= mod:NewSpecialWarningInterrupt(260699, false, nil, nil, 1, 2)--Secondary, Soul Volley is prio
local specWarnInfest				= mod:NewSpecialWarningInterrupt(278444, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnRetch					= mod:NewSpecialWarningInterrupt(271174, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnPallidGlare			= mod:NewSpecialWarningInterrupt(265346, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnHorrificVisage		= mod:NewSpecialWarningInterrupt(264407, "HasInterrupt", nil, nil, 1, 2)--High Prio
local specWarnDecayingTouch			= mod:NewSpecialWarningDefensive(265881, nil, nil, nil, 1, 2)
local specWarnThornedBarrage		= mod:NewSpecialWarningDefensive(265760, nil, nil, nil, 1, 2)
local specWarnSpiritedDefenseDispel	= mod:NewSpecialWarningDispel(265368, "MagicDispeller", nil, nil, 1, 2)
local specWarnRunicMarkDispel		= mod:NewSpecialWarningDispel(264105, "RemoveCurse", nil, nil, 1, 2)
local specWarnEnrage				= mod:NewSpecialWarningDispel(257260, "RemoveEnrage", nil, nil, 1, 2)

local timerScarSoulCD				= mod:NewCDNPTimer(12.2, 267824, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--Needs more data
local timerFocusedStrikeCD			= mod:NewCDNPTimer(8.4, 265371, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerShadowCleaveCD			= mod:NewCDNPTimer(12.1, 265372, nil, nil, nil, 3)
local timerSpiritedDefenseCD		= mod:NewCDNPTimer(23, 265368, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRunicMarkCD				= mod:NewCDNPTimer(12.1, 264105, nil, nil, nil, 3)
local timerEtchCD					= mod:NewCDNPTimer(12.1, 263943, nil, nil, nil, 3)
local timerInfectedThornsCD			= mod:NewCDNPTimer(8.5, 264050, nil, nil, nil, 3)
local timerDrainEssenceCD			= mod:NewCDNPTimer(15.7, 266036, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerTearingStrikeCD			= mod:NewCDNPTimer(10.9, 264556, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerUprootCD					= mod:NewCDNPTimer(15.2, 264038, nil, nil, nil, 3)
local timerSplinterSpikeCD			= mod:NewCDNPTimer(15.7, 265759, nil, nil, nil, 3)
local timerThornedBarrageCD			= mod:NewCDNPTimer(11.7, 265760, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerRavagingLeapCD			= mod:NewCDNPTimer(8.5, 271175, nil, nil, nil, 3)
local timerRetchCD					= mod:NewCDNPTimer(20.6, 271174, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDinnerBellCD				= mod:NewCDNPTimer(17, 265407, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSpellbindCD				= mod:NewCDNPTimer(19.2, 264390, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSoulVolleyCD				= mod:NewCDNPTimer(21.8, 263959, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerWardingCandleCD			= mod:NewCDNPTimer(18.2, 263961, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerRuinousoVolleyCD			= mod:NewCDNPTimer(17, 263959, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDreadMarkCD				= mod:NewCDNPTimer(20.7, 265880, nil, nil, nil, 3)
local timerHorrificVisageCD			= mod:NewCDNPTimer(24, 264407, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 gtfo

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 263959 then
		timerSoulVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn263959interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSoulVolley:Show(args.sourceName)
			specWarnSoulVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSoulVolley:Show()
		end
	elseif spellId == 265876 then
		timerRuinousoVolleyCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn265876interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRuinousVolley:Show(args.sourceName)
			specWarnRuinousVolley:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnRuinousVolley:Show()
		end
	elseif spellId == 278444 then
		if self.Options.SpecWarn278444interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnInfest:Show(args.sourceName)
			specWarnInfest:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnInfest:Show()
		end
	elseif spellId == 264390 then
		timerSpellbindCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn264390interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSpellbind:Show(args.sourceName)
			specWarnSpellbind:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSpellbind:Show()
		end
	elseif spellId == 271174 then
		timerRetchCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn271174interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRetch:Show(args.sourceName)
			specWarnRetch:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnRetch:Show()
		end
	elseif spellId == 265346 then
		if self.Options.SpecWarn265346interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPallidGlare:Show(args.sourceName)
			specWarnPallidGlare:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnPallidGlare:Show()
		end
	elseif spellId == 264407 then
		timerHorrificVisageCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn264407interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHorrificVisage:Show(args.sourceName)
			specWarnHorrificVisage:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHorrificVisage:Show()
		end
	elseif spellId == 265368 then
		timerSpiritedDefenseCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSpiritedDefense:Show(args.sourceName)
			specWarnSpiritedDefense:Play("kickcast")
		end
	elseif spellId == 260699 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSoulBolt:Show(args.sourceName)
			specWarnSoulBolt:Play("kickcast")
		end
	elseif spellId == 426541 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRunicBolt:Show(args.sourceName)
			specWarnRunicBolt:Play("kickcast")
		end
	elseif spellId == 266036 then
		timerDrainEssenceCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDrainEssence:Show(args.sourceName)
			specWarnDrainEssence:Play("kickcast")
		end
	elseif spellId == 278551 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSoulFetish:Show(args.sourceName)
			specWarnSoulFetish:Play("kickcast")
		end
	elseif spellId == 265407 then--Can stutter cast (especially if pulled/kited outside), but can't be moved to success cause there may be one (if kicked).
		timerDinnerBellCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDinnerBell:Show(args.sourceName)
			specWarnDinnerBell:Play("kickcast")
		end
	elseif spellId == 264050 then
		if args:GetSrcCreatureID() == 135474 then--Thistle acolyte has 8.5 CD, coven thornshapder has MUCH shorter CD that we don't track
			timerInfectedThornsCD:Start(nil, args.sourceGUID)
		end
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnInfectedThorn:Show(args.sourceName)
			specWarnInfectedThorn:Play("kickcast")
		end
	elseif spellId == 265881 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnDecayingTouch:Show()
			specWarnDecayingTouch:Play("defensive")
		end
	elseif spellId == 265760 then
		timerThornedBarrageCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnThornedBarrage:Show()
			specWarnThornedBarrage:Play("defensive")
		end
	elseif spellId == 265759 then
		timerSplinterSpikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(5, 2) then
			specWarnSplinterSpike:Show()
			specWarnSplinterSpike:Play("watchstep")
		end
	elseif spellId == 264038 then
		timerUprootCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3.5, 2) then
			specWarnUproot:Show()
			specWarnUproot:Play("watchstep")
		end
	elseif spellId == 264150 and self:AntiSpam(3.5, 2) then
		specWarnShatter:Show()
		specWarnShatter:Play("watchstep")
	elseif spellId == 263905 then
		if self:AntiSpam(2.5, 2) then
			specWarnMarkingCleave:Show()
			specWarnMarkingCleave:Play("shockwave")
		end
	elseif spellId == 263961 then
		timerWardingCandleCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(4, 5) then
			specWarnWardingCandle:Show()
			specWarnWardingCandle:Play("moveboss")
		end
	elseif spellId == 267824 then
		timerScarSoulCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnScarSoul:Show(args.sourceName)
			specWarnScarSoul:Play("kickcast")
		end
	elseif spellId == 265372 then
		timerShadowCleaveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnShadowCleave:Show()
			specWarnShadowCleave:Play("shockwave")
		end
	elseif spellId == 265371 then
		timerFocusedStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnFocusedStrike:Show()
		end
	elseif spellId == 265352 and self:AntiSpam(3, 6) then
		warnToadBlight:Show()
	elseif spellId == 263943 then
		timerEtchCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 264556 then
		timerTearingStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnTearingStrike:Show()
		end
	elseif spellId == 271175 then
		timerRavagingLeapCD:Start(nil, args.sourceGUID)
	elseif spellId == 264105 then
		timerRunicMarkCD:Start(nil, args.sourceGUID)
	elseif spellId == 265880 then
		timerDreadMarkCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 265880 and args:IsPlayer() then
		specWarnDreadMark:Show()
		specWarnDreadMark:Play("runout")
		yellDreadMark:Yell()
		yellDreadMarkFades:Countdown(spellId)
	elseif spellId == 264105 and args:IsPlayer() then
		--Of can dispel, always show dispel warning first even if on self.
		if self.Options.SpecWarn264105dispel and self:CheckDispelFilter("curse") then
			specWarnRunicMarkDispel:Show(args.destName)
			specWarnRunicMarkDispel:Play("helpdispel")
		elseif args:IsPlayer() then
			specWarnRunicMark:Show()
			specWarnRunicMark:Play("runout")
		end
		--Always do yell though
		if args:IsPlayer() then
			yellRunicMark:Yell()
			yellRunicMarkFades:Countdown(spellId)
		end
	elseif spellId == 265368 and not args:IsDestTypePlayer() and self:AntiSpam(4, 3) then
		specWarnSpiritedDefenseDispel:Show(args.destName)
		specWarnSpiritedDefenseDispel:Play("helpdispel")
	elseif spellId == 257260 and self:AntiSpam(4, 3) then
		specWarnEnrage:Show(args.destName)
		specWarnEnrage:Play("enrage")
	elseif spellId == 263943 and args:IsPlayer() or self:IsHealer() then--Antispam if needed
		warnEtch:Show(args.destName)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 265880 and args:IsPlayer() then
		yellDreadMarkFades:Cancel()
	elseif spellId == 264105 and args:IsPlayer() then
		yellRunicMarkFades:Cancel()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 135240 then--soul-essence
		timerScarSoulCD:Stop(args.destGUID)
	elseif cid == 131587 then--bewitched-captain
		timerShadowCleaveCD:Stop(args.destGUID)
		timerSpiritedDefenseCD:Stop(args.destGUID)
	elseif cid == 131585 then--enthralled-guard
		timerFocusedStrikeCD:Stop(args.destGUID)
	elseif cid == 131685 then--runic-disciple
		timerSpellbindCD:Stop(args.destGUID)
	elseif cid == 131812 then--heartsbane-soulcharmer
		--Soul Bolt
		timerSoulVolleyCD:Stop(args.destGUID)
		timerWardingCandleCD:Stop(args.destGUID)
	elseif cid == 135474 then--thistle-acolyte
		timerDrainEssenceCD:Stop(args.destGUID)
		timerInfectedThornsCD:Stop(args.destGUID)
--	elseif cid == 131666 then--coven-thornshaper
		--Infected Thorn (2) (CD too short on these mobs)
		timerUprootCD:Stop(args.destGUID)
	elseif cid == 131858 then--thornguard
		timerTearingStrikeCD:Stop(args.destGUID)
		--enrage (not enough data to suggest it has a CD)
	elseif cid == 135329 then--matron-bryndle
		timerSplinterSpikeCD:Stop(args.destGUID)
		timerThornedBarrageCD:Stop(args.destGUID)
	elseif cid == 137830 then--pallid-gorger
		timerRavagingLeapCD:Stop(args.destGUID)
		timerRetchCD:Stop(args.destGUID)
	elseif cid == 131586 then--banquet-steward
		timerDinnerBellCD:Start(args.destGUID)
--	elseif cid == 134024 then--devouring-maggot
		--Infest
	elseif cid == 131677 then--heartsbane-runeweaver
		timerEtchCD:Stop(args.destGUID)
		timerRunicMarkCD:Stop(args.destGUID)
	elseif cid == 135049 then--dreadwing-raven
		--Pallid Glare
	elseif cid == 131821 then--faceless-maiden
		timerHorrificVisageCD:Stop(args.destGUID)
	elseif cid == 135365 then--matron-alma
		timerRuinousoVolleyCD:Stop(args.destGUID)
		--Decaying Touch
		timerDreadMarkCD:Stop(args.destGUID)
	end
end
