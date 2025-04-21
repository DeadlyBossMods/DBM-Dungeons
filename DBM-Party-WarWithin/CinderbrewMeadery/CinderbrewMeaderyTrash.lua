local mod	= DBM:NewMod("CinderbrewMeaderyTrash", "DBM-Party-WarWithin", 7)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod:SetZone(2661)
mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true
mod:SetZone(2661)
mod:RegisterZoneCombat(2661)

mod:RegisterEvents(
	"SPELL_CAST_START 434706 437721 434756 434998 448619 441627 442589 439467 463218 463206 441242 441410 443487 441351 441119 442995 440687",
	"SPELL_CAST_SUCCESS 437721 441627 441214 441434 434998 434756 434706 437956 434773 441242 441410 441351 441119 440687 440876",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 437956 441627 441214",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"GOSSIP_SHOW"
)

--TODO, see if you can target scan downward trend
--TODO, add Blazing Blelch Frontal?
--TODO, add https://www.wowhead.com/spell=441408/thirsty ?
--TODO, add stack counter for https://www.wowhead.com/ptr-2/spell=441397/bee-venom ?
--[[
(ability.id = 440687) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 440687
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 220141) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 220141)
 --]]
local warnCinderBrewToss					= mod:NewTargetAnnounce(434706, 3)
local warnThrowChair						= mod:NewTargetNoFilterAnnounce(434756, 2)
local warnRejuvenatingHoney					= mod:NewCastAnnounce(441627, 3)--High Prio Interrupt
local warnFinalString						= mod:NewCastAnnounce(443487, 4, nil, nil, "Tank|Healer")--Cast at 20% health, so no timers
local warnSwarmingSurprise					= mod:NewCastAnnounce(442995, 3)
local warnShreddingStink					= mod:NewTargetNoFilterAnnounce(441410, 2, nil, false)--Might be spammy, off by default

local specWarnVolatileKeg					= mod:NewSpecialWarningSpell(463218, nil, nil, nil, 2, 2)
local specWarnTenderize						= mod:NewSpecialWarningSpell(463206, nil, nil, nil, 2, 2)
local specWarnEruptingInferno				= mod:NewSpecialWarningMoveAway(437956, nil, nil, nil, 1, 2)
local yellEruptingInferno					= mod:NewShortYell(437956)
local specWarnEruptingInfernoDispel			= mod:NewSpecialWarningDispel(437956, "RemoveMagic", nil, nil, 1, 2)
local specWarnCinderbrewToss				= mod:NewSpecialWarningMoveAway(434706, nil, nil, nil, 1, 2)
local yellCinderbrewToss					= mod:NewShortYell(434706)
local specWarnFailedBatch					= mod:NewSpecialWarningSwitch(441434, "-Healer", nil, nil, 1, 2)
local specWarnBoilingFlames					= mod:NewSpecialWarningInterrupt(437721, "HasInterrupt", nil, nil, 1, 2)
local specWarnHighSteaks					= mod:NewSpecialWarningDodge(434998, nil, nil, nil, 2, 2)
local specWarnRecklessDelivery				= mod:NewSpecialWarningDodge(448619, nil, nil, nil, 2, 2)
local yellRecklessDelivery					= mod:NewShortYell(448619)
local specWarnBeesWax						= mod:NewSpecialWarningDodge(442589, nil, nil, nil, 2, 2)
local specWarnDownwardtrend					= mod:NewSpecialWarningDodge(439467, nil, nil, nil, 2, 2)
local specWarnRainOfHoney					= mod:NewSpecialWarningDodge(440876, nil, nil, nil, 2, 2)
local specWarnBeezooka						= mod:NewSpecialWarningYou(441119, nil, nil, nil, 1, 2)
local yellBeezooka							= mod:NewShortYell(441119)
local specWarnRejuvenatingHoney				= mod:NewSpecialWarningInterrupt(441627, "HasInterrupt", nil, nil, 1, 2)--High Prio Interrupt
local specWarnFreeSamples					= mod:NewSpecialWarningInterrupt(441242, "HasInterrupt", nil, nil, 1, 2)
local specWarnBeastialWrath					= mod:NewSpecialWarningInterrupt(441351, "HasInterrupt", nil, nil, 1, 2)
local specWarnHoneyVolley					= mod:NewSpecialWarningInterrupt(440687, "HasInterrupt", nil, nil, 1, 2)
local specWarnRejuvenatingHoneyDispel		= mod:NewSpecialWarningDispel(441627, "MagicDispeller", nil, nil, 1, 2)
local specWarnSpillDrink					= mod:NewSpecialWarningDispel(441214, "RemoveEnrage", nil, nil, 1, 2)

