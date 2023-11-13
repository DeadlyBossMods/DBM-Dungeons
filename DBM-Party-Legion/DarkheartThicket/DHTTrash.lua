local mod	= DBM:NewMod("DHTTrash", "DBM-Party-Legion", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(1466)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 200630 200580 200642 200658 200768 198904 201226 201399 201839",
	"SPELL_CAST_SUCCESS 218755 204243 201272 201129 201361",
	"SPELL_SUMMON 198910",
	"SPELL_AURA_APPLIED 225484 198904 204246 201839 201365",
	"UNIT_DIED"
)

--[[
(ability.id = 200630 or ability.id = 200580 or ability.id = 200642 or ability.id = 200658 or ability.id = 200768 or ability.id = 198904 or ability.id = 201226 or ability.id = 201399 or ability.id = 201839) and type = "begincast"
 or (ability.id = 218755 or ability.id = 204243 or ability.id = 201272 or ability.id = 201129 or ability.id = 201361) and type = "cast"
 or ability.id = 198910
 or ability.id = 225484 and type = "applydebuff"
--]]
--TODO, Grievous Rip is lacking a cast event, probably needs UNIT_SPELLCAST
local warnSpewCorruption			= mod:NewSpellAnnounce(218755, 2)
local warnMaddeningRoar				= mod:NewSpellAnnounce(200580, 3)
local warnStarShower				= mod:NewSpellAnnounce(200658, 3)
local warnBloodBomb					= mod:NewSpellAnnounce(201272, 4)
local warnGrievousRip				= mod:NewTargetNoFilterAnnounce(225484, 4, nil, false)--Packs of 3 exist taht cast it near at once but staggered, so can feel spammy but too spread to aggregate
local warnUnnervingScreech			= mod:NewCastAnnounce(200630, 4)--High prio off internet
local warnTormentingEye				= mod:NewCastAnnounce(204243, 4, 4.5)--High prio off internet
local warnBloodMeta					= mod:NewCastAnnounce(225562, 4)--High prio off internet
local warnDreadInferno				= mod:NewCastAnnounce(201399, 4)--High prio off internet

local specWarnPropellingCharge		= mod:NewSpecialWarningDodge(200768, nil, nil, nil, 2, 2)
local specWarnRootBurst				= mod:NewSpecialWarningDodge(201129, nil, nil, nil, 2, 2)
local specWarnVileMushroom			= mod:NewSpecialWarningDodge(198910, nil, nil, nil, 2, 2)
local specWarnDreadInfernoFailed	= mod:NewSpecialWarningMoveAway(201399, nil, nil, nil, 1, 2)
local yellDreadInferno				= mod:NewYell(201399)
local specWarnBloodAssault			= mod:NewSpecialWarningDefensive(201226, nil, nil, nil, 1, 2)
local specWarnUnnervingScreech		= mod:NewSpecialWarningInterrupt(200630, "HasInterrupt", nil, nil, 1, 2)--High Priority
local specWarnDespair				= mod:NewSpecialWarningInterrupt(200642, "HasInterrupt", nil, nil, 1, 2)
local specWarnTormentingEye			= mod:NewSpecialWarningInterrupt(204243, "HasInterrupt", nil, nil, 1, 2)--High Priority
local specWarnBloodMeta				= mod:NewSpecialWarningInterrupt(225562, "HasInterrupt", nil, nil, 1, 2)--High Priority
local specWarnDreadInferno			= mod:NewSpecialWarningInterrupt(201399, "HasInterrupt", nil, nil, 1, 2)--High Priority
local specWarnCurseofIsolation		= mod:NewSpecialWarningInterrupt(201839, "HasInterrupt", nil, nil, 1, 2)
local specWarnPoisonSpear			= mod:NewSpecialWarningDispel(198904, "RemovePoison", nil, nil, 1, 2)
local specWarnTormentingFear		= mod:NewSpecialWarningDispel(204246, "RemoveMagic", nil, nil, 1, 2)--Missed eye interrupt
local specWarnCurseofIsoDispel		= mod:NewSpecialWarningDispel(201839, "RemoveCurse", nil, nil, 1, 2)--Missed Taintheart interrupt
local specWarnDarksoulDrain			= mod:NewSpecialWarningDispel(201365, "RemoveDisease", nil, nil, 1, 2)
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(201123, nil, nil, nil, 1, 8)

