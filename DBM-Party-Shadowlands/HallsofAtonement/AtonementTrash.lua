local mod	= DBM:NewMod("AtonementTrash", "DBM-Party-Shadowlands", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2287)
mod:RegisterZoneCombat(2287)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 326409 326450 325523 325700 1235762 326441 338003 1237071 326997 1235326 1235766 326794 326847 1236614",
	"SPELL_CAST_SUCCESS 325876 326450 1237071 326997 1235326 325701 326638 326879",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 326450 326891 325876 1235762 1236614",
	"SPELL_AURA_REMOVED 325876 1236614",--326409
	"UNIT_DIED"
)

--[[
(ability.id = 341902) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 341902
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 174197) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 174197)
--]]
--TODO, anglebiters have a diff version of wicked bolt? can't really confirm it
--TODO, ideal warning for Dark Communion
--TODO, worth warning https://www.wowhead.com/ptr-2/spell=340446/mark-of-envy ?
local warnHurlGlaive					= mod:NewTargetNoFilterAnnounce(326638, 2)
local warnMortalStrike					= mod:NewCastAnnounce(1235766, 3, nil, nil, "Tank|Healer")
local warnDarkCommunion					= mod:NewSpellAnnounce(326794, 2)
local warnDisperseSins					= mod:NewSpellAnnounce(326847, 3)
local warnDisplayOfPower				= mod:NewSpellAnnounce(1236614, 2)--activation

local specWarnThrash					= mod:NewSpecialWarningSpell(326409, nil, nil, nil, 2, 2)
local specWarnSinQuake					= mod:NewSpecialWarningDodge(326441, nil, nil, nil, 2, 2)
local specWarnDeadlyThrust				= mod:NewSpecialWarningDodge(325523, "Tank", nil, nil, 1, 2)--Removed?
local specWarnPowerfulSwipe				= mod:NewSpecialWarningDodge(326997, nil, nil, nil, 2, 15)
local specWarnTurntoStone				= mod:NewSpecialWarningDodge(1235762, nil, nil, nil, 2, 2)
local specWarnDisplayOfPower			= mod:NewSpecialWarningMoveAway(1236614, nil, nil, nil, 1, 2)--spread alert toward the end of debuff
local specWarnMarkofObliteration		= mod:NewSpecialWarningMoveAway(325876, nil, nil, nil, 1, 2)--backup if no dispel
local yellMarkofObliterationFades		= mod:NewShortFadesYell(325876)
local specWarnStoneFist					= mod:NewSpecialWarningDefensive(1237071, nil, nil, nil, 2, 2)
local specWarnDisruptingScreech			= mod:NewSpecialWarningCast(1235326, "SpellCaster", nil, nil, 2, 2)
local specWarnLoyalBeastsInterrupt		= mod:NewSpecialWarningInterrupt(326450, "HasInterrupt", nil, nil, 1, 2)
local specWarnCollectSins				= mod:NewSpecialWarningInterrupt(325700, "HasInterrupt", nil, nil, 1, 2)
local specWarnSiphonLife				= mod:NewSpecialWarningInterrupt(325701, "HasInterrupt", nil, nil, 1, 2)
local specWarnWickedBolt				= mod:NewSpecialWarningInterrupt(338003, "HasInterrupt", nil, nil, 1, 2)--No CD, just spammed
local specWarnLoyalBeasts				= mod:NewSpecialWarningDispel(326450, "RemoveEnrage|Tank", nil, nil, 1, 2)--Target because it's hybrid warning
local specWarnTurnToStoneDispel			= mod:NewSpecialWarningDispel(1235762, "RemoveMagic", nil, nil, 2, 2)--326607 old version
local specWarnMarkofObliterationDispel	= mod:NewSpecialWarningDispel(325876, "RemoveMagic", nil, nil, 1, 2)

