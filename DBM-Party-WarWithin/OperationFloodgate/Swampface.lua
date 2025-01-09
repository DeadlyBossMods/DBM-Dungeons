if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod(2650, "DBM-Party-WarWithin", 9, 1298)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(226396)
mod:SetEncounterID(3053)
--mod:SetHotfixNoticeRev(20240817000000)
--mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2773)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 473070 473114 469478",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 470038 472819",
--	"SPELL_AURA_REMOVED"
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, Improve the code for pairing once we have context of how it all works to announce who your pair partner is
local specWarnRazorchokeVines				= mod:NewSpecialWarningYouCount(470038, nil, nil, nil, 1, 2)--Pre target debuff
local specWarnVinePartner					= mod:NewSpecialWarningLink(433425, nil, nil, nil, 1, 2)
local yellRazorchokeVines					= mod:NewIconTargetYell(433425)
--local yellInfestationFades				= mod:NewShortFadesYell(433740)
local specWarnAwakenSwamp					= mod:NewSpecialWarningDodgeCount(473070, nil, nil, nil, 2, 2)
local specWarnMudslide						= mod:NewSpecialWarningDodgeCount(473114, nil, nil, nil, 2, 2)
local specWarnSludgeClaws					= mod:NewSpecialWarningDefensive(469478, nil, nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerRazorchokeVinesCD				= mod:NewAITimer(30, 470039, nil, nil, nil, 3)
local timerAwakenSwampCD					= mod:NewAITimer(30, 473070, nil, nil, nil, 3)
local timerMudslideCD						= mod:NewAITimer(30, 473114, nil, nil, nil, 3)
local timerSludgeClawsCD					= mod:NewAITimer(30, 469478, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod.vb.vinesCount = 0
mod.vb.swampCount = 0
mod.vb.mudslideCount = 0
mod.vb.clawsCount = 0
local vineTargets = {}

function mod:OnCombatStart(delay)
	self.vb.vinesCount = 0
	self.vb.swampCount = 0
	self.vb.mudslideCount = 0
	self.vb.clawsCount = 0
--	timerRazorchokeVinesCD:Start(1-delay)--1, 30, 30 (commented since it's used immediately)
	timerAwakenSwampCD:Start(1-delay)--19.0, 30.0
	timerMudslideCD:Start(1-delay)--9.0, 30.0
	timerSludgeClawsCD:Start(1-delay)--3.0, 30.0, 30.0
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
	elseif spellId == 473114 then
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

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 470039 and self:AntiSpam(8, 1) then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 470038 then--Pre target debuff everyone gets at once
		if args:IsPlayer() then
			specWarnRazorchokeVines:Show(self.vb.vinesCount)
			specWarnRazorchokeVines:Play("gathershare")
		end
	elseif spellId == 472819 then--Pairing debuff that links players in sets of 2
		vineTargets[#vineTargets + 1] = args.destName
		if #vineTargets % 2 == 0 then
			local icon = #vineTargets / 2
			local playerIsInPair = false
			if vineTargets[#vineTargets-1] == UnitName("player") then
				specWarnVinePartner:Show(vineTargets[#vineTargets])
				specWarnVinePartner:Play("linegather")
				playerIsInPair = true
			elseif vineTargets[#vineTargets] == UnitName("player") then
				specWarnVinePartner:Show(vineTargets[#vineTargets-1])
				specWarnVinePartner:Play("linegather")
				playerIsInPair = true
			end
			if playerIsInPair then
				yellRazorchokeVines:Yell(icon)
			end
		end
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

--Vines Cast not in combat log (only debuffs, but this is more efficent timer start)
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 470039 then
		self.vb.vinesCount = self.vb.vinesCount + 1
		timerRazorchokeVinesCD:Start()--33.9, self.vb.vinesCount+1
	end
end