local timerGrievousRipCD			= mod:NewCDNPTimer(18, 225484, nil, nil, nil, 3)--Kind of imprecise without an actual cast event, but should be a good approx
local timerUnnervingScreechCD		= mod:NewCDNPTimer(14.5, 200630, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSpewCorruptionCD			= mod:NewCDNPTimer(30.3, 218755, nil, nil, nil, 3)
local timerMaddeningRoarCD			= mod:NewCDNPTimer(22.6, 200580, nil, nil, nil, 2)
local timerStarShowerCD				= mod:NewCDNPTimer(20.7, 200658, nil, nil, nil, 2)
local timerPropellingChargeCD		= mod:NewCDNPTimer(18.2, 200768, nil, nil, nil, 3)
local timerPoisonSpearCD			= mod:NewCDNPTimer(18.2, 198904, nil, nil, nil, 3)--18.2-22
local timerTormentingEyeCD			= mod:NewCDNPTimer(8.5, 204243, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBloodBombCD				= mod:NewCDNPTimer(15.7, 201272, nil, nil, nil, 2)
local timerBloodAssaultCD			= mod:NewCDNPTimer(22.6, 201226, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerBloodMetaCD				= mod:NewCDNPTimer(10.9, 225562, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDreadInfernoCD			= mod:NewCDNPTimer(18.2, 201399, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerCurseofIsolationCD		= mod:NewCDNPTimer(15.8, 201839, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRootBurstCD				= mod:NewCDNPTimer(17, 201129, nil, nil, nil, 3)
local timerVileMushroomCD			= mod:NewCDNPTimer(17, 198910, nil, nil, nil, 3)
local timerDarksoulBiteCD			= mod:NewCDNPTimer(12.1, 201361, nil, nil, nil, 5)--12.1-18.2

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 GTFO

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 200630 then
		timerUnnervingScreechCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn200630interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnUnnervingScreech:Show(args.sourceName)
			specWarnUnnervingScreech:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnUnnervingScreech:Show()
		end
	elseif spellId == 225562 then
		timerBloodMetaCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn225562interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBloodMeta:Show(args.sourceName)
			specWarnBloodMeta:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBloodMeta:Show()
		end
	elseif spellId == 201399 then
		timerDreadInfernoCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn201399interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDreadInferno:Show(args.sourceName)
			specWarnDreadInferno:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnDreadInferno:Show()
		end
	elseif spellId == 200580 then
		timerMaddeningRoarCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnMaddeningRoar:Show()
		end
	elseif spellId == 200642 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDespair:Show(args.sourceName)
			specWarnDespair:Play("kickcast")
		end
	elseif spellId == 200658 then
		timerStarShowerCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnStarShower:Show()
		end
	elseif spellId == 200768 then
		timerPropellingChargeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnPropellingCharge:Show()
			specWarnPropellingCharge:Play("chargemove")
		end
	elseif spellId == 198904 then
		timerPoisonSpearCD:Start(nil, args.sourceGUID)
	elseif spellId == 201226 then
		timerBloodAssaultCD:Start(nil, args.sourceGUID)
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
			specWarnBloodAssault:Show()
			specWarnBloodAssault:Play("carefly")
		end
	elseif spellId == 201839 then
		timerCurseofIsolationCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnCurseofIsolation:Show(args.sourceName)
			specWarnCurseofIsolation:Play("kickcast")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 200343 then
		timerSpewCorruptionCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnSpewCorruption:Show()
		end
	elseif spellId == 204243 then
		timerTormentingEyeCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn204243interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTormentingEye:Show(args.sourceName)
			specWarnTormentingEye:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnTormentingEye:Show()
		end
	elseif spellId == 201272 then
		timerBloodBombCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnBloodBomb:Show()
		end
	elseif spellId == 201399 and args:IsPlayer() then
		specWarnDreadInfernoFailed:Show()
		specWarnDreadInfernoFailed:Play("runout")
		yellDreadInferno:Yell()
	elseif spellId == 201129 then
		timerRootBurstCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRootBurst:Show()
			specWarnRootBurst:Play("watchstep")
		end
	elseif spellId == 201361 then
		timerDarksoulBiteCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_SUMMON(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 198910 and self:AntiSpam(3, 2) then
		timerVileMushroomCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnVileMushroom:Show()
			specWarnVileMushroom:Play("watchstep")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 225484 then
		warnGrievousRip:Show(args.destName)
		if self:AntiSpam(8, args.sourceGUID) then
			timerGrievousRipCD:Start(nil, args.sourceGUID)
		end
	elseif spellId == 198904 then
		if self:CheckDispelFilter("poison") and self:AntiSpam(3, 3) then
			specWarnPoisonSpear:Show(args.destName)
			specWarnPoisonSpear:Play("helpdispel")
		end
	elseif spellId == 204246 then
		if self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnTormentingFear:Show(args.destName)
			specWarnTormentingFear:Play("helpdispel")
		end
	elseif spellId == 201839 then
		if self:CheckDispelFilter("curse") and self:AntiSpam(3, 3) then
			specWarnCurseofIsoDispel:Show(args.destName)
			specWarnCurseofIsoDispel:Play("helpdispel")
		end
	elseif spellId == 201365 then
		if self:CheckDispelFilter("disease") and self:AntiSpam(3, 3) then
			specWarnDarksoulDrain:Show(args.destName)
			specWarnDarksoulDrain:Play("helpdispel")
		end
--	elseif spellId == 201123 and args:IsPlayer() and self:AntiSpam(3, 8) then
--		specWarnGTFO:Show(args.spellName)
--		specWarnGTFO:Play("watchfeet")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 95772 then--frenzied-nightclaw
		timerGrievousRipCD:Stop(args.destGUID)
	elseif cid == 95769 then--mindshattered-screecher
		timerUnnervingScreechCD:Stop(args.destGUID)
	elseif cid == 95779 then--festerhide-grizzly
		timerSpewCorruptionCD:Stop(args.destGUID)
		timerMaddeningRoarCD:Stop(args.destGUID)
	elseif cid == 95771 then--dreadsoul-ruiner
		timerStarShowerCD:Stop(args.destGUID)
	elseif cid == 95766 then--crazed-razorbeak
		timerPropellingChargeCD:Stop(args.destGUID)
	elseif cid == 99358 then--rotheart-dryad
		timerPoisonSpearCD:Stop(args.destGUID)
	elseif cid == 101991 then--nightmare-dweller
		timerTormentingEyeCD:Stop(args.destGUID)
	elseif cid == 100531 then--bloodtainted-fury
		timerBloodBombCD:Stop(args.destGUID)
		timerBloodAssaultCD:Stop(args.destGUID)
	elseif cid == 100532 then--bloodtainted-burster#
		timerBloodMetaCD:Stop(args.destGUID)
	elseif cid == 100527 then--dreadfire-imp
		timerDreadInfernoCD:Stop(args.destGUID)
	elseif cid == 99366 then--taintheart-summoner
		timerCurseofIsolationCD:Stop(args.destGUID)
	elseif cid == 99360 then--Vilethorn Blossom
		timerRootBurstCD:Stop(args.destGUID)
	elseif cid == 99359 then--rotheart-keeper
		timerVileMushroomCD:Stop(args.destGUID)
	elseif cid == 100526 then--tormented-bloodseeker
		timerDarksoulBiteCD:Stop(args.destGUID)
	end
end