--All timers need rechecking, but can't use public WCL to fix this since all logs short
local timerEruptingInfernoCD				= mod:NewCDNPTimer(17.1, 437956, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)--S2 updated
local timerBoilingFlamesCD					= mod:NewCDPNPTimer(24.3, 437721, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--S2 updated
local timerCinderbrewTossCD					= mod:NewCDNPTimer(11.8, 434706, nil, nil, nil, 3)--S2 updated
local timerThrowChairCD						= mod:NewCDNPTimer(15.8, 434756, nil, nil, nil, 3)--S2 Updated
local timerHighSteaksCD						= mod:NewCDNPTimer(20.3, 434998, nil, nil, nil, 3)--S2 Updated
local timerRecklessDeliveryCD				= mod:NewCDPNPTimer(30.3, 448619, nil, nil, nil, 3)--S2 Updated
local timerFailedBatchCD					= mod:NewCDNPTimer(22.2, 441434, nil, nil, nil, 5)--22.6-25.6 --S2 Updated
local timerSpillDrinkCD						= mod:NewCDNPTimer(20, 441214, nil, nil, nil, 5)--S2 confirmed
local timerBeesWaxCD						= mod:NewCDNPTimer(25.1, 442589, nil, nil, nil, 3)--S2 confirmed
local timerDownwardTrendCD					= mod:NewCDNPTimer(12.1, 439467, nil, nil, nil, 3)--S2 confirmed
local timerRejuvenatingHoneyCD				= mod:NewCDPNPTimer(24.2, 441627, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--S2 Updated
local timerMeanMugCD						= mod:NewCDNPTimer(15.8, 434773, nil, nil, nil, 5)--S2 Updated
local timerVolatileKegCD					= mod:NewCDNPTimer(24.1, 463218, nil, nil, nil, 2)--S2 Updated
local timerTenderizeCD						= mod:NewCDNPTimer(18.2, 463206, nil, nil, nil, 2)--S2 Updated
local timerFreeSamplesCD					= mod:NewCDNPTimer(16.6, 441242, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--S2 Updated
local timerShreddingStingCD					= mod:NewCDNPTimer(12.1, 441410, nil, nil, nil, 3)--S2 Updated
local timerBeastialWrathCD					= mod:NewCDNPTimer(18.4, 441351, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--S2 Updated (good 4 sec of variance)
local timerBeezookaCD						= mod:NewCDNPTimer(18.2, 441119, nil, nil, nil, 3)--S2 Updated
local timerSwarmingSurpriseCD				= mod:NewCDNPTimer(23.1, 442995, nil, nil, nil, 2)--S2 Updated
local timerHoneyVolleyCD					= mod:NewCDNPTimer(24.1, 440687, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--S2 Updated
local timerRainofHoneyCD					= mod:NewCDNPTimer(16.6, 440876, nil, nil, nil, 3)--S2 Updated

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

function mod:DeliveryTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			yellRecklessDelivery:Yell()
		end
	end
end

function mod:ShreddingTarget(targetname)
	if not targetname then return end
	warnShreddingStink:Show(targetname)
end

function mod:BeezookaTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnBeezooka:Show()
		specWarnBeezooka:Play("lineyou")
		yellBeezooka:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 434706 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "CinderbrewTarget", 0.1, 6)
		timerCinderbrewTossCD:Start(nil, args.sourceGUID)
	elseif spellId == 434756 then
		timerThrowChairCD:Start(nil, args.sourceGUID)
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ThrowChair", 0.1, 6)
	elseif spellId == 437721 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBoilingFlames:Show(args.sourceName)
			specWarnBoilingFlames:Play("kickcast")
		end
	elseif spellId == 441242 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnFreeSamples:Show(args.sourceName)
		specWarnFreeSamples:Play("kickcast")
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
		timerRecklessDeliveryCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRecklessDelivery:Show()
			specWarnRecklessDelivery:Play("chargemove")
		end
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "DeliveryTarget", 0.1, 6)
	elseif spellId == 442589 then
		timerBeesWaxCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBeesWax:Show()
			specWarnBeesWax:Play("watchstep")
		end
	elseif spellId == 439467 then
		timerDownwardTrendCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnDownwardtrend:Show()
			specWarnDownwardtrend:Play("watchstep")
		end
	elseif spellId == 463218 then
		timerVolatileKegCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnVolatileKeg:Show()
			specWarnVolatileKeg:Play("aesoon")
		end
	elseif spellId == 463206 then
		timerTenderizeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnTenderize:Show()
			specWarnTenderize:Play("carefly")
		end
	elseif spellId == 441410 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "ShreddingTarget", 0.1, 6)
	elseif spellId == 443487 and self:AntiSpam(3, 5) then
		warnFinalString:Show()
	elseif spellId == 441351 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnBeastialWrath:Show(args.sourceName)
		specWarnBeastialWrath:Play("kickcast")
	elseif spellId == 441119 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "BeezookaTarget", 0.1, 6)
	elseif spellId == 442995 then
		timerSwarmingSurpriseCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			warnSwarmingSurprise:Show()
		end
	elseif spellId == 440687 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnHoneyVolley:Show(args.sourceName)
		specWarnHoneyVolley:Play("kickcast")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 437721 then
		timerBoilingFlamesCD:Start(24.3, args.sourceGUID)
	elseif spellId == 441627 then
		timerRejuvenatingHoneyCD:Start(24.2, args.sourceGUID)
	elseif spellId == 441214 then
		timerSpillDrinkCD:Start(20, args.sourceGUID)
	elseif spellId == 441434 then
		timerFailedBatchCD:Start(22.8, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			specWarnFailedBatch:Show()
			specWarnFailedBatch:Play("targetchange")
		end
	elseif spellId == 434998 then
		timerHighSteaksCD:Start(20.3, args.sourceGUID)
	elseif spellId == 437956 then
		timerEruptingInfernoCD:Start(16.1, args.sourceGUID)--17.1-1
	elseif spellId == 434773 then
		timerMeanMugCD:Start(14.8, args.sourceGUID)--15.8-1
	elseif spellId == 441242 then
		timerFreeSamplesCD:Start(17.1, args.sourceGUID)
	elseif spellId == 441410 then
		timerShreddingStingCD:Start(14.3, args.sourceGUID)--15.8-1.5
	elseif spellId == 441351 then
		timerBeastialWrathCD:Start(18.4, args.sourceGUID)
	elseif spellId == 441119 then
		timerBeezookaCD:Start(15.2, args.sourceGUID)
	elseif spellId == 440687 then
		timerHoneyVolleyCD:Start(24.1, args.sourceGUID)
	elseif spellId == 440876 then
		timerRainofHoneyCD:Start(17, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRainOfHoney:Show()
			specWarnRainOfHoney:Play("watchstep")
		end
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	local spellId = args.extraSpellId
	if spellId == 441627 then
		timerRejuvenatingHoneyCD:Start(24.2, args.destGUID)
	elseif spellId == 441242 then
		timerFreeSamplesCD:Start(17.1, args.destGUID)
	elseif spellId == 441351 then
		timerBeastialWrathCD:Start(18.4, args.destGUID)
	elseif spellId == 440687 then
		timerHoneyVolleyCD:Start(24.1, args.destGUID)
	--elseif spellId == 437721 then
	--	timerBoilingFlamesCD:Start(24.3, args.destGUID)
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
		timerThrowChairCD:Stop(args.destGUID)
		timerVolatileKegCD:Stop(args.destGUID)
	elseif cid == 214920 then--Tasting Room Agent
		timerCinderbrewTossCD:Stop(args.destGUID)
	elseif cid == 214697 then--Chef Chewie
		timerHighSteaksCD:Stop(args.destGUID)
		timerTenderizeCD:Stop(args.destGUID)
	elseif cid == 223423 then--Careless Hobgoblin
		timerRecklessDeliveryCD:Stop(args.destGUID)
	elseif cid == 222964 then--Flavor Scientist
		timerFailedBatchCD:Stop(args.destGUID)
		timerRejuvenatingHoneyCD:Stop(args.destGUID)
	elseif cid == 220060 then--Taste Tester
		timerSpillDrinkCD:Stop(args.destGUID)
		timerFreeSamplesCD:Stop(args.destGUID)
	elseif cid == 220946 then--Venture Co Honey Harvester
		timerBeesWaxCD:Stop(args.destGUID)
		timerSwarmingSurpriseCD:Stop(args.destGUID)
	elseif cid == 219588 then--Yes Man
		timerDownwardTrendCD:Stop(args.destGUID)
	elseif cid == 214668 then--Venture Co. Patron
		timerMeanMugCD:Stop(args.destGUID)
	elseif cid == 218016 or cid == 210265 then--Worker Bee
		timerShreddingStingCD:Stop(args.destGUID)
	elseif cid == 210264 then--Bee Wrangler
		timerBeastialWrathCD:Stop(args.destGUID)
		timerBeezookaCD:Stop(args.destGUID)
	elseif cid == 220141 then--Royal Jelly Purveyor
		timerHoneyVolleyCD:Stop(args.destGUID)
		timerRainofHoneyCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 218671 then--Venture Co Pyromaniac
		timerEruptingInfernoCD:Start(8.9-delay, guid)
		timerBoilingFlamesCD:Start(16-delay, guid)
	elseif cid == 210269 then--Hired Muscle
		timerVolatileKegCD:Start(8.1-delay, guid)
		timerThrowChairCD:Start(13-delay, guid)
	elseif cid == 214920 then--Tasting Room Agent
		timerCinderbrewTossCD:Start(11.2-delay, guid)
	elseif cid == 214697 then--Chef Chewie
		timerTenderizeCD:Start(8.2-delay, guid)
		timerHighSteaksCD:Start(12.3-delay, guid)
	elseif cid == 223423 then--Careless Hobgoblin
		timerRecklessDeliveryCD:Start(9.1-delay, guid)
	elseif cid == 222964 then--Flavor Scientist
		timerFailedBatchCD:Start(14.5-delay, guid)
		timerRejuvenatingHoneyCD:Start(14.5-delay, guid)--Super iffy, most heals don't have initial CDs just initial threshold of health
	elseif cid == 220060 then--Taste Tester
		timerSpillDrinkCD:Start(9.5-delay, guid)
		timerFreeSamplesCD:Start(11.1-delay, guid)--11.1-15.4
	elseif cid == 220946 then--Venture Co Honey Harvester
		timerSwarmingSurpriseCD:Start(4.5-delay, guid)--4.5-10
		timerBeesWaxCD:Start(10.6-delay, guid)--10.6--17
	elseif cid == 219588 then--Yes Man
		timerDownwardTrendCD:Start(5-delay, guid)
	elseif cid == 214668 then--Venture Co. Patron
		timerMeanMugCD:Start(7.6-delay, guid)
	elseif cid == 218016 or cid == 210265 then--Worker Bee
		timerShreddingStingCD:Start(9.4-delay, guid)
	elseif cid == 210264 then--Bee Wrangler
		timerBeezookaCD:Start(7-delay, guid)
		timerBeastialWrathCD:Start(3.7-delay, guid)--3.7-11.4
	elseif cid == 220141 then--Royal Jelly Purveyor
		timerHoneyVolleyCD:Start(4.8-delay, guid)--4.8-10.1
		timerRainofHoneyCD:Start(16.2-delay, guid)
	end
end

function mod:LeavingZoneCombat()
	self:Stop(true)
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
