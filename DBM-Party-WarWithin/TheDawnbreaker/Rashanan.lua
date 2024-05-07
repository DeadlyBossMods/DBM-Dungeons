local mod	= DBM:NewMod(2593, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213937)
mod:SetEncounterID(2839)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 434407 448213 448888 439784 434089",
--	"SPELL_CAST_SUCCESS 438875",
	"SPELL_AURA_APPLIED 449042",
	"SPELL_AURA_REMOVED 449734",
	"SPELL_DAMAGE 434726"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--Note, throw bomb is inaccurate for tracking actual bombs hitting boss. Have at least one log where one bomb missed
--TODO, stage 2. Boss was so undertuned in normal it just dies instantly on stage 2 start, so no mechanics seen
--[[
(ability.id = 434407 or ability.id = 448213 or ability.id = 448888 or ability.id = 439784 or ability.id = 434089) and type = "begincast"
 or ability.id = 438875 and type = "cast"
 or ability.id = 449734 and (type = "begincast" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnBlazing							= mod:NewCountAnnounce(434726, 1)
local warnRollingAcid						= mod:NewIncomingCountAnnounce(438875, 2)--General announce, private aura sound will be personal emphasis
local warnRadiantLight						= mod:NewYouAnnounce(449042, 1)
local warnSpinneretsStrands					= mod:NewIncomingCountAnnounce(439784, 3)--General announce, private aura sound will be personal emphasis

local specWarnExpelWebs						= mod:NewSpecialWarningDodgeCount(448213, nil, nil, nil, 1, 2, 4)
local specWarnErosiveSpray					= mod:NewSpecialWarningCount(448888, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerRollingAcidCD					= mod:NewCDCountTimer(21.3, 434407, nil, nil, nil, 3)
local timerExpelWebsCD						= mod:NewAITimer(33.9, 448213, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerErosiveSprayCD					= mod:NewCDCountTimer(19.9, 448888, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerAcidicEruptionCD					= mod:NewCDTimer(5, 449734, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSpinneretsStrandsCD				= mod:NewAITimer(33.9, 439784, nil, nil, nil, 3)

mod:AddPrivateAuraSoundOption(434406, true, 434407, 1)--Rolling Acid target
mod:AddPrivateAuraSoundOption(439783, true, 439784, 1)--Spineret's Strands target

mod.vb.bombCount = 0
mod.vb.rollingCount = 0
mod.vb.expelCount = 0
mod.vb.sprayCount = 0
mod.vb.strandsCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.bombCount = 0
	self.vb.rollingCount = 0
	self.vb.expelCount = 0
	self.vb.sprayCount = 0
	self.vb.strandsCount = 0
	timerRollingAcidCD:Start(9.3-delay, 1)
	timerErosiveSprayCD:Start(20-delay, 1)
	if self:IsMythic() then
		timerExpelWebsCD:Start(1-delay)
	end
	self:EnablePrivateAuraSound(434406, "targetyou", 2)--Rolling Acid Stage 1
	self:EnablePrivateAuraSound(439790, "targetyou", 2, 434406)--Rolling Acid Stage 2
	self:EnablePrivateAuraSound(439783, "pullin", 12)--Mythic?
	self:EnablePrivateAuraSound(434090, "pullin", 12, 439783)--Non Mythic?
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 434407 then
		self.vb.rollingCount = self.vb.rollingCount + 1
		warnRollingAcid:Show(self.vb.rollingCount)
		timerRollingAcidCD:Start(nil, self.vb.rollingCount+1)
	elseif spellId == 448213 then
		self.vb.expelCount = self.vb.expelCount + 1
		specWarnExpelWebs:Show(self.vb.expelCount)
		specWarnExpelWebs:Play("watchstep")
		timerExpelWebsCD:Start()
	elseif spellId == 448888 then
		self.vb.sprayCount = self.vb.sprayCount + 1
		specWarnErosiveSpray:Show(self.vb.sprayCount)
		specWarnErosiveSpray:Play("aesoon")
		timerErosiveSprayCD:Start(nil, self.vb.sprayCount+1)
	elseif spellId == 439784 or spellId == 434089 then
		self.vb.strandsCount = self.vb.strandsCount + 1
		warnSpinneretsStrands:Show(self.vb.strandsCount)
		timerSpinneretsStrandsCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 438875 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 449042 and args:IsPlayer() then
		warnRadiantLight:Show()
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 449734 then--Acidic Eruption ending
		self:SetStage(2)
		timerSpinneretsStrandsCD:Start(2)
		--timerRollingAcidCD:Start()
		--timerErosiveSprayCD:Start()
		--if self:IsMythic() then
			--timerExpelWebsCD:Start()
		--end
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 434726 then
		self.vb.bombCount = self.vb.bombCount + 1
		warnBlazing:Show(self.vb.bombCount)
		if self.vb.bombCount == 5 then--Journal says 6, but 5 is pushing boss in all logs (on normal at least)
			self:SetStage(1.5)
			--Maybe cancel timers on a later event if one found, damage events suck
			timerRollingAcidCD:Stop()
			timerErosiveSprayCD:Stop()
			timerExpelWebsCD:Stop()
			timerAcidicEruptionCD:Start(60, 1)--60-63, give or take for boss position for lift off
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
