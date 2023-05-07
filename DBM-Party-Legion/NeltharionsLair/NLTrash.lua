local mod	= DBM:NewMod("NLTrash", "DBM-Party-Legion", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 183088 226296 202108 193505 226287 183548 193585 226406 202181 193941 226347 183539",
	"SPELL_CAST_SUCCESS 183433 183526",
	"SPELL_AURA_APPLIED 200154 183407 186576 193803 201983 226388 186616",
	"UNIT_DIED"
)

--[[
(ability.id = 183088 or ability.id = 226296 or ability.id = 202108 or ability.id = 193505 or ability.id = 226287 or ability.id = 183548 or ability.id = 193585 or ability.id = 226406 or ability.id = 202181 or ability.id = 193941 or ability.id = 226347 or ability.id = 183539 or ability.id = 201983 or ability.id = 200154) and type = "begincast"
 or (ability.id = 183433 or ability.id = 183526) and type = "cast"
--]]
local warnSubmerge						= mod:NewSpellAnnounce(183433, 3)
local warnWarDrums						= mod:NewSpellAnnounce(183526, 4)
local warnBurningHatred					= mod:NewTargetAnnounce(200154, 3)
local warnMetamorphosis					= mod:NewTargetNoFilterAnnounce(193803, 3, nil, false)
local warnPetrifed						= mod:NewTargetNoFilterAnnounce(186616, 4)
local warnCallWorm						= mod:NewCastAnnounce(183548, 3)
local warnCrush							= mod:NewCastAnnounce(226287, 3)
local warnPiercingShards				= mod:NewCastAnnounce(226296, 4, nil, nil, "Tank|Healer")
local warnFracture						= mod:NewCastAnnounce(193505, 3, nil, nil, "Tank|Healer")
local warnEmberSwipe					= mod:NewCastAnnounce(226406, 3, nil, nil, "Tank|Healer")
local warnImpalingShard					= mod:NewCastAnnounce(193941, 3, nil, nil, "Tank|Healer")
local warnPetrifyingTotem				= mod:NewCastAnnounce(202108, 3)
local warnBound							= mod:NewCastAnnounce(193585, 3)
local warnStoneShatter					= mod:NewCastAnnounce(226347, 3)
local warnBarbedTongue					= mod:NewCastAnnounce(183539, 3)

