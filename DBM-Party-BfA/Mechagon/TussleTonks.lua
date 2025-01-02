local mod	= DBM:NewMod(2336, "DBM-Party-BfA", 11, 1178)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(144244, 145185)
mod:SetEncounterID(2257)
mod:SetBossHPInfoToHighest()
mod:SetZone(2097)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 285020 283422 285388 1215065 1215102 1216431",
	"SPELL_CAST_SUCCESS 285344 285152",
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
(ability.id = 285020 or ability.id = 283422 or ability.id = 285388) and type = "begincast"
 or (ability.id = 285344 or ability.id = 285152) and type = "cast"
 --]]
 --Obsolete (pre 11.1)
local warnLayMine					= mod:NewCountAnnounce(285351, 2)

local specWarnVentJets				= mod:NewSpecialWarningDodge(285388, nil, nil, nil, 2, 2)
local specWarnWhirlingEdge			= mod:NewSpecialWarningDodge(285020, "Tank", nil, nil, 1, 2)

local timerVentJetsCD				= mod:NewCDTimer(40.1, 285388, nil, nil, nil, 2)
local timerLayMineCD				= mod:NewCDTimer(12.1, 285351, nil, nil, nil, 3)
local timerWhirlingEdgeCD			= mod:NewNextTimer(32.4, 285020, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
--General
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

local timerRP						= mod:NewRPTimer(68)
--The Platinum Pummeler
mod:AddTimerLine(DBM:EJ_GetSectionInfo(19237))
local warnPlating					= mod:NewFadesAnnounce(282801, 1)

local specWarnPlatinumPummel		= mod:NewSpecialWarningDodgeCount(1215065, nil, nil, nil, 1, 15)
local specWarnGroundPound			= mod:NewSpecialWarningCount(1215102, nil, nil, nil, 2, 2)

local timerPlatinumPummelCD			= mod:NewAITimer(12.1, 1215065, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerGroundPoundCD			= mod:NewAITimer(12.1, 1215102, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
--Gnomercy
mod:AddTimerLine(DBM:EJ_GetSectionInfo(19236))
local warnMaxThrust					= mod:NewTargetNoFilterAnnounce(283565, 2)
local warnFoeFlipper				= mod:NewTargetNoFilterAnnounce(285153, 2)

local specWarnMaxThrust				= mod:NewSpecialWarningYouCount(283565, nil, nil, nil, 1, 2)
local yellMaxThrust					= mod:NewYell(283565)
local specWarnBattleMine			= mod:NewSpecialWarningDodgeCount(1216431, nil, nil, nil, 2, 2)
local specWarnFoeFlipper			= mod:NewSpecialWarningYouCount(285153, nil, nil, nil, 1, 2)
local yellFoeFlipper				= mod:NewYell(285153)

local timerMaxThrustCD				= mod:NewCDTimer(45.8, 283565, nil, nil, nil, 3)
local timerBattlemineCD				= mod:NewAITimer(12.1, 1216431, nil, nil, nil, 3)
--local timerFoeFlipperCD				= mod:NewCDTimer(13.4, 285153, nil, nil, nil, 3)

local isNewShit = DBM:GetTOC() >= 110100

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

function mod:OnCombatStart(delay)
	self.vb.platinumPummelCount = 0
	self.vb.groundPoundCount = 0
	self.vb.trustCount = 0
	self.vb.mineCount = 0
	self.vb.foeCount = 0
	--timerMaxThrustCD:Start(3-delay)
	if not isNewShit then
		timerWhirlingEdgeCD:Start(8.2-delay)--No longer used in 11.1
		timerLayMineCD:Start(15.5-delay)----No longer used in 11.1
		timerVentJetsCD:Start(22.8-delay)--No longer used in 11.1?
	else
		timerPlatinumPummelCD:Start(1-delay)
		timerGroundPoundCD:Start(1-delay)
	end
	--timerFoeFlipperCD:Start(16.7-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 285020 then
		specWarnWhirlingEdge:Show()
		specWarnWhirlingEdge:Play("shockwave")
		timerWhirlingEdgeCD:Start()
	elseif spellId == 283422 then
		self.vb.trustCount = self.vb.trustCount + 1
		timerMaxThrustCD:Start()--self.vb.trustCount+1
		self:BossTargetScanner(args.sourceGUID, "ThrustTarget", 0.1, 7)
	elseif spellId == 285388 then
		specWarnVentJets:Show()
		specWarnVentJets:Play("watchstep")
		timerVentJetsCD:Start()
	elseif spellId == 1215065 then
		self.vb.platinumPummelCount = self.vb.platinumPummelCount + 1
		specWarnPlatinumPummel:Show(self.vb.platinumPummelCount)
		specWarnPlatinumPummel:Play("frontal")
		timerPlatinumPummelCD:Start()--nil, self.vb.platinumPummelCount+1
	elseif spellId == 1215102 then
		self.vb.groundPoundCount = self.vb.groundPoundCount + 1
		specWarnGroundPound:Show(self.vb.groundPoundCount)
		specWarnGroundPound:Play("aesoon")
		timerGroundPoundCD:Start()--nil, self.vb.groundPoundCount+1
	elseif spellId == 1216431 then
		self.vb.mineCount = self.vb.mineCount + 1
		specWarnBattleMine:Show(self.vb.mineCount)
		specWarnBattleMine:Play("watchstep")
		timerBattlemineCD:Start()--self.vb.mineCount+1
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 285344 then
		self.vb.mineCount = self.vb.mineCount + 1
		warnLayMine:Show(self.vb.mineCount)
		timerLayMineCD:Start(nil, self.vb.mineCount+1)
	elseif spellId == 285152 then
		self.vb.foeCount = self.vb.foeCount + 1
		if args:IsPlayer() then
			specWarnFoeFlipper:Show(self.vb.foeCount)
			specWarnFoeFlipper:Play("targetyou")
			yellFoeFlipper:Yell()
		else
			warnFoeFlipper:Show(args.destName)
		end
		--timerFoeFlipperCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 282801 then
		warnPlating:Show()
		timerWhirlingEdgeCD:Stop()
	end
end
--mod.SPELL_AURA_REMOVED_DOSE = mod.SPELL_AURA_REMOVED

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 144244 then--The Platinum Pummeler
		timerWhirlingEdgeCD:Stop()
		timerPlatinumPummelCD:Stop()
	elseif cid == 145185 then--Gnomercy 4.U.
		--timerFoeFlipperCD:Stop()
		timerVentJetsCD:Stop()
		timerMaxThrustCD:Stop()
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
