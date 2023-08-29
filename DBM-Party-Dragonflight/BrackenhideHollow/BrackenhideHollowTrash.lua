local mod	= DBM:NewMod("BrackenhideHollowTrash", "DBM-Party-Dragonflight", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)
mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 382555 367500 388060 388046 382474 382787 374544 385029 383062 367503 373897 382712 373943 374569 385832",
	"SPELL_CAST_SUCCESS 382555 368287 383385 382435 384930 372711",
	"SPELL_SUMMON 374057",
	"SPELL_AURA_APPLIED 383087 383399 385058 385827 384974 367484 368081",
--	"SPELL_AURA_APPLIED_DOSE 339528",
--	"SPELL_AURA_REMOVED 339525",
	"SPELL_PERIODIC_DAMAGE 383399",
	"SPELL_PERIODIC_MISSED 383399",
	"UNIT_DIED"
)

--TODO, half the mobs in zone cast Bloody Bite, is it worth having a Cd bar? cause it's pretty hard to vet for so many diff mobs
--TODO: can https://www.wowhead.com/ptr/spell=383385/rotting-surge can be stunned (but not interrupted)
--TODO, can burst of decay be interrupted/stunned or target scanned?
--TODO, Add https://www.wowhead.com/spell=382593/crushing-smash?
--TODO, add https://www.wowhead.com/spell=382410/witherbolt interrupt warning?
--TODO, ragestorm cd might not start til last one is stopped? need more data
--TODO, auto detect and correct CD timers if mob affected by https://www.wowhead.com/spell=367510/pack-tactics ?
--TODO, add https://www.wowhead.com/spell=384899/bone-bolt-volley
--TODO, add https://www.wowhead.com/spell=382883/siphon-decay ?
--[[
(ability.id = 384899 or ability.id = 367481 or ability.id = 382555 or ability.id = 367500 or ability.id = 388060 or ability.id = 388046 or ability.id = 382474 or ability.id = 382787 or ability.id = 374544 or ability.id = 385029 or ability.id = 383062 or ability.id = 367503 or ability.id = 373897 or ability.id = 382712 or ability.id = 373943 or ability.id = 374569 or ability.id = 385832) and type = "begincast"
 or (ability.id = 368287 or ability.id = 383385 or ability.id = 382435 or ability.id = 384930 or ability.id = 372711) and type = "cast"
 or ability.id = 374057
--]]
local warnBurstofDecay						= mod:NewCastAnnounce(374544, 4)--Change to target scan?
local warnHidiousCackle						= mod:NewCastAnnounce(367500, 4)
local warnScreech							= mod:NewCastAnnounce(385029, 4)
local warnDecayClaws						= mod:NewCastAnnounce(382787, 4, nil, nil, "Tank|Healer")
local warnSummonLashers						= mod:NewCastAnnounce(383062, 2, nil, nil, "Tank")
local warnDecayingRoots						= mod:NewCastAnnounce(373897, 3)
local warnBurst								= mod:NewCastAnnounce(374569, 4)
local warnWitheringContagion				= mod:NewTargetAnnounce(383087, 3)
local warnWitheringBurst					= mod:NewTargetAnnounce(367503, 3)
local warnInfuseCorruption					= mod:NewTargetNoFilterAnnounce(372711, 3)--Used as target warning but is off interrupt too
local warnStealth							= mod:NewSpellAnnounce(384930, 3)
--local warnSummontotem						= mod:NewSpellAnnounce(374057, 4)--Despite tooltip showing cast time, only event in log is SPELL_SUMMON