local timerMarkofObliterationCD			= mod:NewCDNPTimer(22.2, 325876, nil, nil, nil, 3)
local timerLoyalBeastsCD				= mod:NewCDNPTimer(23.7, 326450, nil, nil, nil, 4)
local timerStoneFistCD					= mod:NewCDPNPTimer(15.2, 1237071, nil, "Tank|Healer", nil, 5)--18.2 minus cast time
local timerPowerfulSwipeCD				= mod:NewCDPNPTimer(21.5, 326997, nil, nil, nil, 2)--23 minus cast time
local timerDisruptingScreechCD			= mod:NewCDPNPTimer(29.7, 1235326, nil, "SpellCaster", nil, 2)--32.7 minus cast time
local timerSiphonLifeCD					= mod:NewCDNPTimer(15.8, 325701, nil, nil, nil, 4)--15.8-21.8
local timerThrashCD						= mod:NewCDNPTimer(22.2, 326409, nil, nil, nil, 2)
local timerSinQuakeCD					= mod:NewCDNPTimer(23, 326441, nil, nil, nil, 3)--always 11 seconds after thrash (thrash is 10 sec + 1 sec)
local timerHurlGlaiveCD					= mod:NewCDNPTimer(16.7, 326638, nil, nil, nil, 3)--16.7-20.7
local timerMortalStrikeCD				= mod:NewCDNPTimer(14.2, 1235766, nil, "Tank|Healer", nil, 5)--14.6-21.9
local timerTurntoStoneCD				= mod:NewCDNPTimer(23.9, 1235762, nil, nil, nil, 3)
local timerAnkleBiterCD					= mod:NewCDNPTimer(10.1, 326879, nil, nil, nil, 5)--10.1-12.1
local timerDarkCommunionCD				= mod:NewCDNPTimer(31.6, 326794, nil, nil, nil, 1)
local timerDisperseSinsCD				= mod:NewCDNPTimer(10.9, 326847, nil, nil, nil, 3)--10.9-21.8
local timerDisplayOfPowerCD				= mod:NewCDNPTimer(32.8, 1236614, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 generalized

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 326409 then
		timerThrashCD:Start(nil, args.sourceGUID)
		timerSinQuakeCD:Start(11, args.sourceGUID)
		if self:AntiSpam(3, 4) then
			specWarnThrash:Show()
			specWarnThrash:Play("aesoon")
		end
	elseif spellId == 326450 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnLoyalBeastsInterrupt:Show(args.sourceName)
			specWarnLoyalBeastsInterrupt:Play("kickcast")
		end
	elseif spellId == 325523 and self:AntiSpam(3, 2) then
		specWarnDeadlyThrust:Show()
		specWarnDeadlyThrust:Play("shockwave")
	elseif spellId == 326441 and self:AntiSpam(3, 2) then
		specWarnSinQuake:Show()
		specWarnSinQuake:Play("watchstep")
	elseif spellId == 325700 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnCollectSins:Show(args.sourceName)
		specWarnCollectSins:Play("kickcast")
	elseif spellId == 338003 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnWickedBolt:Show(args.sourceName)
		specWarnWickedBolt:Play("kickcast")
	elseif spellId == 1235762 then
		timerTurntoStoneCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 2) then
			specWarnTurntoStone:Show()
			specWarnTurntoStone:Play("watchstep")
		end
	elseif spellId == 1237071 and self:IsTanking("player", nil, nil, true, args.sourceGUID) and self:AntiSpam(3, 5) then
		specWarnStoneFist:Show()
		specWarnStoneFist:Play("carefly")
	elseif spellId == 326997 then
		if self:AntiSpam(3, 2) then
			specWarnPowerfulSwipe:Show()
			specWarnPowerfulSwipe:Play("frontal")
		end
	elseif spellId == 1235326 and self:AntiSpam(3, 6) then
		specWarnDisruptingScreech:Show()
		specWarnDisruptingScreech:Play("stopcast")
	elseif spellId == 1235766 then
		timerMortalStrikeCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 5) then
			warnMortalStrike:Show()
		end
	elseif spellId == 326794 then
		timerDarkCommunionCD:Start(nil, args.sourceGUID)
		warnDarkCommunion:Show()
	elseif spellId == 326847 then
		warnDisperseSins:Show()
		timerDisperseSinsCD:Start(nil, args.sourceGUID)
	elseif spellId == 1236614 then
		warnDisplayOfPower:Show()
		timerDisplayOfPowerCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
	if not self:IsValidWarning(args.sourceGUID) then return end
	local spellId = args.spellId
	if spellId == 325876 then
		timerMarkofObliterationCD:Start(nil, args.sourceGUID)
	elseif spellId == 326450 then
		timerLoyalBeastsCD:Start(nil, args.sourceGUID)
	elseif spellId == 1237071 then
		timerStoneFistCD:Start(nil, args.sourceGUID)
	elseif spellId == 326997 then
		timerPowerfulSwipeCD:Start(nil, args.sourceGUID)
	elseif spellId == 1235326 then
		timerDisruptingScreechCD:Start(nil, args.sourceGUID)
	elseif spellId == 325701 then
		timerSiphonLifeCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnSiphonLife:Show(args.sourceName)
			specWarnSiphonLife:Play("kickcast")
		end
	elseif spellId == 326638 then
		timerHurlGlaiveCD:Start(nil, args.sourceGUID)
		if self:AntiSpam(3, 6) then
			warnHurlGlaive:Show(args.destName)
		end
	elseif spellId == 326879 then
		timerAnkleBiterCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 326450 then
		timerLoyalBeastsCD:Start(nil, args.destGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 326450 and self:AntiSpam(3, 3) then
		specWarnLoyalBeasts:Show(args.destName)
		specWarnLoyalBeasts:Play("enrage")
	elseif spellId == 325876 then
		if args:IsPlayer() then
			specWarnMarkofObliteration:Schedule(8)
			specWarnMarkofObliteration:ScheduleVoice(8, "runout")
			yellMarkofObliterationFades:Countdown(spellId, 4)
		end
		if self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnMarkofObliterationDispel:Show(args.destName)
			specWarnMarkofObliterationDispel:Play("dispelnow")
		end
	elseif spellId == 1235762 then
		if self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnTurnToStoneDispel:Show(args.destName)
			specWarnTurnToStoneDispel:Play("dispelnow")
		end
	elseif spellId == 1236614 and args:IsPlayer() then
		specWarnDisplayOfPower:Schedule(12)
		specWarnDisplayOfPower:ScheduleVoice(12, "scatter")
	end
end

--This is faster but in reality it's actually too fast. it results in almost 4-5 seconds before damage goes out.
--"<185.37 23:03:18> [CLEU] SPELL_AURA_REMOVED#Creature-0-2085-2287-9145-164557-000126FD07#Shard of Halkias#Creature-0-2085-2287-9145-164557-000126FD07#Shard of Halkias#326409#Thrash#BUFF#nil", -- [1273]
--"<186.29 23:03:19> [CLEU] SPELL_CAST_START#Creature-0-2085-2287-9145-164557-000126FD07#Shard of Halkias##nil#326441#Sin Quake#nil#nil", -- [1286]
function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 325876 then
		if args:IsPlayer() then
			specWarnMarkofObliteration:Cancel()
			specWarnMarkofObliteration:CancelVoice()
			yellMarkofObliterationFades:Cancel()
		end
	elseif spellId == 1236614 and args:IsPlayer() then
		specWarnDisplayOfPower:Cancel()
		specWarnDisplayOfPower:CancelVoice()
	--elseif spellId == 326409 then
	--	specWarnSinQuake:Show()
	--	specWarnSinQuake:Play("watchstep")
	end
end

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 165414 then--Depraved Obliterator
		timerMarkofObliterationCD:Stop(args.destGUID)
	elseif cid == 164562 then--Depraved Houndmaster
		timerLoyalBeastsCD:Stop(args.destGUID)
	elseif cid == 167607 then--Stoneborn Slasher
		timerStoneFistCD:Stop(args.destGUID)
		timerPowerfulSwipeCD:Stop(args.destGUID)
		timerDisruptingScreechCD:Stop(args.destGUID)
	elseif cid == 165529 then--Depraved Collector
		timerSiphonLifeCD:Stop(args.destGUID)
	elseif cid == 164557 then--Shard of Halkias
		timerThrashCD:Stop(args.destGUID)
		timerSinQuakeCD:Stop(args.destGUID)
	elseif cid == 167611 then--Stoneborn Eviscerator
		timerHurlGlaiveCD:Stop(args.destGUID)
	elseif cid == 167612 then--Stoneborn Reaver
		timerMortalStrikeCD:Stop(args.destGUID)
		timerTurntoStoneCD:Stop(args.destGUID)
	elseif cid == 167610 then--Stonefiend Anklebiter
		timerAnkleBiterCD:Stop(args.destGUID)
	elseif cid == 167876 then--Inquisitor Sigar
		timerDarkCommunionCD:Stop(args.destGUID)
		timerDisperseSinsCD:Stop(args.destGUID)
		timerDisplayOfPowerCD:Stop(args.destGUID)
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
--Most timers need adjustment, had bad logs
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 165414 then--Depraved Obliterator
		timerMarkofObliterationCD:Start(6.6-delay, guid)--6.6-10
	elseif cid == 164562 then--Depraved Houndmaster
		timerLoyalBeastsCD:Start(15-delay, guid)--Can be as early as 2.5, but is almost always massively delayed so gonna use delayed timer here
	elseif cid == 167607 then--Stoneborn Slasher
		timerStoneFistCD:Start(5-delay, guid)--Iffy
		timerPowerfulSwipeCD:Start(10-delay, guid)--Iffy
		timerDisruptingScreechCD:Start(15.8-delay, guid)--Iffy
	elseif cid == 165529 then--Depraved Collector
		timerSiphonLifeCD:Start(2.4-delay, guid)
	elseif cid == 164557 then--Shard of Halkias
		timerThrashCD:Start(6-delay, guid)
		--No need to start Sin Quake here, it'll be started by Thrash
	elseif cid == 167611 then--Stoneborn Eviscerator
		timerHurlGlaiveCD:Start(4.4-delay, guid)
	elseif cid == 167612 then--Stoneborn Reaver
		timerMortalStrikeCD:Start(4.5-delay, guid)
		timerTurntoStoneCD:Start(20.2-delay, guid)
	elseif cid == 167610 then--Stonefiend Anklebiter
		timerAnkleBiterCD:Start(2-delay, guid)
	elseif cid == 167876 then--Inquisitor Sigar
		timerDarkCommunionCD:Start(4.9-delay, guid)
		timerDisperseSinsCD:Start(10.5-delay, guid)--Iffy
		timerDisplayOfPowerCD:Start(15.6-delay, guid)
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
