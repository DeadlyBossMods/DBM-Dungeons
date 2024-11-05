local mod	= DBM:NewMod(2559, "DBM-Party-WarWithin", 1, 1210)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(208743)
mod:SetEncounterID(2826)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2651)
mod:SetUsedIcons(1, 2, 3)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 421817 424212 429113 423109 425394 443835",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 421817",--423080
	"SPELL_AURA_REMOVED 421817"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, get right events for gusts
--[[
(421817 424212 429113 423109 425394 443835) and type = "begincast"
 or (ability.id = 423080 or ability.id = 421817) and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnWicklighterBarrage				= mod:NewTargetNoFilterAnnounce(421817, 2)
local warnExtinguishingGust					= mod:NewIncomingCountAnnounce(429113, 2)
local warnEnkindlingInferno					= mod:NewCountAnnounce(423109, 3)
local warnDousingBreath						= mod:NewCountAnnounce(425394, 3)
local warnBlazingStorms						= mod:NewSpellAnnounce(443835, 3)

local specWarnWicklighterBarrage			= mod:NewSpecialWarningYou(421817, nil, nil, nil, 1, 2)
local yellWicklighterBarrage				= mod:NewShortPosYell(421817)
local specWarnInciteFlames					= mod:NewSpecialWarningCount(424212, nil, nil, nil, 2, 2)
--local specWarnExtinguishingGust				= mod:NewSpecialWarningYou(429113, nil, nil, nil, 1, 2)
--local yellExtinguishingGust					= mod:NewShortYell(429113)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerWicklighterBarrageCD				= mod:NewAITimer(33.9, 421817, nil, nil, nil, 3)
local timerInciteFlamesCD					= mod:NewAITimer(33.9, 424212, nil, nil, nil, 2)
local timerExtinguishingGustCD				= mod:NewAITimer(33.9, 429113, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerEnkindlingInfernoCD				= mod:NewAITimer(33.9, 423109, nil, nil, nil, 2)
local timerDousingBreathCD					= mod:NewAITimer(33.9, 425394, nil, nil, nil, 2)

mod:AddSetIconOption("IconOnWick", 421817, true, 0, {1, 2, 3})
mod:AddPrivateAuraSoundOption(423080, true, 429113, 1)

mod.vb.debuffIcon = 1
mod.vb.wickCount = 0
mod.vb.inciteCount = 0
mod.vb.gustCount = 0
mod.vb.infernoCount = 0
mod.vb.breathCount = 0

function mod:OnCombatStart(delay)
	self.vb.debuffIcon = 1
	self.vb.wickCount = 0
	self.vb.inciteCount = 0
	self.vb.gustCount = 0
	self.vb.infernoCount = 0
	self.vb.breathCount = 0
	timerWicklighterBarrageCD:Start(1-delay)
	timerInciteFlamesCD:Start(1-delay)
	timerExtinguishingGustCD:Start(1-delay)
	timerEnkindlingInfernoCD:Start(1-delay)
	timerDousingBreathCD:Start(1-delay)
	self:EnablePrivateAuraSound(423080, "targetyou", 2)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 421817 then
		self.vb.debuffIcon = 1
		self.vb.wickCount = self.vb.wickCount + 1
		timerWicklighterBarrageCD:Start()
	elseif spellId == 424212 then
		self.vb.inciteCount = self.vb.inciteCount + 1
		specWarnInciteFlames:Show(self.vb.inciteCount)
		specWarnInciteFlames:Play("aesoon")
		timerInciteFlamesCD:Start()
	elseif spellId == 429113 then
		self.vb.gustCount = self.vb.gustCount + 1
		warnExtinguishingGust:Show(self.vb.gustCount)
		timerExtinguishingGustCD:Start()
	elseif spellId == 423109 then
		self.vb.infernoCount = self.vb.infernoCount + 1
		warnEnkindlingInferno:Show(self.vb.infernoCount)
		timerEnkindlingInfernoCD:Start()
	elseif spellId == 425394 then
		self.vb.breathCount = self.vb.breathCount + 1
		warnDousingBreath:Show(self.vb.breathCount)
		timerDousingBreathCD:Start()
	elseif spellId == 443835 then
		warnBlazingStorms:Show()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 421817 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 421817 then
		warnWicklighterBarrage:PreciseShow(3, args.destName)
		if args:IsPlayer() then
			specWarnWicklighterBarrage:Show()
			specWarnWicklighterBarrage:Play("targetyou")
			yellWicklighterBarrage:Yell(self.vb.debuffIcon, self.vb.debuffIcon)
		end
		if self.Options.IconOnWick then
			self:SetIcon(args.destName, self.vb.debuffIcon)
		end
		self.vb.debuffIcon = self.vb.debuffIcon + 1
	--elseif spellId == 423080 then
	--	warnExtinguishingGust:CombinedShow(0.5, args.destName)--Change to PreciseShow once we confirm if it's 2 or 4 targets
	--	if args:IsPlayer() then
	--		specWarnExtinguishingGust:Show()
	--		specWarnExtinguishingGust:Play("targetyou")
	--		yellExtinguishingGust:Yell()
	--	end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 421817 then
		if self.Options.IconOnWick then
			self:SetIcon(args.destName, 0)
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
