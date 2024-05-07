local mod	= DBM:NewMod(2568, "DBM-Party-WarWithin", 3, 1268)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207207)
mod:SetEncounterID(2836)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 423305 429487 445457 424371",
--	"SPELL_CAST_SUCCESS 181089",
	"SPELL_AURA_APPLIED 445262 428269 429028 423839",
	"SPELL_AURA_REMOVED 445262 428269 423839",
	"SPELL_PERIODIC_DAMAGE 433067",
	"SPELL_PERIODIC_MISSED 433067"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, is infoframe on absorb overkill?
--TODO, reshape still need announcing with nameplat auras? don't want to introduce spam
--TODO, can the tank sidestep Oblivion Wave?
--TODO, update timers for 10 second stun on boss?
--NOTE, Really long pulls will be needed to fix this boss
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
local warnUnleashedCorruption			= mod:NewCountAnnounce(429487, 3)
local warnStormsVengeance				= mod:NewCountAnnounce(424371, 1)

local specWarnLatentVoid				= mod:NewSpecialWarningDodgeCount(423305, nil, nil, nil, 1, 2)
--local yellSomeAbility						= mod:NewYell(372107)
local specWarnOblivionWave				= mod:NewSpecialWarningDefensive(423305, nil, nil, nil, 1, 2)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(433067, nil, nil, nil, 1, 8)

local timerLatentVoidCD					= mod:NewAITimer(33.9, 423305, nil, nil, nil, 3)
local timerUnleashedCorruptionCD		= mod:NewAITimer(33.9, 429487, nil, nil, nil, 3)
local timerOblivionWaveCD				= mod:NewAITimer(10.7, 445457, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerElectrocuted					= mod:NewBuffActiveTimer(33.9, 423839, nil, nil, nil, 5)

mod:AddInfoFrameOption(445262)
mod:AddNamePlateOption("NameplateOnReshape", 428269)

mod.vb.latentVoidCount = 0
mod.vb.unleashedCount = 0
mod.vb.oblivionCount = 0
mod.vb.vengeanceCount = 0

function mod:OnCombatStart(delay)
	self.vb.latentVoidCount = 0
	self.vb.unleashedCount = 0
	self.vb.oblivionCount = 0
	self.vb.vengeanceCount = 0
	timerLatentVoidCD:Start(1)
	timerUnleashedCorruptionCD:Start(1)
	timerOblivionWaveCD:Start(1)
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

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 423305 then
		self.vb.latentVoidCount = self.vb.latentVoidCount + 1
		specWarnLatentVoid:Show(self.vb.latentVoidCount)
		specWarnLatentVoid:Play("watchstep")
		timerLatentVoidCD:Start()
	elseif spellId == 429487 then
		self.vb.unleashedCount = self.vb.unleashedCount + 1
		warnUnleashedCorruption:Show(self.vb.unleashedCount)
		timerUnleashedCorruptionCD:Start()
	elseif spellId == 445457 then
		self.vb.oblivionCount = self.vb.oblivionCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnOblivionWave:Show()
			specWarnOblivionWave:Play("defensive")
		end
		timerOblivionWaveCD:Start()
	elseif spellId == 424371 then
		self.vb.vengeanceCount = self.vb.vengeanceCount + 1
		warnStormsVengeance:Show(self.vb.vengeanceCount)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 181089 then--Encounter Event
		self.vb.vengeanceCount = self.vb.vengeanceCount + 1
		warnStormsVengeance:Show(self.vb.vengeanceCount)
	end
end
--]]

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
	elseif spellId == 429028 and self:AntiSpam(3, 1) then
		warnCorruptionPulse:Show(args.destName)
	elseif spellId == 423839 then
		timerElectrocuted:Start()
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
		timerElectrocuted:Stop()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 433067 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
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
