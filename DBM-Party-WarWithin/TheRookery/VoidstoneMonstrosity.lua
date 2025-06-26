local mod	= DBM:NewMod(2568, "DBM-Party-WarWithin", 3, 1268)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207207)
mod:SetEncounterID(2836)
mod:SetHotfixNoticeRev(20250303000000)
mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2648)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 423305 429487 445457 424371",
	"SPELL_CAST_SUCCESS 458082 423839 423305",
	"SPELL_AURA_APPLIED 445262 428269 429028 429493 458082",
	"SPELL_AURA_REMOVED 445262 428269 423839 458082",
	"SPELL_PERIODIC_DAMAGE 433067",
	"SPELL_PERIODIC_MISSED 433067"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, is infoframe on absorb overkill?
--TODO, reshape still need announcing with nameplat auras? don't want to introduce spam
--TODO, can the tank sidestep Oblivion Wave?
--TODO, update timers for 10 second stun on boss?
--TODO, add https://www.wowhead.com/spell=423393/entropy ?
--TODO, add auto marking of stormriders charge?
--TODO, verify timer pausing/resuming is correct
--[[
(ability.id = 423305 or ability.id = 429487 or ability.id = 445457 or ability.id = 424371) and type = "begincast"
 or ability.id = 181089 and type = "cast"
 or ability.id = 445262 and (type = "applybuff" or type = "removebuff")
 or ability.id = 423839
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnVoidShell						= mod:NewTargetNoFilterAnnounce(445262, 3)
local warnVoidShellFaded				= mod:NewFadesAnnounce(445262, 1)
local warnCorruptionPulse				= mod:NewTargetNoFilterAnnounce(429028, 4)
local warnUnleashedCorruption			= mod:NewTargetAnnounce(429487, 3)
local warnStormsVengeance				= mod:NewCountAnnounce(424371, 1)
local warnStormridersCharge				= mod:NewTargetNoFilterAnnounce(458082, 3)

local specWarnNullUpheaval				= mod:NewSpecialWarningDodgeCount(423305, nil, nil, nil, 1, 2)
--local yellSomeAbility					= mod:NewYell(372107)
local specWarnOblivionWave				= mod:NewSpecialWarningDefensive(423305, nil, nil, nil, 1, 2)
local specWarnUnleashedCorruption		= mod:NewSpecialWarningMoveAway(429493, nil, nil, nil, 1, 2)
local yellUnleashedCorruption			= mod:NewShortYell(429493)
local specWarnStormridersCharge			= mod:NewSpecialWarningYou(458082, nil, nil, nil, 1, 2)
local yellStormridersCharge				= mod:NewShortYell(458082)
local yellStormridersChargeFades		= mod:NewShortFadesYell(458082)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(433067, nil, nil, nil, 1, 8)

local timerNullUpheavalCD				= mod:NewVarCountTimer("v29.8-40.8", 423305, nil, nil, nil, 3)
local timerUnleashedCorruptionCD		= mod:NewVarCountTimer("v17.0-26.3", 429487, nil, nil, nil, 3)
local timerOblivionWaveCD				= mod:NewVarCountTimer("v13.4-21.2", 445457, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerStormridersChargeCD			= mod:NewVarCountTimer("v32.8-41.9", 458082, nil, nil, nil, 3)
local timerVengeanceActive				= mod:NewBuffActiveTimer(20, 423839, nil, nil, nil, 6)

mod:AddInfoFrameOption(445262)
mod:AddNamePlateOption("NameplateOnReshape", 428269)

mod.vb.NullUpheavalCount = 0
mod.vb.unleashedCount = 0
mod.vb.oblivionCount = 0
mod.vb.vengeanceCount = 0
mod.vb.riderCount = 0

function mod:OnCombatStart(delay)
	self.vb.NullUpheavalCount = 0
	self.vb.unleashedCount = 0
	self.vb.oblivionCount = 0
	self.vb.vengeanceCount = 0
	self.vb.riderCount = 0
	timerOblivionWaveCD:Start(5.2, 1)
	timerUnleashedCorruptionCD:Start(10.1, 1)
	timerNullUpheavalCD:Start(16.7, 1)
	timerStormridersChargeCD:Start(19.1, 1)
	if self.Options.NameplateOnReshape then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
	if self.Options.NameplateOnReshape then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 423305 then
		specWarnNullUpheaval:Show(self.vb.NullUpheavalCount+1)
		specWarnNullUpheaval:Play("watchstep")
	elseif spellId == 429487 then
		self.vb.unleashedCount = self.vb.unleashedCount + 1
		timerUnleashedCorruptionCD:Start(nil, self.vb.unleashedCount+1)
	elseif spellId == 445457 then
		self.vb.oblivionCount = self.vb.oblivionCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnOblivionWave:Show()
			specWarnOblivionWave:Play("defensive")
		end
		timerOblivionWaveCD:Start(nil, self.vb.oblivionCount+1)
	elseif spellId == 424371 then
		self.vb.vengeanceCount = self.vb.vengeanceCount + 1
		warnStormsVengeance:Show(self.vb.vengeanceCount)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 458082 and self:AntiSpam(3, 1) then
		self.vb.riderCount = self.vb.riderCount + 1
		timerStormridersChargeCD:Start(nil, self.vb.riderCount+1)
	elseif spellId == 423305 then
		--Only increment count and start timer if cast finishes, because cast can be interrupted by storms vengeance (and then boss retains full energy and doesn't go on CD)
		self.vb.NullUpheavalCount = self.vb.NullUpheavalCount + 1
		timerNullUpheavalCD:Start(nil, self.vb.NullUpheavalCount+1)
	elseif spellId == 423839 then
		timerVengeanceActive:Start()
		--Pause timers
		timerNullUpheavalCD:Pause(self.vb.NullUpheavalCount+1)
		timerUnleashedCorruptionCD:Pause(self.vb.unleashedCount+1)
		timerOblivionWaveCD:Pause(self.vb.oblivionCount+1)
		timerStormridersChargeCD:Pause(self.vb.riderCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 445262 then
		warnVoidShell:Show(args.destName)
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	elseif spellId == 428269 then
		if self.Options.NameplateOnReshape then
			DBM.Nameplate:Show(true, args.destGUID, spellId, nil, 15)
		end
	elseif spellId == 429028 and self:AntiSpam(3, 2) then
		warnCorruptionPulse:Show(args.destName)
	elseif spellId == 429493 then
		warnUnleashedCorruption:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnUnleashedCorruption:Show()
			specWarnUnleashedCorruption:Play("runout")
			yellUnleashedCorruption:Yell()
		end
	elseif spellId == 458082 then
		warnStormridersCharge:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnStormridersCharge:Show()
			specWarnStormridersCharge:Play("targetyou")
			yellStormridersCharge:Yell()
			yellStormridersChargeFades:Countdown(spellId)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 445262 then
		warnVoidShellFaded:Show()
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	elseif spellId == 428269 then
		if self.Options.NameplateOnReshape then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	elseif spellId == 423839 then
		timerVengeanceActive:Stop()
		--Resume timers
		--In addition, they're all extended by about 4 sec
		timerNullUpheavalCD:Resume(self.vb.NullUpheavalCount+1)
		timerUnleashedCorruptionCD:Resume(self.vb.unleashedCount+1)
		timerOblivionWaveCD:Resume(self.vb.oblivionCount+1)
		timerStormridersChargeCD:Resume(self.vb.riderCount+1)
		--Not sure what addtime will do to a variance timer, especially one in the neg at time of pause.
		--timerNullUpheavalCD:AddTime(3.8, self.vb.NullUpheavalCount+1)
		--timerUnleashedCorruptionCD:AddTime(3.8, self.vb.unleashedCount+1)
		--timerOblivionWaveCD:AddTime(3.8, self.vb.oblivionCount+1)
		--timerStormridersChargeCD:AddTime(3.8, self.vb.riderCount+1)
	elseif spellId == 458082 and args:IsPlayer() then
		yellStormridersChargeFades:Cancel()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 433067 and destGUID == UnitGUID("player") and self:AntiSpam(3, 3) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
