local mod	= DBM:NewMod("CinderbrewMeaderyTrash", "DBM-Party-WarWithin", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(2661)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2661)
if DBM.Options.DebugMode then--Make it easier to collect initial nameplate timers across delves with transcriptor
	mod:RegisterZoneCombat(2661)
end

mod:RegisterEvents(
	"SPELL_CAST_START 434761 434706 437721 434756 434998 448619 441627 442589 439467",
	"SPELL_CAST_SUCCESS 437721 441627 441214 441434 448619 434998 434756 434706 434761 437956 442589 439467",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 437956 441627 441214",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"GOSSIP_SHOW"
)

--TODO, do more with throw chair? can you actually dodge it? is it actually threatening on higher keys?
--TODO, see if you can target scan downward trend
--TODO, add Blazing Blelch Frontal, Honey Volley Interrupt, Bee-Zooka Frontal
--[[
(ability.id = 437956 or ability.id = 434761 or ability.id = 434706 or ability.id = 437721 or ability.id = 434756 or ability.id = 434998 or ability.id = 448619 or ability.id = 441627 or ability.id = 441214) and type = "begincast"
 or ability.id = 441434 and type1 = "cast"
 or stoppedAbility.id = 437956 or stoppedAbility.id = 434761 or stoppedAbility.id = 434706 or stoppedAbility.id = 437721 or stoppedAbility.id = 434756 or stoppedAbility.id = 434998 or stoppedAbility.id = 448619 or stoppedAbility.id = 441434 or stoppedAbility.id = 441627 or stoppedAbility.id = 441214)
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --]]
local warnCinderBrewToss					= mod:NewTargetAnnounce(434706, 3)
local warnThrowChair						= mod:NewTargetNoFilterAnnounce(434756, 2)
local warnFailedBatch						= mod:NewSpellAnnounce(441434, 3)
local warnRejuvenatingHoney					= mod:NewCastAnnounce(441627, 3)--High Prio Interrupt

