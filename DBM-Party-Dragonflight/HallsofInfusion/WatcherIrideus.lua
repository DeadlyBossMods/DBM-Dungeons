local mod	= DBM:NewMod(2504, "DBM-Party-Dragonflight", 8, 1204)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(189719)
mod:SetEncounterID(2615)
mod:SetHotfixNoticeRev(20230507000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 389179 384014 384524 389446 384351",
	"SPELL_AURA_APPLIED 389179 383840 389443",
	"SPELL_AURA_REMOVED 389179 383840",
	"SPELL_PERIODIC_DAMAGE 389181",
	"SPELL_PERIODIC_MISSED 389181"
)

--[[
(ability.id = 389179 or ability.id = 384351 or ability.id = 384014 or ability.id = 384524 or ability.id = 389446) and type = "begincast"
 or ability.id = 383840
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
--]]
--Stage One: A Chance at Redemption
mod:AddTimerLine(DBM:EJ_GetSectionInfo(25745))
local warnPowerLoverload						= mod:NewTargetAnnounce(389179, 3)

local specWarnPowerOverload						= mod:NewSpecialWarningMoveAway(389179, nil, nil, nil, 1, 2)
local yellPowerOverload							= mod:NewYell(389179)
local yellPowerOverloadFades					= mod:NewShortFadesYell(389179)
local specWarnSparkVolley						= mod:NewSpecialWarningDodge(384351, nil, nil, nil, 2, 2)
local specWarnStaticSurge						= mod:NewSpecialWarningCount(384014, nil, nil, nil, 2, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(389181, nil, nil, nil, 1, 8)
local specWarnTitanticFist						= mod:NewSpecialWarningDodge(384524, nil, nil, nil, 1, 2)

local timerPowerOverloadCD						= mod:NewCDTimer(27.5, 389179, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSparkVolleyCD						= mod:NewCDTimer(31.6, 384351, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerStaticSurgeCD						= mod:NewCDCountTimer(27.5, 384014, nil, nil, nil, 2)
local timerTitanicFistCD						= mod:NewCDTimer(16.9, 384524, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
--Stage Two: Watcher's Last Stand
mod:AddTimerLine(DBM:EJ_GetSectionInfo(25744))
local warnAblativeBarrier						= mod:NewSpellAnnounce(383840, 2)
local warnAblativeBarrierOver					= mod:NewEndAnnounce(383840, 1)
local warnNullifyingPulse						= mod:NewCastAnnounce(389446, 4)
local warnPurifyingBlast						= mod:NewTargetNoFilterAnnounce(389443, 3, nil, false)

mod.vb.surgeCount = 0

function mod:OnCombatStart(delay)
	self.vb.surgeCount = 0
	self:SetStage(1)
	timerTitanicFistCD:Start(6-delay)
	timerStaticSurgeCD:Start(10-delay, 1)
	timerPowerOverloadCD:Start(23.4-delay)--20.6 (old?)
	timerSparkVolleyCD:Start(29.1-delay)--37.4 (old?)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 389179 then
		timerPowerOverloadCD:Start()
	elseif spellId == 384351 then
		specWarnSparkVolley:Show()
		specWarnSparkVolley:Play("watchstep")
		timerSparkVolleyCD:Start()
	elseif spellId == 384014 then
		self.vb.surgeCount = self.vb.surgeCount + 1
		specWarnStaticSurge:Show(self.vb.surgeCount)
		specWarnStaticSurge:Play("aesoon")
		timerStaticSurgeCD:Start(nil, self.vb.surgeCount+1)
	elseif spellId == 384524 then
		timerTitanicFistCD:Start()
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTitanticFist:Show()
			specWarnTitanticFist:Play("shockwave")
		end
	elseif spellId == 389446 and self:AntiSpam(3, 1) then
		warnNullifyingPulse:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 389179 then
		warnPowerLoverload:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnPowerOverload:Show()
			specWarnPowerOverload:Play("runout")
			yellPowerOverload:Yell()
			yellPowerOverloadFades:Countdown(spellId)
		end
	elseif spellId == 383840 then
		warnAblativeBarrier:Show()
		if self:GetStage(1) then
			self:SetStage(2)
			timerPowerOverloadCD:Stop()
			timerSparkVolleyCD:Stop()
			timerStaticSurgeCD:Stop()
			timerTitanicFistCD:Stop()
		end
	elseif spellId == 389443 then
		warnPurifyingBlast:CombinedShow(1, args.destname)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 389179 then
		if args:IsPlayer() then
			yellPowerOverloadFades:Cancel()
		end
	elseif spellId == 383840 then
		warnAblativeBarrierOver:Show()
		self:SetStage(1)
		timerTitanicFistCD:Start(6.1)
		timerStaticSurgeCD:Start(10.7, self.vb.surgeCount+1)
		timerPowerOverloadCD:Start(24.3)
		timerSparkVolleyCD:Start(31.6)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 389181 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
