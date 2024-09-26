local mod	= DBM:NewMod(2594, "DBM-Party-WarWithin", 8, 1274)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(216619)
mod:SetEncounterID(2907)
mod:SetHotfixNoticeRev(20240818000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 434722 434779 448560 434829",
	"SPELL_AURA_APPLIED 448561",
	"SPELL_AURA_REMOVED 448561",
	"SPELL_PERIODIC_DAMAGE 434926",
	"SPELL_PERIODIC_MISSED 434926"
)

--NOTE: Chains of Oppression doesn't really need much, it's just an always active mechanic if you aren't in melee range of boss
--NOTE: there is a duplicate mechanic of doubt mechanic that does not mention boss name with same 3 spells (cast, debuff, failure debuff). maybe used on trash too?
--[[
(ability.id = 434722 or ability.id = 434779 or ability.id = 448560 or ability.id = 434829) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnShadowsofDoubt				= mod:NewTargetNoFilterAnnounce(448560, 3)

local specWarnSubjugate					= mod:NewSpecialWarningDefensive(434722, nil, nil, nil, 1, 2)
local specWarnTerrorize					= mod:NewSpecialWarningDodgeCount(434779, nil, nil, nil, 2, 15)
local specWarnShadowsofDoubt			= mod:NewSpecialWarningMoveAway(448560, nil, nil, nil, 1, 2)
local yellShadowsofDoubt				= mod:NewYell(448560)
local yellShadowsofDoubtFades			= mod:NewShortFadesYell(448560)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(434926, nil, nil, nil, 1, 8)

local timerSubjugateCD					= mod:NewCDCountTimer(13.5, 434722, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerTerrorizeCD					= mod:NewCDCountTimer(8.4, 434779, nil, nil, nil, 3)
local timerShadowsofDoubtCD				= mod:NewCDCountTimer(30.3, 448560, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)--30.3-32.1
local timerVociferousIndoctrinationCD	= mod:NewCDCountTimer(30.3, 434829, nil, nil, nil, 2)--30.3-31.6

mod.vb.subjugateCount = 0
mod.vb.terrorizeCount = 0
mod.vb.doubtCount = 0
mod.vb.fakeNewsCount = 0

function mod:OnCombatStart(delay)
	self.vb.subjugateCount = 0
	self.vb.terrorizeCount = 0
	self.vb.doubtCount = 0
	self.vb.fakeNewsCount = 0
	timerSubjugateCD:Start(4.4-delay, 1)--4.4-4.8
	timerTerrorizeCD:Start(9.3-delay, 1)--9.3-9.7
	timerVociferousIndoctrinationCD:Start(25.1-delay, 1)
	if self:IsMythic() then
		timerShadowsofDoubtCD:Start(14.1-delay, 1)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 434722 then
		self.vb.subjugateCount = self.vb.subjugateCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSubjugate:Show()
			specWarnSubjugate:Play("defensive")
		end
		if self.vb.subjugateCount % 2 == 0 then
			timerSubjugateCD:Start(12.8, self.vb.subjugateCount+1)--12.8-14
		else
			--Will be delayed by Vociferous Indoctrination
			timerSubjugateCD:Start(17.1, self.vb.subjugateCount+1)--17.1-17.6
		end
	elseif spellId == 434779 then
		self.vb.terrorizeCount = self.vb.terrorizeCount + 1
		specWarnTerrorize:Show(self.vb.terrorizeCount)
		specWarnTerrorize:Play("frontal")
		if self.vb.terrorizeCount % 2 == 0 then
			timerTerrorizeCD:Start(21.8, self.vb.terrorizeCount+1)--21.8-23.1
		else
			--Will be delayed by Vociferous Indoctrination
			timerTerrorizeCD:Start(8.5, self.vb.terrorizeCount+1)--8.4-8.9
		end
	elseif spellId == 448560 then
		self.vb.doubtCount = self.vb.doubtCount + 1
		timerShadowsofDoubtCD:Start(nil, self.vb.doubtCount+1)
	elseif spellId == 434829 then
		self.vb.fakeNewsCount = self.vb.fakeNewsCount + 1
		timerVociferousIndoctrinationCD:Start(nil, self.vb.fakeNewsCount+1)
		--Make timers more precise that used lowest predicted spell queue delay to use actual spell queue delay here
		--(This is miniscule correction, like 0.5-2 seconds or so, but it's cheap and easy to do)
		if timerSubjugateCD:GetRemaining(self.vb.subjugateCount+1) < 10.9 then
			local elapsed, total = timerSubjugateCD:GetTime(self.vb.subjugateCount+1)
			local extend = 10.9 - (total-elapsed)
			DBM:Debug("timerSubjugateCD extended by: "..extend, 2)
			timerSubjugateCD:Update(elapsed, total+extend, self.vb.subjugateCount+1)
		end
		if timerTerrorizeCD:GetRemaining(self.vb.terrorizeCount+1) < 15.4 then
			local elapsed, total = timerTerrorizeCD:GetTime(self.vb.terrorizeCount+1)
			local extend = 15.4 - (total-elapsed)
			DBM:Debug("timerTerrorizeCD extended by: "..extend, 2)
			timerTerrorizeCD:Update(elapsed, total+extend, self.vb.terrorizeCount+1)
		end
		if self:IsMythic() and timerShadowsofDoubtCD:GetRemaining(self.vb.doubtCount+1) < 20.1 then
			local elapsed, total = timerShadowsofDoubtCD:GetTime(self.vb.doubtCount+1)
			local extend = 20.1 - (total-elapsed)
			DBM:Debug("timerShadowsofDoubtCD extended by: "..extend, 2)
			timerShadowsofDoubtCD:Update(elapsed, total+extend, self.vb.doubtCount+1)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 448561 then
		warnShadowsofDoubt:PreciseShow(2, args.destName)
		if args:IsPlayer() then
			specWarnShadowsofDoubt:Show()
			specWarnShadowsofDoubt:Play("runout")
			yellShadowsofDoubt:Yell()
			yellShadowsofDoubtFades:Countdown(spellId, 3)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 448561 then
		if args:IsPlayer() then
			yellShadowsofDoubtFades:Cancel()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 434926 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