local specWarnViolentWhirlwind				= mod:NewSpecialWarningRun(388046, "Melee", nil, nil, 4, 2)
local specWarnScentedMeat					= mod:NewSpecialWarningRun(384974, nil, nil, nil, 4, 2)
local specWarnViciousClawmangle				= mod:NewSpecialWarningRun(367484, nil, nil, nil, 4, 2)
local specWarnRagestorm						= mod:NewSpecialWarningRun(382555, "Melee", nil, nil, 4, 2)
local specWarnRagestormDispel				= mod:NewSpecialWarningDispel(382555, "RemoveEnrage", nil, nil, 1, 2)
local specWarnBloodyRage					= mod:NewSpecialWarningDispel(385827, "RemoveEnrage", nil, nil, 1, 2)
local specWarnWitheringPoison				= mod:NewSpecialWarningDispel(385058, "RemovePoison", nil, nil, 1, 2)
local specWarnWithering						= mod:NewSpecialWarningDispel(368081, false, nil, nil, 1, 2)
local specWarnWitheringContagion			= mod:NewSpecialWarningMoveAway(383087, nil, nil, nil, 1, 2)
local specWarnStinkBreath					= mod:NewSpecialWarningDodge(388060, nil, nil, nil, 2, 2)
local specWarnToxicTrap						= mod:NewSpecialWarningDodge(368287, nil, nil, nil, 2, 2)
local specWarnRottingSurge					= mod:NewSpecialWarningDodge(383385, nil, nil, nil, 2, 2)
local specWarnStomp							= mod:NewSpecialWarningDodge(373943, nil, nil, nil, 2, 2)
local specWarnBloodthirstyCharge			= mod:NewSpecialWarningDodge(385832, nil, nil, nil, 2, 2)
local specWarnSummontotem					= mod:NewSpecialWarningSwitch(374057, "Dps", nil, nil, 1, 2)
local specWarnRotchantingTotem				= mod:NewSpecialWarningSwitch(382435, "Dps", nil, nil, 1, 2)
local yellWitheringContagion				= mod:NewYell(383087)
local specWarnWitheringBurst				= mod:NewSpecialWarningYou(367503, nil, nil, nil, 1, 2)
local yellWitheringBurst					= mod:NewYell(367503)
local specWarnBurstofDecay					= mod:NewSpecialWarningInterrupt(374544, "HasInterrupt", nil, nil, 1, 2)
local specWarnHidiousCackle					= mod:NewSpecialWarningInterrupt(367500, "HasInterrupt", nil, nil, 1, 2)--46?
local specWarnDecaySurge					= mod:NewSpecialWarningInterrupt(382474, "HasInterrupt", nil, nil, 1, 2)
local specWarnScreech						= mod:NewSpecialWarningInterrupt(385029, "HasInterrupt", nil, nil, 1, 2)
local specWarnNecroticBreath				= mod:NewSpecialWarningInterrupt(382712, "HasInterrupt", nil, nil, 1, 2)--26.7-40?
local specWarnGTFO							= mod:NewSpecialWarningGTFO(383399, nil, nil, nil, 1, 8)

local timerDecayClawsCD						= mod:NewCDTimer(10.2, 382787, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerWitheringBurstCD					= mod:NewCDTimer(19.4, 367503, nil, nil, nil, 3)--19-26
local timerSummonLashersCD					= mod:NewCDTimer(12.2, 383062, nil, nil, nil, 1)--12-15
local timerStinkBreathCD					= mod:NewCDTimer(17, 388060, nil, nil, nil, 3)
local timerViolentWhirlwindCD				= mod:NewCDTimer(17, 388046, nil, nil, nil, 2)
local timerStompCD							= mod:NewCDTimer(17, 373943, nil, nil, nil, 2)
local timerRottingSurgeCD					= mod:NewCDTimer(23, 383385, nil, nil, nil, 3)--TODO, limited data

--local playerName = UnitName("player")

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt, 8 gtfo

function mod:BurstTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		if self:AntiSpam(4, 5) then
			specWarnWitheringBurst:Show()
			specWarnWitheringBurst:Play("targetyou")
		end
		yellWitheringBurst:Yell()
	else
		warnWitheringBurst:Show(targetname)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if not self:IsValidWarning(args.sourceGUID) then return end
	if spellId == 382555 and self:AntiSpam(3, 1) then
		specWarnRagestorm:Show()
		specWarnRagestorm:Play("justrun")
	elseif spellId == 367500 then
		if self.Options.SpecWarn367500interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHidiousCackle:Show(args.sourceName)
			specWarnHidiousCackle:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHidiousCackle:Show()
		end
	elseif spellId == 382474 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDecaySurge:Show(args.sourceName)
			specWarnDecaySurge:Play("kickcast")
		end
	elseif spellId == 382712 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnNecroticBreath:Show(args.sourceName)
			specWarnNecroticBreath:Play("kickcast")
		end
	elseif spellId == 388060 then
		if self:AntiSpam(3, 2) then
			specWarnStinkBreath:Show()
			specWarnStinkBreath:Play("shockwave")
		end
		timerStinkBreathCD:Start(nil, args.sourceGUID)
	elseif spellId == 373943 then
		if self:AntiSpam(3, 2) then
			specWarnStomp:Show()
			specWarnStomp:Play("watchstep")
		end
		timerStompCD:Start(nil, args.sourceGUID)
	elseif spellId == 388046 then
		if self:AntiSpam(3, 1) then
			specWarnViolentWhirlwind:Show()
			specWarnViolentWhirlwind:Play("justrun")
		end
		timerViolentWhirlwindCD:Start(nil, args.sourceGUID)
	elseif spellId == 385832 and self:AntiSpam(3, 2) then
		specWarnBloodthirstyCharge:Show()
		specWarnBloodthirstyCharge:Play("chargemove")
	elseif spellId == 382787 then
		timerDecayClawsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 7) then
			warnDecayClaws:Show()
		end
	elseif spellId == 374544 then
		if self.Options.SpecWarn374544interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnBurstofDecay:Show(args.sourceName)
			specWarnBurstofDecay:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnBurstofDecay:Show()
		end
	elseif spellId == 385029 then
		if self.Options.SpecWarn385029interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnScreech:Show(args.sourceName)
			specWarnScreech:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnScreech:Show()
		end
	elseif spellId == 383062 then
		if self:AntiSpam(3, 5) then
			warnSummonLashers:Show()
		end
		if args:GetSrcCreatureID() == 186229 then--Wilted Oak
			timerSummonLashersCD:Start(46, args.sourceGUID)
		else--Decayed Elder (189531)
			timerSummonLashersCD:Start(12.2, args.sourceGUID)
		end
	elseif spellId == 367503 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "BurstTarget", 0.1, 8)
		timerWitheringBurstCD:Start(nil, args.sourceGUID)
	elseif spellId == 373897 and self:AntiSpam(3, 5) then
		warnDecayingRoots:Show()
	elseif spellId == 374569 and self:AntiSpam(3, 6) then
		warnBurst:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 368287 and self:AntiSpam(3, 2) then
		specWarnToxicTrap:Show()
		specWarnToxicTrap:Play("watchstep")
	elseif spellId == 383385 then
		timerRottingSurgeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRottingSurge:Show()
			specWarnRottingSurge:Play("watchstep")
		end
	elseif spellId == 382435 and self:AntiSpam(3, 5) then
		specWarnRotchantingTotem:Show()
		specWarnRotchantingTotem:Play("attacktotem")
	elseif spellId == 384930 and self:AntiSpam(3, 5) then
		warnStealth:Show()
	elseif spellId == 372711 and self:AntiSpam(3, 7) then
		warnInfuseCorruption:Show(args.destName)
	elseif spellId == 382555 and self:AntiSpam(3, 3) then--Buff not in combat log, so success is used to assume buff went up
		specWarnRagestormDispel:Show(args.sourceName)
		specWarnRagestormDispel:Play("enrage")
	end