local specWarnEruptingInferno				= mod:NewSpecialWarningMoveAway(437956, nil, nil, nil, 1, 2)
local yellEruptingInferno					= mod:NewShortYell(437956)
local specWarnEruptingInfernoDispel			= mod:NewSpecialWarningDispel(437956, "RemoveMagic", nil, nil, 1, 2)
local specWarnMightyStomp					= mod:NewSpecialWarningSpell(434761, nil, nil, nil, 2, 2)
local specWarnCinderbrewToss				= mod:NewSpecialWarningMoveAway(434706, nil, nil, nil, 1, 2)
local yellCinderbrewToss					= mod:NewShortYell(434706)
local specWarnBoilingFlames					= mod:NewSpecialWarningInterrupt(437721, "HasInterrupt", nil, nil, 1, 2)
local specWarnHighSteaks					= mod:NewSpecialWarningDodge(434998, nil, nil, nil, 2, 2)
local specWarnRecklessDelivery				= mod:NewSpecialWarningDodge(448619, nil, nil, nil, 2, 2)
local specWarnBeesWax						= mod:NewSpecialWarningDodge(442589, nil, nil, nil, 2, 2)
local specWarnDownwardtrend					= mod:NewSpecialWarningDodge(439467, nil, nil, nil, 2, 2)
local specWarnRejuvenatingHoney				= mod:NewSpecialWarningInterrupt(441627, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnRejuvenatingHoneyDispel		= mod:NewSpecialWarningDispel(441627, "MagicDispeller", nil, nil, 1, 2)
local specWarnSpillDrink					= mod:NewSpecialWarningDispel(441214, "RemoveEnrage", nil, nil, 1, 2)

--All timers need rechecking, but can't use public WCL to fix this since all logs short
local timerEruptingInfernoCD				= mod:NewCDNPTimer(12.3, 437956, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerMightyStompCD					= mod:NewCDNPTimer(22.2, 434761, nil, nil, nil, 2)
local timerCinderbrewTossCD					= mod:NewCDNPTimer(10.6, 434706, nil, nil, nil, 3)
local timerThrowChairCD						= mod:NewCDNPTimer(11.8, 434756, nil, nil, nil, 3)
local timerHighSteaksCD						= mod:NewCDNPTimer(20.3, 434998, nil, nil, nil, 3)
local timerRecklessDeliveryCD				= mod:NewCDPNPTimer(16.6, 448619, nil, nil, nil, 3)
local timerFailedBatchCD					= mod:NewCDNPTimer(22.2, 441434, nil, nil, nil, 5)--22.6-25.6
local timerSpillDrinkCD						= mod:NewCDNPTimer(20, 441214, nil, nil, nil, 5)
local timerBeesWaxCD						= mod:NewCDNPTimer(18, 442589, nil, nil, nil, 3)
local timerDownwardTrendCD					= mod:NewCDNPTimer(12.7, 439467, nil, nil, nil, 3)
local timerBoilingFlamesCD					= mod:NewCDPNPTimer(20.1, 437721, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRejuvenatingHoneyCD				= mod:NewCDPNPTimer(12.7, 441627, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

mod:AddGossipOption(true, "Buff")

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:CinderbrewTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnCinderbrewToss:Show()
			specWarnCinderbrewToss:Play("range5")
			yellCinderbrewToss:Yell()
		end
	else
		warnCinderBrewToss:Show(targetname)
	end
end

function mod:ThrowChair(targetname)
	if not targetname then return end
	--if targetname == UnitName("player") then
	--	if self:AntiSpam(4, 5) then
	--		specWarnCinderbrewToss:Show()
	--		specWarnCinderbrewToss:Play("range5")
	--		yellCinderbrewToss:Yell()
	--	end
	--else
		warnThrowChair:Show(targetname)
	--end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 434761 then
		if self:AntiSpam(3, 6) then
			specWarnMightyStomp:Show()
			specWarnMightyStomp:Play("carefly")
		end
	elseif spellId == 434706 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CinderbrewTarget", 0.1, 6)
	elseif spellId == 434756 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ThrowChair", 0.1, 6)
	elseif spellId == 437721 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBoilingFlames:Show(args.sourceName)
			specWarnBoilingFlames:Play("kickcast")
		end
	elseif spellId == 441627 then
		if self.Options.SpecWarn441627interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnRejuvenatingHoney:Show(args.sourceName)
			specWarnRejuvenatingHoney:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnRejuvenatingHoney:Show()
		end
	elseif spellId == 434998 then
		if self:AntiSpam(3, 2) then
			specWarnHighSteaks:Show()
			specWarnHighSteaks:Play("watchstep")
		end
	elseif spellId == 448619 then
		if self:AntiSpam(3, 2) then
			specWarnRecklessDelivery:Show()
			specWarnRecklessDelivery:Play("chargemove")
		end
	elseif spellId == 434706 then
		timerCinderbrewTossCD:Start(10.6, args.sourceGUID)
	elseif spellId == 442589 then
		if self:AntiSpam(3, 2) then
			specWarnBeesWax:Show()
			specWarnBeesWax:Play("watchstep")
		end
	elseif spellId == 439467 then
		if self:AntiSpam(3, 2) then
			specWarnDownwardtrend:Show()
			specWarnDownwardtrend:Play("watchstep")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 437721 then
		timerBoilingFlamesCD:Start(20.1, args.sourceGUID)
	elseif spellId == 441627 then
		timerRejuvenatingHoneyCD:Start(12.7, args.sourceGUID)
	elseif spellId == 441214 then
		timerSpillDrinkCD:Start(20, args.sourceGUID)
	elseif spellId == 441434 then
		timerFailedBatchCD:Start(22.2, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnFailedBatch:Show()
		end
	elseif spellId == 448619 then
		timerRecklessDeliveryCD:Start(16.6, args.sourceGUID)
	elseif spellId == 434998 then
		timerHighSteaksCD:Start(20.3, args.sourceGUID)
	elseif spellId == 434756 then
		timerThrowChairCD:Start(11.8, args.sourceGUID)
	elseif spellId == 434761 then
		timerMightyStompCD:Start(22.2, args.sourceGUID)
	elseif spellId == 437956 then
		timerEruptingInfernoCD:Start(12.3, args.sourceGUID)
	elseif spellId == 442589 then
		timerBeesWaxCD:Start(18, args.sourceGUID)
	elseif spellId == 439467 then
		timerDownwardTrendCD:Start(12.7, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 437721 then
		timerBoilingFlamesCD:Start(20.1, args.destGUID)
	elseif spellId == 441627 then
		timerRejuvenatingHoneyCD:Start(12.7, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 437956 then
		--Always prio dispel over runout, even if on self cause can just dispel self
		if self.Options.SpecWarn437956dispel and self:CheckDispelFilter("magic") then
			specWarnEruptingInfernoDispel:Show(args.destName)
			specWarnEruptingInfernoDispel:Play("helpdispel")
			--Still do yell
			if args:IsPlayer() then
				yellEruptingInferno:Yell()
			end
		elseif args:IsPlayer() then
			specWarnEruptingInferno:Show()
			specWarnEruptingInferno:Play("runout")
			yellEruptingInferno:Yell()
		end
	elseif spellId == 441627 and args:IsDestTypeHostile() then
		specWarnRejuvenatingHoneyDispel:Show(args.destName)
		specWarnRejuvenatingHoneyDispel:Play("helpdispel")
	elseif spellId == 441214 and args:IsDestTypeHostile() and self:AntiSpam(3, 5) then
		specWarnSpillDrink:Show(args.destName)
		specWarnSpillDrink:Play("enrage")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 218671 then--Venture Co Pyromaniac
		timerEruptingInfernoCD:Stop(args.destGUID)
		timerBoilingFlamesCD:Stop(args.destGUID)
	elseif cid == 210269 then--Hired Muscle
		timerMightyStompCD:Stop(args.destGUID)
		timerThrowChairCD:Stop(args.destGUID)
	elseif cid == 214920 then--Tasting Room Agent
		timerCinderbrewTossCD:Stop(args.destGUID)
	elseif cid == 214697 then--Chef Chewie
		timerHighSteaksCD:Stop(args.destGUID)
	elseif cid == 223423 then--Careless Hobgoblin
		timerRecklessDeliveryCD:Stop(args.destGUID)
	elseif cid == 222964 then--Flavor Scientist
		timerFailedBatchCD:Stop(args.destGUID)
		timerRejuvenatingHoneyCD:Stop(args.destGUID)
	elseif cid == 220060 then--Taste Tester
		timerSpillDrinkCD:Stop(args.destGUID)
	elseif cid == 220946 then--Venture Co Honey Harvester
		timerBeesWaxCD:Stop(args.destGUID)
	elseif cid == 219588 then--Yes Man
		timerDownwardTrendCD:Stop(args.destGUID)
	end
end

--121211 cooking pot, 121320 flamethrower
function mod:GOSSIP_SHOW()
	local gossipOptionID = self:GetGossipID()
	if gossipOptionID then
		if self.Options.AutoGossipBuff and (gossipOptionID == 121211 or gossipOptionID == 121320) then
			self:SelectGossip(gossipOptionID)
		end
	end
end