local specWarnBurningHatred				= mod:NewSpecialWarningRun(200154, nil, nil, nil, 4, 2)
local specWarnCrush						= mod:NewSpecialWarningRun(226287, "Melee", nil, nil, 1, 2)
local specWarnAvalanche					= mod:NewSpecialWarningDodge(183088, nil, nil, 3, 1, 2)
local specWarnPetrifyingTotem			= mod:NewSpecialWarningDodge(202108, nil, nil, nil, 2, 2)
local specWarnPetrifyingCloud			= mod:NewSpecialWarningDispel(186576, "RemoveMagic", nil, nil, 1, 2)
local specWarnFrenzy					= mod:NewSpecialWarningDispel(201983, "RemoveEnrage", nil, nil, 1, 2)
local specWarnStoneGaze					= mod:NewSpecialWarningInterrupt(202181, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(186576, nil, nil, nil, 1, 8)

local timerSubmergeCD					= mod:NewCDTimer(22.7, 183433, nil, nil, nil, 5)
local timerStoneShatterCD				= mod:NewCDTimer(12.1, 226347, nil, nil, nil, 3)
local timerImpalingShardCD				= mod:NewCDTimer(15.7, 193941, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerCrushCD						= mod:NewCDTimer(18.2, 226287, nil, nil, nil, 3)
local timerFractureCD					= mod:NewCDTimer(15.7, 193505, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Also acts as piercing shards timer, piercing is awlays used immediately after fracture
local timerStoneGazeCD					= mod:NewCDTimer(20.6, 202181, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerAvalancheCD					= mod:NewCDTimer(19.4, 183088, nil, nil, nil, 3)
local timerPetrifyingTotemCD			= mod:NewCDTimer(48.6, 202108, nil, nil, nil, 3)
local timerEmberSwipeCD					= mod:NewCDTimer(10.9, 226406, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFrenzyCD						= mod:NewCDTimer(20.6, 201983, nil, "RemoveEnrage|Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerBoundCD						= mod:NewCDTimer(22.7, 193585, nil, nil, nil, 5)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 GTFO

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 183088 then
		timerAvalancheCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnAvalanche:Show()
			specWarnAvalanche:Play("watchstep")
		end
	elseif spellId == 226296 and self:AntiSpam(3, 5) then
		warnPiercingShards:Show()
	elseif spellId == 202108 then
		timerPetrifyingTotemCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnPetrifyingTotem:Show()
			specWarnPetrifyingTotem:Play("runaway")
		end
	elseif spellId == 193505 then
		timerFractureCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnFracture:Show()
		end
	elseif spellId == 226287 then
		timerCrushCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			if self.Options.SpecWarn226287run then
				specWarnCrush:Show()
				specWarnCrush:Play("justrun")
			else
				warnCrush:Show()
			end
		end
	elseif spellId == 183548 and self:AntiSpam(3, 5) then
		warnCallWorm:Show()
	elseif spellId == 193585 then
		timerBoundCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnBound:Show()
		end
	elseif spellId == 226406 then
		timerEmberSwipeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnEmberSwipe:Show()
		end
	elseif spellId == 193941 then
		timerImpalingShardCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnImpalingShard:Show()
		end
	elseif spellId == 202181 then
		if args:GetSrcCreatureID() == 91332 then--Stoneclaw Hunter
			timerStoneGazeCD:Start(12.1, args.sourceGUID)
		else--Stoneclaw Grubmaster
			timerStoneGazeCD:Start(13.8, args.sourceGUID)
		end
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnStoneGaze:Show(args.sourceName)
			specWarnStoneGaze:Play("kickcast")
		end
	elseif spellId == 226347 then
		timerStoneShatterCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnStoneShatter:Show()
		end
	elseif spellId == 183539 and self:AntiSpam(3, 5) then
		warnBarbedTongue:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 183433 then
		timerSubmergeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnSubmerge:Show()
		end
	elseif spellId == 183526 and self:AntiSpam(3, 5) then
		warnWarDrums:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 200154 then
		if args:IsPlayer() then
			specWarnBurningHatred:Show()
			specWarnBurningHatred:Play("justrun")
		else
			warnBurningHatred:Show(args.destName)
		end
	elseif (spellId == 183407 or spellId == 226388) and args:IsPlayer() and self:AntiSpam(3, 7) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 186576 then
		if args:IsPlayer() then
			specWarnGTFO:Show(args.spellName)
			specWarnGTFO:Play("watchfeet")
		elseif self:CheckDispelFilter("magic") then
			specWarnPetrifyingCloud:Show(args.destName)
			specWarnPetrifyingCloud:Play("helpdispel")
		end
	elseif spellId == 193803 and self:AntiSpam(3, 6) then
		warnMetamorphosis:Show(args.destName)
	elseif spellId == 201983 then
		timerFrenzyCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 3) then
			specWarnFrenzy:Show(args.destName)
			specWarnFrenzy:Play("enrage")
		end
	elseif spellId == 186616 then
		warnPetrifed:Show(args.destName)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 91001 then--Tarspitter Lurker
		timerSubmergeCD:Stop(args.destGUID)
	elseif cid == 91332 then--Stoneclaw Hunter
		timerStoneShatterCD:Stop(args.destGUID)
	elseif cid == 98406 then--Embershard Scorpion
		timerImpalingShardCD:Stop(args.destGUID)
	elseif cid == 101438 then--Vileshard Chunk
		timerCrushCD:Stop(args.destGUID)
	elseif cid == 91000 then--Vileshard Hulk
		timerFractureCD:Stop(args.destGUID)
	elseif cid == 91006 then--Rockback Gnasher
		timerStoneGazeCD:Stop(args.destGUID)
	elseif cid == 102404 then--Stoneclaw Grubmaster
		timerStoneShatterCD:Stop(args.destGUID)
	elseif cid == 90997 then--Mightstone breaker
		timerAvalancheCD:Stop(args.destGUID)
	elseif cid == 90998 then--Blightshard Shaper
		timerPetrifyingTotemCD:Stop(args.destGUID)
	elseif cid == 102295 or cid == 102287 or cid == 113536 or cid == 113537 then--Emberhusk Dominator
		timerEmberSwipeCD:Stop(args.destGUID)
		timerFrenzyCD:Stop(args.destGUID)
	elseif cid == 102232 then--Rockbound Trapper
		timerBoundCD:Stop(args.destGUID)
	end
end