end

function mod:SPELL_SUMMON(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 374057 and self:AntiSpam(3, 5) then
		specWarnSummontotem:Show()
		specWarnSummontotem:Play("attacktotem")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 385827 and self:AntiSpam(3, 3) then
		specWarnBloodyRage:Show(args.destName)
		specWarnBloodyRage:Play("enrage")
	elseif spellId == 383087 then
		warnWitheringContagion:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnWitheringContagion:Show()
			specWarnWitheringContagion:Play("range5")
			yellWitheringContagion:Yell()
		end
	elseif spellId == 383399 and args:IsPlayer() and self:AntiSpam(3, 8) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 385058 and args:IsDestTypePlayer() and self:CheckDispelFilter("poison") and self:AntiSpam(3, 3) then
		specWarnWitheringPoison:Show(args.destName)
		specWarnWitheringPoison:Play("helpdispel")
	elseif spellId == 368081 and args:IsDestTypePlayer() and self:CheckDispelFilter("disease") and self:AntiSpam(3, 3) then
		specWarnWithering:Show(args.destName)
		specWarnWithering:Play("helpdispel")
	elseif spellId == 384974 and args:IsPlayer() and self:AntiSpam(4, 1) then
		specWarnScentedMeat:Show()
		specWarnScentedMeat:Play("justrun")
	elseif spellId == 367484 and args:IsPlayer() and self:AntiSpam(4, 1) then
		specWarnViciousClawmangle:Show()
		specWarnViciousClawmangle:Play("justrun")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 339525 and args:IsPlayer() then

	end
end
--]]

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 383399 and destGUID == UnitGUID("player") and self:AntiSpam(2, 8) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 186191 then--Decay Speaker
		timerWitheringBurstCD:Stop(args.destGUID)
	elseif cid == 189531 then--Decay Elder
		timerSummonLashersCD:Stop(args.destGUID)
	elseif cid == 187033 then--Stink Breath
		timerStinkBreathCD:Stop(args.destGUID)
		timerViolentWhirlwindCD:Stop(args.destGUID)
	elseif cid == 187315 then--Disease Slasher
		timerDecayClawsCD:Stop(args.destGUID)
	elseif cid == 186229 then--Wilted Oak
		timerStompCD:Stop(args.destGUID)
		timerSummonLashersCD:Stop(args.destGUID)
	elseif cid == 185656 then--Filth Caller
		timerRottingSurgeCD:Stop(args.destGUID)
	end
end
