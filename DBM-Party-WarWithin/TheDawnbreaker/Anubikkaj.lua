local mod	= DBM:NewMod(2581, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(211087)
mod:SetEncounterID(2838)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 425264 453212 445996 453140 426734",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 453859 426735",
	"SPELL_AURA_REMOVED 453859"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, do something with https://www.wowhead.com/beta/spell=426736/shadow-shroud ? i can't think of anything productive. It's more of unit frames thing
--[[
(ability.id = 425264 or ability.id = 453212 or ability.id = 445996 or ability.id = 453140 or ability.id = 426734) and type = "begincast"
 or ability.id = 453859 and (type = "applybuff" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnBurnignShadows					= mod:NewTargetNoFilterAnnounce(426734, 3, nil, "RemoveMagic|Healer")

local specWarnDarknessComes					= mod:NewSpecialWarningCount(453859, nil, nil, nil, 3, 2)
local specWarnObsidianBlast					= mod:NewSpecialWarningDefensive(453212, nil, nil, nil, 1, 2)
local specWarnCollapsingDarkness			= mod:NewSpecialWarningDodgeCount(453140, nil, nil, nil, 2, 2)
local specWarnBurningShadows				= mod:NewSpecialWarningYou(426734, nil, nil, nil, 1, 2)
--local yellSomeAbility						= mod:NewYell(372107)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerObsidianBlastCD					= mod:NewAITimer(33.9, 453212, nil, nil, nil, 5)--Combining blast with beam
local timerCollapsingDarknessCD				= mod:NewAITimer(33.9, 453140, nil, nil, nil, 3)--Combining Darkness with Night
local timerBurningShadowsCD					= mod:NewAITimer(33.9, 426734, nil, nil, nil, 3)

mod.vb.darknessCount = 0
mod.vb.obsidianCount = 0
mod.vb.collapsingCount = 0
mod.vb.shadowsCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.darknessCount = 0
	self.vb.obsidianCount = 0
	self.vb.collapsingCount = 0
	self.vb.shadowsCount = 0
	timerObsidianBlastCD:Start(1-delay)--6
	timerBurningShadowsCD:Start(1-delay)--9.3
	timerCollapsingDarknessCD:Start(1-delay)--13.1
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 425264 or spellId == 453212 then--Non Mythic, Mythic
		self.vb.obsidianCount = self.vb.obsidianCount + 1
		timerObsidianBlastCD:Start()
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnObsidianBlast:Show()
			specWarnObsidianBlast:Play("defensive")
		end
	elseif spellId == 445996 or spellId == 453140 then--Non Mythic, Mythic
		self.vb.collapsingCount = self.vb.collapsingCount + 1
		specWarnCollapsingDarkness:Show(self.vb.collapsingCount)
		specWarnCollapsingDarkness:Play("watchstep")
		timerCollapsingDarknessCD:Start()
	elseif spellId == 426734 then
		self.vb.shadowsCount = self.vb.shadowsCount + 1
		timerBurningShadowsCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 372858 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 453859 then
		self.vb.darknessCount = self.vb.darknessCount + 1
		specWarnDarknessComes:Show(self.vb.darknessCount)
		specWarnDarknessComes:Play("justrun")
		timerObsidianBlastCD:Stop()
		timerCollapsingDarknessCD:Stop()
		timerBurningShadowsCD:Stop()
	elseif spellId == 426735 then
		if args:IsPlayer() then
			specWarnBurningShadows:Show()
			specWarnBurningShadows:Play("targetyou")
		else
			warnBurnignShadows:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 453859 then
		--Increment phase after each movement
		self:SetStage(0)
		timerObsidianBlastCD:Start(2)--6.8
		timerBurningShadowsCD:Start(2)--10.1
		timerCollapsingDarknessCD:Start(2)--13.8
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
