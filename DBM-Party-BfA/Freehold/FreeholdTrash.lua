local mod	= DBM:NewMod("FreeholdTrash", "DBM-Party-BfA", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetModelID(47785)

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_CAST_START 257732 257397 257899 257736 258777 257784 257756 274860 257426 274383 258199 272402 257870 274400 257436 258672 258181 274507",
	"SPELL_CAST_SUCCESS 257747 258777 257272",
	"SPELL_AURA_APPLIED 257274 257476 258323 257739 257908 257397 257775",
	"SPELL_AURA_APPLIED_DOSE 274555",
	"UNIT_DIED",
	"UNIT_SPELLCAST_START_UNFILTERED",
	"ENCOUNTER_START"
)

--TODO, poision Strikes dispel/stack warning?
--TODO, Reverify dash target scan on 10.1, before re-enabling it
--TODO, alert for https://www.wowhead.com/spell=272413/dragging-harpoon ?
--TODO, Healing Balm CD? can't find any logs it was cast twice by single mob
--[[
(ability.id = 257732 or ability.id = 257397 or ability.id = 257899 or ability.id = 257736 or ability.id = 258777 or ability.id = 257784 or ability.id = 257756 or ability.id = 274860 or ability.id = 257426 or ability.id = 274383 or ability.id = 258199 or ability.id = 272402 or ability.id = 257870 or ability.id = 274400 or ability.id = 257436 or ability.id = 258672 or ability.id = 258181 or ability.id = 274507) and type = "begincast"
 or (ability.id = 257747 or ability.id = 258777 or ability.id = 257272 or ability.id = 274400) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--local warnDuelistDash					= mod:NewTargetNoFilterAnnounce(274400, 4)
--local warnRatTrap						= mod:NewCastAnnounce(274383, 2)
local warnPoisoningStrike				= mod:NewCastAnnounce(257436, 2, nil, nil, "Tank|Healer")
local warnHealingBalm					= mod:NewCastAnnounce(257397, 3)
local warnShatteringBellow				= mod:NewCastAnnounce(257732, 4)
local warnPainfulMotivation				= mod:NewCastAnnounce(257899, 4)
local warnThunderingSquall				= mod:NewCastAnnounce(257736, 3)
local warnSlipperySuds					= mod:NewCastAnnounce(274507, 3)
local warnRicochetingThrow				= mod:NewTargetAnnounce(272402, 2)
local warnSabrousBite					= mod:NewStackAnnounce(274555, 2, nil, "Tank|Healer")

local yellRicochetingThrow				= mod:NewYell(272402)
local yellDuelistDash					= mod:NewYell(274400)
local specWarnOiledBladeSelf			= mod:NewSpecialWarningDefensive(257908, nil, nil, nil, 1, 2)
local specWarnVileBombardment			= mod:NewSpecialWarningDodge(257272, nil, nil, nil, 2, 2)
local specWarnBrutalBackhand			= mod:NewSpecialWarningDodge(257426, nil, nil, nil, 2, 2)
local specWarnAzeriteGrenade			= mod:NewSpecialWarningDodge(258672, nil, nil, nil, 2, 2)
local specWarnDuelistDash				= mod:NewSpecialWarningDodge(274400, nil, nil, nil, 2, 2)
local specWarnSeaSpout					= mod:NewSpecialWarningDodge(258777, nil, nil, nil, 2, 2)
local specWarnRatTrap					= mod:NewSpecialWarningDodge(274383, nil, nil, nil, 2, 2)
local specWarnBoulderThrow				= mod:NewSpecialWarningDodge(258181, nil, nil, nil, 2, 2)
local specWarnBladeBarrage				= mod:NewSpecialWarningDodge(257870, nil, nil, nil, 2, 2)
local specWarnShatteringToss			= mod:NewSpecialWarningSpell(274860, "Tank", nil, nil, 1, 12)
local specWarnGoinBan					= mod:NewSpecialWarningRun(257756, "Melee", nil, nil, 4, 2)
local specWarnGroundShatter				= mod:NewSpecialWarningRun(258199, "Melee", nil, nil, 4, 2)
local specWarnBlindRagePlayer			= mod:NewSpecialWarningRun(257739, nil, nil, nil, 4, 2)
local specWarnSlipperySudsYou			= mod:NewSpecialWarningYou(274507, nil, nil, nil, 1, 2)
local specWarnHealingBalm				= mod:NewSpecialWarningInterrupt(257397, "HasInterrupt", nil, nil, 1, 2)
local specWarnPainfulMotivation			= mod:NewSpecialWarningInterrupt(257899, false, nil, 2, 1, 2)--Off by default since it'll be common strategy NOT to interrupt this ever for dps gain
local specWarnThunderingSquall			= mod:NewSpecialWarningInterrupt(257736, "HasInterrupt", nil, nil, 1, 2)
local specWarnSeaSpout					= mod:NewSpecialWarningInterrupt(258777, "HasInterrupt", nil, nil, 1, 2)
local specWarnFrostBlast				= mod:NewSpecialWarningInterrupt(257784, "HasInterrupt", nil, nil, 1, 2)--Might prune or disable by default if it conflicts with higher priority interrupts in area
local specWarnShatteringBellowKick		= mod:NewSpecialWarningInterrupt(257732, "HasInterrupt", nil, nil, 1, 2)
local specWarnSlipperySuds				= mod:NewSpecialWarningInterrupt(274507, "HasInterrupt", nil, nil, 1, 2)
local specWarnBestialWrath				= mod:NewSpecialWarningDispel(257476, "RemoveEnrage", nil, 2, 1, 2)
local specWarnBlindRage					= mod:NewSpecialWarningDispel(257739, "RemoveEnrage", nil, 2, 1, 2)
local specWarnInfectedWound				= mod:NewSpecialWarningDispel(258323, "RemoveDisease", nil, nil, 1, 2)
local specWarnPlagueStep				= mod:NewSpecialWarningDispel(257775, "RemoveDisease", nil, nil, 1, 2)
local specWarnOiledBlade				= mod:NewSpecialWarningDispel(257908, "RemoveMagic", nil, 2, 1, 2)
local specWarnHealingBalmDispel			= mod:NewSpecialWarningDispel(257397, "MagicDispeller", nil, nil, 1, 2)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerVileBombardmentCD			= mod:NewCDTimer(16, 257272, nil, nil, nil, 3)
local timerShatteringBellowCD			= mod:NewCDTimer(27.8, 257732, nil, nil, nil, 2)
local timerBrutalBackhandCD				= mod:NewCDTimer(18.2, 257426, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSeaSpoutCD					= mod:NewCDTimer(17, 258777, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerRatTrapsCD					= mod:NewCDTimer(20.6, 274383, nil, nil, nil, 3)
local timerRicochetingThrowCD			= mod:NewCDTimer(8.4, 272402, nil, nil, nil, 3)
local timerEarthShakerCD				= mod:NewCDTimer(8.4, 257747, nil, nil, nil, 3)--Instance cast, not really worth announcing every 8 sec, but def worth having a timer for
local timerGoinBanCD					= mod:NewCDTimer(17, 257756, nil, nil, nil, 3)
local timerSlipperySudsCD				= mod:NewCDTimer(20.6, 274507, nil, nil, nil, 3)
local timerGroundShatterCD				= mod:NewCDTimer(19.3, 258199, nil, nil, nil, 3)
local timerBoulderThrowCD				= mod:NewCDTimer(19.3, 258181, nil, nil, nil, 3)
local timerPainfulMotivationCD			= mod:NewCDTimer(18.1, 257899, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBladeBarrageCD				= mod:NewCDTimer(18.2, 257870, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerThunderingSquallCD			= mod:NewCDTimer(27.8, 257736, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:RicochetingTarget(targetname)
	if not targetname then return end
	if self:AntiSpam(3, targetname) then
		warnRicochetingThrow:CombinedShow(0.5, targetname)
		if targetname == UnitName("player") then
			yellRicochetingThrow:Yell()
		end
	end
end

function mod:DashTarget(targetname)
	if not targetname then return end
--	warnDuelistDash:Show(targetname)
	if targetname == UnitName("player") then
		yellDuelistDash:Yell()
	end
end

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 257397 then
		if self.Options.SpecWarn257397interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnHealingBalm:Show(args.sourceName)
			specWarnHealingBalm:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnHealingBalm:Show()
		end
	elseif spellId == 257899 then
		timerPainfulMotivationCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn257899interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPainfulMotivation:Show(args.sourceName)
			specWarnPainfulMotivation:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnPainfulMotivation:Show()
		end
	elseif spellId == 257736 then
		timerThunderingSquallCD:Start(nil, args.sourceGUID)
		if self.Options.SpecWarn257736interrupt and self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnThunderingSquall:Show(args.sourceName)
			specWarnThunderingSquall:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnThunderingSquall:Show()
		end
	elseif spellId == 258777 then
		timerSeaSpoutCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSeaSpout:Show(args.sourceName)
			specWarnSeaSpout:Play("kickcast")
		end
	elseif spellId == 257784 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnFrostBlast:Show(args.sourceName)
		specWarnFrostBlast:Play("kickcast")
	elseif spellId == 257732 then
		timerShatteringBellowCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) and self.Options.SpecWarn257732interrupt then
			specWarnShatteringBellowKick:Show(args.sourceName)
			specWarnShatteringBellowKick:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnShatteringBellow:Show()
		end
	elseif spellId == 274507 then
		timerSlipperySudsCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) and self.Options.SpecWarn274507interrupt then
			specWarnSlipperySuds:Show(args.sourceName)
			specWarnSlipperySuds:Play("kickcast")
		elseif self:AntiSpam(3, 7) then
			warnSlipperySuds:Show()
		end
	elseif spellId == 257756 then
		timerGoinBanCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(4, 1) then
			specWarnGoinBan:Show()
			specWarnGoinBan:Play("justrun")
		end
	elseif spellId == 257870 then
		timerBladeBarrageCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBladeBarrage:Show()
			specWarnBladeBarrage:Play("shockwave")
		end
	elseif spellId == 274860 and self:AntiSpam(3, 5) then
		specWarnShatteringToss:Show()
		specWarnShatteringToss:Play("tosscoming")
	elseif spellId == 257426 then
		timerBrutalBackhandCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBrutalBackhand:Show()
			specWarnBrutalBackhand:Play("shockwave")
		end
	elseif spellId == 258181 then
		timerBoulderThrowCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnBoulderThrow:Show()
			specWarnBoulderThrow:Play("watchstep")
		end
	elseif spellId == 274400 then
--		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "DashTarget", 0.1, 8)
	elseif spellId == 274383 then
		timerRatTrapsCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnRatTrap:Show()
			specWarnRatTrap:Play("watchstep")
		end
	elseif spellId == 258199 then
		timerGroundShatterCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 1) then
			specWarnGroundShatter:Show()
			specWarnGroundShatter:Play("justrun")
		end
	elseif spellId == 272402 then
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "RicochetingTarget", 0.1, 4)
		timerRicochetingThrowCD:Start(nil, args.sourceGUID)
	elseif spellId == 257436 and self:AntiSpam(3, 5) then
		warnPoisoningStrike:Show()
	elseif spellId == 258672 and self:AntiSpam(3, 2) then
		specWarnAzeriteGrenade:Show()
		specWarnAzeriteGrenade:Play("watachstep")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 257747 then
		timerEarthShakerCD:Start(nil, args.sourceGUID)
	elseif spellId == 258777 and self:AntiSpam(3, 2) then
		specWarnSeaSpout:Show()
		specWarnSeaSpout:Play("watchstep")
	elseif spellId == 257272 and self:AntiSpam(3, 2) then
		specWarnVileBombardment:Show()
		specWarnVileBombardment:Play("watchstep")
		timerVileBombardmentCD:Start()--No GUID needed, SharkBait isn't in nameplate range at this time
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 257274 and args:IsPlayer() and self:AntiSpam(2, 2) then--Vile Coating
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 257476 and self:AntiSpam(3, 3) then
		specWarnBestialWrath:Show(args.destName)
		specWarnBestialWrath:Play("helpdispel")
	elseif spellId == 257739 and self:AntiSpam(3, 3) then
		--If it can be dispelled by affected player, no reason to tell them to run away, dispel is priority
		if self.Options.SpecWarn257739dispel then
			specWarnBlindRage:Show(args.sourceName)
			specWarnBlindRage:Play("enrage")
		elseif args:IsPlayer() and not self:IsTank() then
			specWarnBlindRagePlayer:Show()
			specWarnBlindRagePlayer:Play("justrun")
		end
	elseif spellId == 257908 and args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		--If tank can dispel self, no reason to tell tank to defensive through it, dispel is priority
		if self.Options.SpecWarn257908dispel and self:CheckDispelFilter("magic") then
			specWarnOiledBlade:Show(args.destName)
			specWarnOiledBlade:Play("helpdispel")
		elseif args:IsPlayer() then
			specWarnOiledBladeSelf:Show()
			specWarnOiledBladeSelf:Play("defensive")
		end
	elseif spellId == 258323 and args:IsDestTypePlayer() and self:CheckDispelFilter("disease") and self:AntiSpam(3, 3) then
		specWarnInfectedWound:Show(args.destName)
		specWarnInfectedWound:Play("helpdispel")
	elseif spellId == 257397 and not args:IsDestTypePlayer() and self:AntiSpam(3, 3) then
		specWarnHealingBalmDispel:Show(args.destName)
		specWarnHealingBalmDispel:Play("helpdispel")
	elseif spellId == 257775 and args:IsDestTypePlayer() and self:CheckDispelFilter("disease") and self:AntiSpam(3, 3) then
		specWarnPlagueStep:Show(args.destName)
		specWarnPlagueStep:Play("helpdispel")
	elseif spellId == 274555 then
		local amount = args.amount or 1
		if amount >= 3 and self:AntiSpam(3, 5) then
			warnSabrousBite:Show(args.destName, amount)
		end
	elseif spellId == 274507 and args:IsPlayer() then
		specWarnSlipperySudsYou:Show()
		specWarnSlipperySudsYou:Play("targetyou")
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 129548 then--Blacktooth Brute
		timerEarthShakerCD:Stop(args.destGUID)
	elseif cid == 129602 then--Irontide Enforcer
		timerShatteringBellowCD:Stop(args.destGUID)
		timerBrutalBackhandCD:Stop(args.destGUID)
	elseif cid == 127111 then--Irontide Oarsman
		timerSeaSpoutCD:Stop(args.destGUID)
	elseif cid == 130404 then--Vermin Trapper
		timerRatTrapsCD:Stop(args.destGUID)
	elseif cid == 129599 then--Cutthroat Knife Juggler
		timerRicochetingThrowCD:Stop(args.destGUID)
	elseif cid == 129527 then--Bilge Rat Buccaneer
		timerGoinBanCD:Stop(args.destGUID)
	elseif cid == 129526 then--Bilge Rat Swabby
		timerSlipperySudsCD:Stop(args.destGUID)
	elseif cid == 130400 then--Irontide Crusher
		timerGroundShatterCD:Stop(args.destGUID)
		timerBoulderThrowCD:Stop(args.destGUID)
	elseif cid == 130012 then--Irontide Ravager
		timerPainfulMotivationCD:Stop(args.destGUID)
	elseif cid == 130011 then--Irontide Buccaneer
		timerBladeBarrageCD:Stop(args.destGUID)
	elseif cid == 126919 then--Irontide Stormcaller
		timerThunderingSquallCD:Stop(args.destGUID)
	end
end

--in 10.1 for some reason blizzard removed start from combat log, even though it existed in BFA
function mod:UNIT_SPELLCAST_START_UNFILTERED(uId, _, spellId)
	if spellId == 274400 then
		local guid = UnitGUID(uId)
		self:ScheduleMethod(0.1, "BossTargetScanner", guid, "DashTarget", 0.1, 8)
		if self:AntiSpam(3, 2) then
			specWarnDuelistDash:Show()
			specWarnDuelistDash:Play("chargemove")
		end
	end
end

function mod:ENCOUNTER_START(eID)
	if eID == 2093 then--Skycap'n Kragg
		timerVileBombardmentCD:Stop()
	end
end
