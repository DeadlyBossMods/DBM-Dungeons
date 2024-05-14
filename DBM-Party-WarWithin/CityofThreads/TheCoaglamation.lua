local mod	= DBM:NewMod(2600, "DBM-Party-WarWithin", 8, 1274)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(216320)
mod:SetEncounterID(2905)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 441289 448185 438658",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 447402",
	"SPELL_AURA_REMOVED 447402"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, infoframe for corrupted coating? only if someone asks for it. Realistically i doubt anyone would use DBM for this anyways
--TODO, long enough pull to see Dark Pulse. Cannot even guess which ID it uses and it's not used in first 56 seconds of fight (longest public long)
local warnSlimePropagation					= mod:NewTargetNoFilterAnnounce(447402, 3)

local specWarnViscousDarkness				= mod:NewSpecialWarningCount(441216, nil, nil, nil, 2, 2)
local specWarnSlimePropagation				= mod:NewSpecialWarningMoveAway(447402, nil, nil, nil, 2, 2, 4)
local yellSlimePropagation					= mod:NewYell(447402)
local yellSlimePropagationFades				= mod:NewShortFadesYell(447402)
local specWarnVoidSurge						= mod:NewSpecialWarningDodgeCount(445435, nil, nil, nil, 2, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerViscousDarknessCD				= mod:NewAITimer(33.9, 441216, nil, nil, nil, 5)
local timerSlimePropagationCD				= mod:NewAITimer(33.9, 447402, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerVoidSurgeCD						= mod:NewAITimer(33.9, 445435, nil, nil, nil, 3)
--local timerDarkPulseCD					= mod:NewAITimer(33.9, 445435, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)

mod.vb.viscousCount = 0
mod.vb.slimepropCount = 0
mod.vb.surgeCount = 0
--mod.vb.pulseCount = 0

function mod:OnCombatStart(delay)
	self.vb.viscousCount = 0
	self.vb.slimepropCount = 0
	self.vb.surgeCount = 0
	--self.vb.pulseCount = 0
	timerViscousDarknessCD:Start(1-delay)
	timerVoidSurgeCD:Start(1-delay)
	if self:IsMythic() then
		timerSlimePropagationCD:Start(1-delay)
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 441289 then
		self.vb.viscousCount = self.vb.viscousCount + 1
		specWarnViscousDarkness:Show()
		specWarnViscousDarkness:Play("helpsoak")
		timerViscousDarknessCD:Start()
	elseif spellId == 448185 then
		self.vb.slimepropCount = self.vb.slimepropCount + 1
		timerSlimePropagationCD:Start()
	elseif spellId == 438658 then
		self.vb.surgeCount = self.vb.surgeCount + 1
		specWarnVoidSurge:Show(self.vb.surgeCount)
		specWarnVoidSurge:Play("watchstep")
		timerVoidSurgeCD:Start()
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
	if spellId == 447402 then
		warnSlimePropagation:PreciseShow(2, args.destName)
		if args:IsPlayer() then
			specWarnSlimePropagation:Show()
			specWarnSlimePropagation:Play("scatter")
			yellSlimePropagation:Yell()
			yellSlimePropagationFades:Countdown(spellId)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 447402 then
		if args:IsPlayer() then
			yellSlimePropagationFades:Cancel()
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
