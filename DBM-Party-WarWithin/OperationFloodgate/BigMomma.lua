local mod	= DBM:NewMod(2648, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226398)
mod:SetEncounterID(3020)
mod:SetUsedIcons(8, 7, 6, 5)
mod:SetHotfixNoticeRev(20250215000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 460156 471585 472452 460075 1214780 473351 473220 469981",
--	"SPELL_CAST_SUCCESS",
	"SPELL_SUMMON 471595",
	"SPELL_AURA_APPLIED 473354 469981",
	"SPELL_AURA_REMOVED 460156 469981",
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, finetune scoping of interrupt on whether or not cooldown should be checked
--TODO, add interrupt nameplate timer if it actually has a cooldown (and not spam cast)
--TODO, add custom audio for sonic boom that says "get behind objectname"
--TODO, see if timers reset on jump start or if they just continue
--[[
(ability.id = 460156 or ability.id = 471585 or ability.id = 460075 or ability.id = 473351 or ability.id = 473220 or ability.id = 469981) and type = "begincast"
 or ability.id = 460156 and type = "removebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnJumpStart							= mod:NewCountAnnounce(460156, 1)
local warnJumpStartOver						= mod:NewEndAnnounce(460156, 2)
local warnDoomStorm							= mod:NewTargetNoFilterAnnounce(472452, 2)
local warnSonicBoom							= mod:NewTargetNoFilterAnnounce(473220, 2)

local specWarnMobilizeMechadrones			= mod:NewSpecialWarningSwitchCount(471585, "-Healer", nil, nil, 1, 2)
local specWarnDoomStorm						= mod:NewSpecialWarningMoveAway(472452, nil, nil, nil, 1, 2)
local yellDoomStorm							= mod:NewShortYell(472452)
local specWarnMaximumDistortion				= mod:NewSpecialWarningInterruptCount(1214780, "HasInterrupt", nil, nil, 1, 2, 4)
local specWarnElectrocrush					= mod:NewSpecialWarningDefensive(473351, "Tank", nil, nil, 1, 2)
local specWarnSonicBoom						= mod:NewSpecialWarningMoveAway(473220, nil, nil, nil, 1, 2)
local yellSonicBoom							= mod:NewShortYell(473220)
local specWarnbarrier						= mod:NewSpecialWarningCount(469981, nil, nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerMobilizeMechadronesCD			= mod:NewNextCountTimer(33.9, 471585, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
--local timerDoomStormCD					= mod:NewCDNPTimer(33.9, 472452, nil, nil, nil, 3)
local timerElectrocrushCD					= mod:NewVarCountTimer("v20.6-21.8", 473351, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSonicBoomCD						= mod:NewNextCountTimer(21.8, 473220, nil, nil, nil, 3)
local timerBarrierCD						= mod:NewNextCountTimer(33.9, 469981, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)

mod:AddInfoFrameOption(469981, true)
mod:AddSetIconOption("SetIconOnMechs", 471585, true, 5, {8, 7, 6, 5})

mod.vb.addIcon = 8
mod.vb.jumpStartCount = 0
mod.vb.mechCount = 0
mod.vb.electroCount = 0
mod.vb.sonicCount = 0
mod.vb.barrierCount = 0
local castsPerGUID = {}

function mod:DoomStormTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnDoomStorm:Show()
		yellDoomStorm:Yell()
	else
		warnDoomStorm:Show(targetname)
	end
end

function mod:SonicBoomTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnSonicBoom:Show()
		specWarnSonicBoom:Play("runout")
		yellSonicBoom:Yell()
	else
		warnSonicBoom:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	table.wipe(castsPerGUID)
	self.vb.jumpStartCount = 0
	self.vb.mechCount = 0
	self.vb.electroCount = 0
	self.vb.sonicCount = 0
	self.vb.barrierCount = 0
	timerElectrocrushCD:Start(6-delay, 1)
	timerSonicBoomCD:Start(15.4-delay, 1)
	timerBarrierCD:Start(51-delay, 1)
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 460156 then
		self.vb.jumpStartCount = self.vb.jumpStartCount + 1
		warnJumpStart:Show(self.vb.jumpStartCount)
		--Stop Timers
		timerMobilizeMechadronesCD:Start(15.1, self.vb.mechCount+1)
		timerElectrocrushCD:Stop()
		timerSonicBoomCD:Stop()
		timerBarrierCD:Stop()
	elseif spellId == 471585 then
		self.vb.mechCount = self.vb.mechCount + 1
		self.vb.addIcon = 8
		specWarnMobilizeMechadrones:Show(self.vb.mechCount)
		specWarnMobilizeMechadrones:Play("killbigmob")
	elseif spellId == 472452 or spellId == 460075 then--472452 confirmed on follower, 460075 unknown
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "DoomStormTarget", 0.1, 8, true)
	elseif spellId == 1214780 then
		if not castsPerGUID[args.sourceGUID] then
			castsPerGUID[args.sourceGUID] = 0
		end
		castsPerGUID[args.sourceGUID] = castsPerGUID[args.sourceGUID] + 1
		local count = castsPerGUID[args.sourceGUID]
		if self:CheckInterruptFilter(args.sourceGUID, false, false) then
			specWarnMaximumDistortion:Show(args.sourceName, count)
			if count == 1 then
				specWarnMaximumDistortion:Play("kick1r")
			elseif count == 2 then
				specWarnMaximumDistortion:Play("kick2r")
			elseif count == 3 then
				specWarnMaximumDistortion:Play("kick3r")
			elseif count == 4 then
				specWarnMaximumDistortion:Play("kick4r")
			elseif count == 5 then
				specWarnMaximumDistortion:Play("kick5r")
			else
				specWarnMaximumDistortion:Play("kickcast")
			end
		end
	elseif spellId == 473351 then
		self.vb.electroCount = self.vb.electroCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnElectrocrush:Show()
			specWarnElectrocrush:Play("defensive")
		end
		timerElectrocrushCD:Start()
	elseif spellId == 473220 then
		self.vb.sonicCount = self.vb.sonicCount + 1
		timerSonicBoomCD:Start()
		self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "SonicBoomTarget", 0.1, 8, true)
	elseif spellId == 469981 then
		self.vb.barrierCount = self.vb.barrierCount + 1
		specWarnbarrier:Show(self.vb.barrierCount)
		specWarnbarrier:Play("killmob")
	end
end


--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 433740 then

	end
end
--]]

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 471595 then
		if self.Options.SetIconOnMechs then
			self:ScanForMobs(args.destGUID, 2, self.vb.addIcon, 1, nil, 12, "SetIconOnMechs")
		end
		self.vb.addIcon = self.vb.addIcon - 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 469981 then
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, UnitGetTotalAbsorbs("boss1"))
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED


function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 460156 then
		warnJumpStartOver:Show()
		--restart Timers
		timerElectrocrushCD:Start(9.2, self.vb.electroCount+1)
		timerSonicBoomCD:Start(18.9, self.vb.sonicCount+1)
		timerBarrierCD:Start(60.4, self.vb.barrierCount+1)
	elseif spellId == 469981 then
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end


--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 228424 then--Mobilize Mechadrones
		--timerDoomStormCD:Stop(args.destGUID)
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
