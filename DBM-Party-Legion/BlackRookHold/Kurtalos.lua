local mod	= DBM:NewMod(1672, "DBM-Party-Legion", 1, 740)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(98965, 98970)
mod:SetEncounterID(1835)
mod:SetHotfixNoticeRev(20231027000000)
mod:SetMinSyncRevision(20231027000000)
mod.respawnTime = 29
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 198820 199143 199193 202019 198641 201733",
	"SPELL_CAST_SUCCESS 198635 198641",
	"SPELL_AURA_APPLIED 201733",
	"SPELL_AURA_REMOVED 199193",
	"UNIT_DIED"
)

--TODO, figure out swarm warnings, how many need to switch and kill?
--TODO, boss guids for nameplate aura timers, i'm feeling lazy about this right now cause it'd require scanning at different timings
--[[
(ability.id = 198820 or ability.id = 199143 or ability.id = 199193 or ability.id = 202019 or ability.id = 198641 or ability.id = 201733) and type = "begincast"
 or ability.id = 198635 and type = "cast"
 or ability.id = 199193 and type = "removebuff"
 or target.id = 98965 and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Stage One: Lord of the Keep
mod:AddTimerLine(DBM:EJ_GetSectionInfo(12502))
local warnWhirlingBlade				= mod:NewCountAnnounce(198641, 2)

local specWarnDarkblast				= mod:NewSpecialWarningDodgeCount(198820, nil, nil, nil, 2, 2)

local timerDarkBlastCD				= mod:NewCDCountTimer(18.1, 198820, nil, nil, nil, 3)
local timerWhirlingBladeCD			= mod:NewCDCountTimer(23, 198641, nil, nil, nil, 3)
local timerUnerringShearCD			= mod:NewCDCountTimer(12.1, 198635, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON, nil, mod:IsTank() and 2 or nil, 4)
--Stage Two: Vengeance of the Ancients
mod:AddTimerLine(DBM:EJ_GetSectionInfo(12509))
local warnCloud						= mod:NewCountAnnounce(199143, 2)
local warnSwarm						= mod:NewTargetNoFilterAnnounce(201733, 2)

local specWarnGuile					= mod:NewSpecialWarningDodgeCount(199193, nil, nil, nil, 2, 2)
local specWarnGuileEnded			= mod:NewSpecialWarningEnd(199193, nil, nil, nil, 1, 2)
local specWarnSwarm					= mod:NewSpecialWarningYou(201733, nil, nil, nil, 1, 2)
local specWarnShadowBoltVolley		= mod:NewSpecialWarningSpell(202019, nil, nil, nil, 2, 2)

local timerGuileCD					= mod:NewCDCountTimer(39, 199193, nil, nil, nil, 6)
local timerGuile					= mod:NewBuffFadesTimer(20, 199193, nil, nil, nil, 6)
local timerCloudCD					= mod:NewCDCountTimer(32.7, 199143, nil, nil, nil, 3)
local timerSwarmCD					= mod:NewCDCountTimer(17, 201733, nil, nil, nil, 3)--17-21
local timerShadowBoltVolleyCD		= mod:NewCDCountTimer(9.7, 202019, nil, nil, nil, 2)

--Stage 1
mod.vb.bladeCount = 0
mod.vb.blastCount = 0
mod.vb.shearCount = 0
--Stage 2
mod.vb.shadowboltCount = 0
mod.vb.guileCount = 0
mod.vb.cloudCount = 0
mod.vb.swarmCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	--Stage 1
	self.vb.bladeCount = 0
	self.vb.blastCount = 0
	self.vb.shearCount = 0
	--Stage 2
	self.vb.shadowboltCount = 0
	self.vb.guileCount = 0
	self.vb.cloudCount = 0
	self.vb.swarmCount = 0
	timerUnerringShearCD:Start(5.5-delay, 1)
	timerWhirlingBladeCD:Start(10-delay, 1)--Either whirling or dark can come first, other will be immediately after
	timerDarkBlastCD:Start(10-delay, 1)--Either whirling or dark can come first, other will be immediately after
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 198820 then
		self.vb.blastCount = self.vb.blastCount + 1
		if self:GetStage(1) then
			specWarnDarkblast:Show(self.vb.blastCount)
			specWarnDarkblast:Play("watchstep")
			timerDarkBlastCD:Start(nil, self.vb.blastCount+1)
		end
	elseif spellId == 199143 then
		self.vb.cloudCount = self.vb.cloudCount + 1
		warnCloud:Show(self.vb.cloudCount)
		timerCloudCD:Start(nil, self.vb.cloudCount+1)
	elseif spellId == 199193 then
		--Seems to pause and resume timers but with an extra 3 secondcs
		--As such, just adding 23 is cleaner than actually doing the pause + 3 seconds
		timerCloudCD:AddTime(23, self.vb.cloudCount+1)
		timerSwarmCD:AddTime(23, self.vb.swarmCount+1)
		timerShadowBoltVolleyCD:AddTime(23, self.vb.shadowboltCount+1)
		self.vb.guileCount = self.vb.guileCount + 1
		specWarnGuile:Show(self.vb.guileCount)
		specWarnGuile:Play("watchstep")
		specWarnGuile:ScheduleVoice(1.5, "keepmove")
		timerGuile:Start()
	elseif spellId == 202019 then
		self.vb.shadowboltCount = self.vb.shadowboltCount + 1
		if self.vb.shadowboltCount == 1 then
			specWarnShadowBoltVolley:Show()
			specWarnShadowBoltVolley:Play("aesoon")
		end
		timerShadowBoltVolleyCD:Start(nil, self.vb.shadowboltCount+1)
	elseif spellId == 198641 then
		warnWhirlingBlade:Show(self.vb.bladeCount+1)
	elseif spellId == 201733 then
		self.vb.swarmCount = self.vb.swarmCount + 1
		timerSwarmCD:Start(nil, self.vb.swarmCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 198635 then
		self.vb.shearCount = self.vb.shearCount + 1
		timerUnerringShearCD:Start(nil, self.vb.shearCount+1)
	elseif spellId == 198641 then
		self.vb.bladeCount = self.vb.bladeCount + 1
		timerWhirlingBladeCD:Start(20.5, self.vb.bladeCount+1)--23 - 2.5
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 201733 then
		if args:IsPlayer() then
			specWarnSwarm:Show()
			specWarnSwarm:Play("targetyou")
		else
			warnSwarm:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 199193 then
		specWarnGuileEnded:Show()
		specWarnGuileEnded:Play("safenow")
		timerGuileCD:Start(63.8, self.vb.guileCount+1)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 98965 then--Kur'talos Ravencrest
		self:SetStage(2)
		timerDarkBlastCD:Stop()
		timerUnerringShearCD:Stop()
		timerWhirlingBladeCD:Stop()
		timerShadowBoltVolleyCD:Start(17.5, 1)
		if not self:IsNormal() then
			timerSwarmCD:Start(22.3, 1)
		end
		timerCloudCD:Start(27.2, 1)
		timerGuileCD:Start(38.1, 1)
	end
end
