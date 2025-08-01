local mod	= DBM:NewMod("AtonementTrash", "DBM-Party-Shadowlands", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(2287)
mod:RegisterZoneCombat(2287)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 326409 326450 325523 325700 326607 326441 338003 1237071 326997 1235326 1235766",
	"SPELL_CAST_SUCCESS 325876 326450 1237071 326997 1235326 325701 326638",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 326450 326891 325876",
	"SPELL_AURA_REMOVED 325876",--326409
	"UNIT_DIED"
)

--[[
(ability.id = 341902) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 341902
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 174197) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 174197)
--]]
local warnHurlGlaive					= mod:NewTargetNoFilterAnnounce(326638, 2)
local warnMortalStrike					= mod:NewCastAnnounce(1235766, 3, nil, nil, "Tank|Healer")

local specWarnThrash					= mod:NewSpecialWarningSpell(326409, nil, nil, nil, 2, 2)
local specWarnSinQuake					= mod:NewSpecialWarningDodge(326441, nil, nil, nil, 2, 2)
local specWarnDeadlyThrust				= mod:NewSpecialWarningDodge(325523, "Tank", nil, nil, 1, 2)
local specWarnTurnToStoneOther			= mod:NewSpecialWarningDodge(326607, nil, nil, nil, 2, 2)
local specWarnPowerfulSwipe				= mod:NewSpecialWarningDodge(326997, nil, nil, nil, 2, 15)
local specWarnMarkofObliteration		= mod:NewSpecialWarningMoveAway(325876, nil, nil, nil, 1, 2)--backup if no dispel
local yellMarkofObliterationFades		= mod:NewShortFadesYell(325876)
local specWarnStoneFist					= mod:NewSpecialWarningDefensive(1237071, nil, nil, nil, 2, 2)
local specWarnDisruptingScreech			= mod:NewSpecialWarningCast(1235326, "SpellCaster", nil, nil, 2, 2)
local specWarnLoyalBeasts				= mod:NewSpecialWarningDispel(326450, "RemoveEnrage|Tank", nil, nil, 1, 2)--Target because it's hybrid warning
local specWarnLoyalBeastsInterrupt		= mod:NewSpecialWarningInterrupt(326450, "HasInterrupt", nil, nil, 1, 2)
local specWarnCollectSins				= mod:NewSpecialWarningInterrupt(325700, "HasInterrupt", nil, nil, 1, 2)
local specWarnSiphonLife				= mod:NewSpecialWarningInterrupt(325701, "HasInterrupt", nil, nil, 1, 2)
local specWarnTurntoStone				= mod:NewSpecialWarningInterrupt(326607, "HasInterrupt", nil, nil, 1, 2)
local specWarnWickedBolt				= mod:NewSpecialWarningInterrupt(338003, "HasInterrupt", nil, nil, 1, 2)--No CD, just spammed
local specWarnMarkofObliterationDispel	= mod:NewSpecialWarningDispel(325876, "RemoveMagic", nil, nil, 1, 2)

local timerMarkofObliterationCD			= mod:NewCDNPTimer(23, 325876, nil, nil, nil, 3)
local timerLoyalBeastsCD				= mod:NewCDNPTimer(23.7, 326450, nil, nil, nil, 4)
local timerStoneFistCD					= mod:NewCDPNPTimer(15.2, 1237071, nil, "Tank|Healer", nil, 5)--18.2 minus cast time
local timerPowerfulSwipeCD				= mod:NewCDPNPTimer(21.5, 326997, nil, nil, nil, 2)--23 minus cast time
local timerDisruptingScreechCD			= mod:NewCDPNPTimer(29.7, 1235326, nil, "SpellCaster", nil, 2)--32.7 minus cast time
local timerSiphonLifeCD					= mod:NewCDNPTimer(17, 325701, nil, nil, nil, 4)--17-21.8
local timerThrashCD						= mod:NewCDNPTimer(23, 326409, nil, nil, nil, 2)
local timerSinQuakeCD					= mod:NewCDNPTimer(23, 326441, nil, nil, nil, 3)--always 11 seconds after thrash (thrash is 10 sec + 1 sec)
local timerHurlGlaiveCD					= mod:NewCDNPTimer(17, 326638, nil, nil, nil, 3)--17-20.7
local timerMortalStrikeCD				= mod:NewCDNPTimer(14.6, 1235766, nil, "Tank|Healer", nil, 5)--14.6-21.9

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 generalized

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
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
	elseif spellId == 326607 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTurntoStone:Show(args.sourceName)
			specWarnTurntoStone:Play("kickcast")
		elseif self:AntiSpam(3, 2) then
			specWarnTurnToStoneOther:Show()
			specWarnTurnToStoneOther:Play("watchstep")
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
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if not self.Options.Enabled then return end
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
			yellMarkofObliterationFades:Countdown(spellId)
		end
		if self:CheckDispelFilter("magic") and self:AntiSpam(3, 3) then
			specWarnMarkofObliterationDispel:Show(args.destName)
			specWarnMarkofObliterationDispel:Play("dispelnow")
		end
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
	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
--Most timers need adjustment, had bad logs
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 165414 then--Depraved Obliterator
		timerMarkofObliterationCD:Start(10-delay, guid)--Iffy
	elseif cid == 164562 then--Depraved Houndmaster
		timerLoyalBeastsCD:Start(14.2-delay, guid)--Iffy
	elseif cid == 167607 then--Stoneborn Slasher
		timerStoneFistCD:Start(5-delay, guid)--Iffy
		timerPowerfulSwipeCD:Start(10-delay, guid)--Iffy
		timerDisruptingScreechCD:Start(15.8-delay, guid)--Iffy
	elseif cid == 165529 then--Depraved Collector
		timerSiphonLifeCD:Start(3-delay, guid)--Iffy
	elseif cid == 164557 then--Shard of Halkias
		timerThrashCD:Start(7-delay, guid)--Iffy
		--No need to start Sin Quake here, it'll be started by Thrash
	elseif cid == 167611 then--Stoneborn Eviscerator
		timerHurlGlaiveCD:Start(7.5-delay, guid)--Iffy
	elseif cid == 167612 then--Stoneborn Reaver
		timerMortalStrikeCD:Start(4.8-delay, guid)--Iffy
	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
