if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod(2650, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(215405)
mod:SetEncounterID(3053)
--mod:SetHotfixNoticeRev(20240817000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 473070 473112 469478",
	"SPELL_CAST_SUCCESS 470039 473112",
	"SPELL_AURA_APPLIED 470038 473112"
--	"SPELL_AURA_REMOVED"
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, Improve the code for pairing once we have context of how it all works to announce who your pair partner is
--TODO, potentially fix mudslide trigger
--local warnImpale							= mod:NewCountAnnounce(433425, 3)

local specWarnRazorchokeVines				= mod:NewSpecialWarningYouCount(433740, nil, nil, nil, 1, 2)--Pre target debuff
--local yellRazorchokeVines					= mod:NewShortYell(433740)
--local yellInfestationFades				= mod:NewShortFadesYell(433740)
local specWarnAwakenSwamp					= mod:NewSpecialWarningDodgeCount(473070, nil, nil, nil, 2, 2)
local specWarnMudslide						= mod:NewSpecialWarningDodgeCount(473112, nil, nil, nil, 2, 2)
local specWarnSludgeClaws					= mod:NewSpecialWarningDefensive(469478, nil, nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerRazorchokeVinesCD				= mod:NewAITimer(33.9, 470039, nil, nil, nil, 3)
local timerAwakenSwampCD					= mod:NewAITimer(33.9, 473070, nil, nil, nil, 3)
local timerMudslideCD						= mod:NewAITimer(33.9, 473112, nil, nil, nil, 3)
local timerSludgeClawsCD					= mod:NewAITimer(33.9, 469478, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod.vb.vinesCount = 0
mod.vb.swampCount = 0
mod.vb.mudslideCount = 0
mod.vb.clawsCount = 0

function mod:OnCombatStart(delay)
	self.vb.vinesCount = 0
	self.vb.swampCount = 0
	self.vb.mudslideCount = 0
	self.vb.clawsCount = 0
	timerRazorchokeVinesCD:Start(1-delay)
	timerAwakenSwampCD:Start(1-delay)
	timerMudslideCD:Start(1-delay)
	timerSludgeClawsCD:Start(1-delay)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 473070 then
		self.vb.swampCount = self.vb.swampCount + 1
		specWarnAwakenSwamp:Show(self.vb.swampCount)
		specWarnAwakenSwamp:Play("watchstep")
		timerAwakenSwampCD:Start()--33.9, self.vb.swampCount+1
	elseif spellId == 473112 and self:AntiSpam(10, 2) then
		self.vb.mudslideCount = self.vb.mudslideCount + 1
		specWarnMudslide:Show(self.vb.mudslideCount)
		specWarnMudslide:Play("watchstep")
		timerMudslideCD:Start()--33.9, self.vb.mudslideCount+1
	elseif spellId == 469478 then
		self.vb.clawsCount = self.vb.clawsCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSludgeClaws:Show()
			specWarnSludgeClaws:Play("defensive")
		end
		timerSludgeClawsCD:Start()--33.9, self.vb.clawsCount+1
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 470039 and self:AntiSpam(8, 1) then
		self.vb.vinesCount = self.vb.vinesCount + 1
		timerRazorchokeVinesCD:Start()--33.9, self.vb.vinesCount+1
	elseif spellId == 473112 and self:AntiSpam(10, 2) then
		self.vb.mudslideCount = self.vb.mudslideCount + 1
		specWarnMudslide:Show(self.vb.mudslideCount)
		specWarnMudslide:Play("watchstep")
		timerMudslideCD:Start()--33.9, self.vb.mudslideCount+1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 470038 then
		if self:AntiSpam(8, 1) then
			self.vb.vinesCount = self.vb.vinesCount + 1
			timerRazorchokeVinesCD:Start()--33.9, self.vb.vinesCount+1
		end
		if args:IsPlayer() then
			specWarnRazorchokeVines:Show(self.vb.vinesCount)
			specWarnRazorchokeVines:Play("gathershare")
		end
	elseif spellId == 473112 and self:AntiSpam(10, 2) then
		self.vb.mudslideCount = self.vb.mudslideCount + 1
		specWarnMudslide:Show(self.vb.mudslideCount)
		specWarnMudslide:Play("watchstep")
		timerMudslideCD:Start()--33.9, self.vb.mudslideCount+1
--	elseif spellId == 473508 or spellId == 470041 then
		--DO stuff
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 434408 then

	end
end
--]]

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
