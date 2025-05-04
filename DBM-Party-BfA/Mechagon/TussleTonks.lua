local mod	= DBM:NewMod(2336, "DBM-Party-BfA", 11, 1178)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(144244, 145185)
mod:SetEncounterID(2257)
mod:SetHotfixNoticeRev(20250303000000)
mod:SetBossHPInfoToHighest()
mod:SetZone(2097)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 283422 1215065 1215102 1216431 282801 285152",
	"SPELL_CAST_SUCCESS 1216443 282801 1215194 1215102 1215065",
	"SPELL_AURA_REMOVED 282801",
--	"SPELL_AURA_REMOVED_DOSE 282801",
	"UNIT_DIED"
)

--TODO, Foe Flipper success target valid?
--TODO, thrust scan was changed to slower scan method, because UNIT_TARGET scan method relies on boss changing target after cast begins, but 8.3 notes now say boss changes target before cast starts
--TODO, the part two of above is need to verify whether or not a target scanner is even needed at all now. If boss is already looking at atarget at cast start then all we need is boss1target and no scan what so ever
--TODO, post 11.1, delete removed mechanics?
--TODO, can tank dodge pummel?
--TODO, target scan battle mine?
--[[
(ability.id = 282801 or ability.id = 283422 or ability.id = 1215065 or ability.id = 1215102 or ability.id = 1216431 or ability.id = 285152) and type = "begincast"
 or (ability.id = 282801 or ability.id = 1215194 or ability.id = 1215102 or ability.id = 1216443) and type = "cast"
 or ability.id = 282801 and type = "removebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --]]
--General
local warnElectricalStorm			= mod:NewSpellAnnounce(1216443, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerRP						= mod:NewRPTimer(68)
--The Platinum Pummeler
mod:AddTimerLine(DBM:EJ_GetSectionInfo(19237))
local warnPlatingCast				= mod:NewCastAnnounce(282801, 2)
local warnPlating					= mod:NewFadesAnnounce(282801, 1)

local specWarnPlatinumPummel		= mod:NewSpecialWarningDodgeCount(1215065, nil, nil, nil, 1, 15)
local specWarnGroundPound			= mod:NewSpecialWarningCount(1215102, nil, nil, nil, 2, 2)

local timerPlatinumPlatingCD		= mod:NewCDCountTimer(36.2, 282801, nil, nil, nil, 5)
local timerPlatinumPummelCD			= mod:NewVarCountTimer("v15.2-27.9", 1215065, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerGroundPoundCD			= mod:NewCDCountTimer(18.1, 1215102, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
--Gnomercy
mod:AddTimerLine(DBM:EJ_GetSectionInfo(19236))
local warnMaxThrust					= mod:NewTargetNoFilterAnnounce(283565, 2)
local warnFoeFlipper				= mod:NewTargetNoFilterAnnounce(285153, 2)

local specWarnMaxThrust				= mod:NewSpecialWarningYouCount(283565, nil, nil, nil, 1, 2)
local yellMaxThrust					= mod:NewYell(283565)
local specWarnBattleMine			= mod:NewSpecialWarningDodgeCount(1216431, nil, nil, nil, 2, 2)
local specWarnFoeFlipper			= mod:NewSpecialWarningYouCount(285153, nil, nil, nil, 1, 2)
local yellFoeFlipper				= mod:NewYell(285153)

local timerMaxThrustCD				= mod:NewCDCountTimer(35.2, 283565, nil, nil, nil, 3)
local timerBattlemineCD				= mod:NewCDCountTimer(17.0, 1216431, nil, nil, nil, 3)
local timerFoeFlipperCD				= mod:NewCDCountTimer(15.4, 285153, nil, nil, nil, 3)

mod.vb.platinumPlatingCastCount = 0
mod.vb.platinumPummelCount = 0
mod.vb.groundPoundCount = 0
mod.vb.trustCount = 0
mod.vb.mineCount = 0
mod.vb.foeCount = 0

function mod:ThrustTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnMaxThrust:Show(self.vb.trustCount)
		specWarnMaxThrust:Play("targetyou")
		yellMaxThrust:Yell()
	else
		warnMaxThrust:Show(targetname)
	end
end

function mod:FoeTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnFoeFlipper:Show(self.vb.foeCount)
		specWarnFoeFlipper:Play("targetyou")
		yellFoeFlipper:Yell()
	else
		warnFoeFlipper:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	self.vb.platinumPlatingCastCount = 0
	self.vb.platinumPummelCount = 0
	self.vb.groundPoundCount = 0
	self.vb.trustCount = 0
	self.vb.mineCount = 0
	self.vb.foeCount = 0
	timerFoeFlipperCD:Start(5.2-delay, 1)
	timerPlatinumPummelCD:Start(7-delay, 1)
	timerBattlemineCD:Start(12.1-delay, 1)
	timerGroundPoundCD:Start(13.1-delay, 1)
	timerMaxThrustCD:Start(35.2-delay, 1)
	timerPlatinumPlatingCD:Start(37.2-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 283422 then
		self.vb.trustCount = self.vb.trustCount + 1
		--"Maximum Thrust-283565-npc:145185-000032308F = pull:39.2, 35.2, 35.2, 35.2",
		timerMaxThrustCD:Start(self.vb.trustCount+1)
		self:BossTargetScanner(args.sourceGUID, "ThrustTarget", 0.1, 7)
	elseif spellId == 1215065 then
		specWarnPlatinumPummel:Show(self.vb.platinumPummelCount+1)
		specWarnPlatinumPummel:Play("frontal")
	elseif spellId == 1215102 then
		specWarnGroundPound:Show(self.vb.groundPoundCount+1)
		specWarnGroundPound:Play("aesoon")
	elseif spellId == 1216431 then
		self.vb.mineCount = self.vb.mineCount + 1
		specWarnBattleMine:Show(self.vb.mineCount)
		specWarnBattleMine:Play("watchstep")
		--"B.4.T.T.L.3. Mine-1216431-npc:145185-000032308F = pull:13.1, 17.0, 28.0, 35.2, 35.2, 35.2",
		if self.vb.mineCount == 1 then
			timerBattlemineCD:Start(17, 2)
		elseif self.vb.mineCount == 2 then
			timerBattlemineCD:Start(27.5, 3)
		else
			timerBattlemineCD:Start(35.2, self.vb.mineCount+1)
		end
	elseif spellId == 282801 then
		--Count and timer not here since cast can be interrupted and we only want to increment on successful cast
		warnPlatingCast:Show()
	elseif spellId == 285152 then
		self.vb.foeCount = self.vb.foeCount + 1
		self:BossTargetScanner(args.sourceGUID, "FoeTarget", 0.1, 8)
		--Might be worth using UnitTarget scanner instead based on below
		--"<167.34 19:37:12> [UNIT_SPELLCAST_START] Gnomercy 4.U.(99.2%-17.0%){Target:Relop} -Foe Flipper- 2.5s [[boss2:Cast-3-5770-2097-16037-285152-001CB23057:285152]]",
		--"<167.34 19:37:12> [CLEU] SPELL_CAST_START#Creature-0-5770-2097-16037-145185-000032303A#Gnomercy 4.U.(99.3%-17.0%)##nil#285152#Foe Flipper#nil#nil#nil#nil#nil#nil",
		--"<167.34 19:37:12> [UNIT_SPELLCAST_SUCCEEDED] Gnomercy 4.U.(99.2%-17.0%){Target:Relop} -Foe Flipper- [[boss2:Cast-3-5770-2097-16037-285150-001C323057:285150]]",
---->	--"<167.34 19:37:12> [UNIT_TARGET] boss2#Gnomercy 4.U.#Target: Shirumw#TargetOfTarget: Gnomercy 4.U.",
		--"<169.83 19:37:14> [UNIT_SPELLCAST_SUCCEEDED] Gnomercy 4.U.(97.4%-22.0%){Target:Shirumw} -Foe Flipper- [[boss2:Cast-3-5770-2097-16037-285152-001CB23057:285152]]",
		--"<169.83 19:37:14> [UNIT_SPELLCAST_STOP] Gnomercy 4.U.(97.4%-22.0%){Target:Shirumw} -Foe Flipper- [[boss2:Cast-3-5770-2097-16037-285152-001CB23057:285152]]",
		--"<169.83 19:37:14> [CLEU] SPELL_CAST_SUCCESS#Creature-0-5770-2097-16037-145185-000032303A#Gnomercy 4.U.(97.4%-22.0%)#Player-5764-0042C929#Shirumw#285152#Foe Flipper#nil#nil#nil#nil#nil#nil",
		--"Foe Flipper-285152-npc:145185-000032308F = pull:5.8, 15.8, 29.2, 15.8, 19.4, 15.8, 19.4, 15.8, 19.4, 15.8",
		if self.vb.foeCount == 2 then
			timerFoeFlipperCD:Start(28, 3)
		elseif self.vb.foeCount % 2 == 1 then
			timerFoeFlipperCD:Start(15.8, self.vb.foeCount+1)
		else
			timerFoeFlipperCD:Start(19.4, self.vb.foeCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 1216443 and self.vb.bossLeft == 1 then
		warnElectricalStorm:Show()
	elseif spellId == 282801 then
		self.vb.platinumPlatingCastCount = self.vb.platinumPlatingCastCount + 1
		--"Platinum Plating-282801-npc:144244-000032308F = pull:42.2, 42.5, 41.3",
		timerPlatinumPlatingCD:Start(35.2, self.vb.platinumPlatingCastCount+1)--36.2 - 1
	elseif spellId == 1215194 then--Stunnned
		--Add 5 seconds to timer when boss is stunned
		timerPlatinumPlatingCD:AddTime(5, self.vb.platinumPlatingCastCount+1)
		--Extend timers that come off CD during stun
		if timerGroundPoundCD:GetRemaining(self.vb.groundPoundCount+1) < 5.3 then
			local elapsed, total = timerGroundPoundCD:GetTime(self.vb.groundPoundCount+1)
			local extend = 5.3 - (total-elapsed)
			DBM:Debug("timerGroundPoundCD extended by: "..extend, 2)
			timerGroundPoundCD:Stop()
			timerGroundPoundCD:Update(elapsed, total+extend, self.vb.groundPoundCount+1)
		end
	elseif spellId == 1215102 then
		self.vb.groundPoundCount = self.vb.groundPoundCount + 1
		--"Ground Pound-1215102-npc:144244-000032308F = pull:13.1, 18.2, 25.5, 18.2, 20.6, 18.2, 21.9, 18.2",
		timerGroundPoundCD:Start(15.2, self.vb.groundPoundCount+1)--18.2-3
	elseif spellId == 1215065 then--can stutter cast, we only want to raise count and start timer on finished casts
		self.vb.platinumPummelCount = self.vb.platinumPummelCount + 1
		--"Platinum Pummel-1215065-npc:144244-00004A67A1 = pull:7.3, 15.8, 17.0, 21.8, 19.4, 17.0, 6.1, 15.8, 15.8, 23.1, 18.2, 27.9",
		timerPlatinumPummelCD:Start(12.8, self.vb.platinumPummelCount+1)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 282801 then
		warnPlating:Show()
	end
end
--mod.SPELL_AURA_REMOVED_DOSE = mod.SPELL_AURA_REMOVED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 144244 then--The Platinum Pummeler
		timerPlatinumPummelCD:Stop()
		timerGroundPoundCD:Stop()
		timerPlatinumPlatingCD:Stop()
	elseif cid == 145185 then--Gnomercy 4.U.
		timerFoeFlipperCD:Stop()
		timerMaxThrustCD:Stop()
		timerBattlemineCD:Stop()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	--"<745.04 00:25:22> [CHAT_MSG_MONSTER_YELL] Now this is a statistical anomaly! Our visitors are still alive!#Deuce Mecha-Buffer###Anshlun##0#0##0#2667#nil#0#false#false#false#false", -- [3780]
	--"<769.56 00:25:47> [ENCOUNTER_START] 2257#Tussle Tonks#23#5", -- [3807]
	if (msg == L.openingRP or msg:find(L.openingRP)) and self:LatencyCheck(1000) then
		self:SendSync("openingRP")
	end
end

function mod:OnSync(msg)
	if msg == "openingRP" and self:AntiSpam(10, 1) then
		timerRP:Start(24.5)
	end
end
