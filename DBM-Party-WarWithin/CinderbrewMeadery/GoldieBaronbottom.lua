local mod	= DBM:NewMod(2589, "DBM-Party-WarWithin", 7, 1272)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(218523)
mod:SetEncounterID(2930)
mod:SetUsedIcons(1, 2)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 435622 435560 436592",
	"SPELL_CAST_SUCCESS 436644",
	"SPELL_AURA_APPLIED 435789 436644",
--	"SPELL_AURA_APPLIED_DOSE 435789",
	"SPELL_AURA_REMOVED 435789 436644"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, track number of remaining bombs and cahnge emphasis of Hail if more than a couple?
--TODO, warn cinderboom going off, but which ID, there are 4 of them, and it might not even be CLEU
--TODO, right event for spread the love timer/announce
--TODO, can bombs be auto marked with https://www.wowhead.com/beta/spell=435567/spread-the-love and https://www.wowhead.com/beta/spell=439517/spread-the-love
--TODO, do timers reset on Hail?
--TODO, can tank sidestep frontal?
local warnSpreadtheLove						= mod:NewCountAnnounce(435560, 3)--Maybe change to bomb count not spread count, or show both
local warnBurningRicochet					= mod:NewTargetNoFilterAnnounce(436644, 4)

local specWarnLetItHail						= mod:NewSpecialWarningCount(435622, nil, nil, nil, 2, 2)
local specWarnBurningRicochet				= mod:NewSpecialWarningYouPos(436644, nil, nil, nil, 1, 2)
local yellBurningRicochet					= mod:NewShortPosYell(436644)
local yellBurningRicochetFades				= mod:NewIconFadesYell(436644)
local specWarnCashCannon					= mod:NewSpecialWarningCount(436592, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerLetItHailCD						= mod:NewAITimer(33.9, 435622, nil, nil, nil, 2)
local timerCinderWounds						= mod:NewBuffFadesTimer(33.9, 435789, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerSpreadtheLoveCD					= mod:NewAITimer(33.9, 435560, nil, nil, nil, 5)
local timerBurningRicochetCD				= mod:NewAITimer(33.9, 436644, nil, nil, nil, 3)
local timerCashCannonCD						= mod:NewAITimer(33.9, 436592, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddSetIconOption("SetIconOnRico", 436644, true, false, {1, 2})

mod.vb.hailCount = 0
mod.vb.debuffsTracked = 0
mod.vb.spreadCount = 0
mod.vb.ricochetCount = 0
mod.vb.DebuffIcon = 1
mod.vb.cannonCount = 0

function mod:OnCombatStart(delay)
	self.vb.hailCount = 0
	self.vb.debuffsTracked = 0
	self.vb.spreadCount = 0
	self.vb.ricochetCount = 0
	self.vb.DebuffIcon = 1
	self.vb.cannonCount = 0
	timerLetItHailCD:Start(1)
	timerSpreadtheLoveCD:Start(1)
	timerBurningRicochetCD:Start(1)
	timerCashCannonCD:Start(1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 435622 then
		self.vb.hailCount = self.vb.hailCount + 1
		specWarnLetItHail:Show(self.vb.hailCount)
		specWarnLetItHail:Play("specialsoon")
		timerLetItHailCD:Start()
	elseif spellId == 435560 then
		self.vb.spreadCount = self.vb.spreadCount + 1
		warnSpreadtheLove:Show(self.vb.spreadCount)
		timerSpreadtheLoveCD:Start()
	elseif spellId == 436592 then
		self.vb.cannonCount = self.vb.cannonCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnCashCannon:Show()
			specWarnCashCannon:Play("carefly")
		end
		timerCashCannonCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 436644 and self:AntiSpam(3, 1) then
		self.vb.DebuffIcon = 1
		self.vb.ricochetCount = self.vb.ricochetCount + 1
		timerBurningRicochetCD:Start()
	end
end


function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 435789 then
		self.vb.debuffsTracked = self.vb.debuffsTracked + 1
		if self.vb.debuffsTracked == 1 then
			timerCinderWounds:Start()
		end
	elseif spellId == 436644 then
		local icon = self.vb.DebuffIcon
		if self.Options.SetIconOnExplosiveEruption then
			self:SetIcon(args.destName, icon)
		end
		if args:IsPlayer() then
			specWarnBurningRicochet:Show(self:IconNumToTexture(icon))
			specWarnBurningRicochet:Play("targetyou")--"mm"..icon
			yellBurningRicochet:Yell(icon, icon)
			yellBurningRicochetFades:Countdown(spellId, nil, icon)
		else
			warnBurningRicochet:CombinedShow(0.5, args.destName)
		end
		self.vb.DebuffIcon = self.vb.DebuffIcon + 1
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 435789 then
		self.vb.debuffsTracked = self.vb.debuffsTracked - 1
		if self.vb.debuffsTracked == 0 then
			timerCinderWounds:Stop()
		end
	elseif spellId == 436644 then

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
