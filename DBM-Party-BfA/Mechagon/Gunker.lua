local mod	= DBM:NewMod(2358, "DBM-Party-BfA", 11, 1178)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(150222)
mod:SetEncounterID(2292)
mod:SetZone(2097)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 297834 297835",
	"SPELL_CAST_SUCCESS 297985",
	"SPELL_AURA_APPLIED 298259 297913"
--	"SPELL_AURA_REMOVED 298259"
)

--[[
(ability.id = 297834 or ability.id = 297835) and type = "begincast"
 or (ability.id = 297821 or ability.id = 297985) and type = "cast"
--]]
local warnGooped					= mod:NewTargetNoFilterAnnounce(298259, 2)
local warnSplatter					= mod:NewCountAnnounce(297985, 2)

local specWarnToxicWave				= mod:NewSpecialWarningCount(297834, nil, nil, nil, 2, 2)
local specWarnGooped				= mod:NewSpecialWarningYou(298259, nil, nil, nil, 1, 2)
local specWarnGoopedDispel			= mod:NewSpecialWarningDispel(298259, "RemoveDisease", nil, nil, 1, 2)
local specWarnToxicGoopDispel		= mod:NewSpecialWarningDispel(297913, false, nil, nil, 1, 2)
local specWarnCoalesce				= mod:NewSpecialWarningDodgeCount(297835, nil, nil, nil, 2, 2)

local timerToxicWaveCD				= mod:NewCDCountTimer(49.8, 297834, nil, nil, nil, 2)
local timerSplatterCD				= mod:NewCDCountTimer(24.2, 297985, nil, nil, nil, 3)
local timerCoalesceCD				= mod:NewCDCountTimer(49.8, 297835, nil, nil, nil, 3)

mod.vb.toxicCount = 0
mod.vb.splatCount = 0
mod.vb.coalesceCount = 0

function mod:OnCombatStart(delay)
	self.vb.toxicCount = 0
	self.vb.splatCount = 0
	self.vb.coalesceCount = 0
	timerSplatterCD:Start(8.7-delay, 1)
	timerCoalesceCD:Start(20.6-delay, 1)
	timerToxicWaveCD:Start(44.8-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 297834 then
		self.vb.toxicCount = self.vb.toxicCount + 1
		specWarnToxicWave:Show(self.vb.toxicCount)
		specWarnToxicWave:Play("specialsoon")--watchwave (if dodgable)
		timerToxicWaveCD:Start(nil, self.vb.toxicCount+1)
	elseif spellId == 297835 then
		self.vb.coalesceCount = self.vb.coalesceCount + 1
		specWarnCoalesce:Show(self.vb.coalesceCount)
		specWarnCoalesce:Play("watchstep")
		timerCoalesceCD:Start(nil, self.vb.coalesceCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 297985 then
		self.vb.splatCount = self.vb.splatCount + 1
		warnSplatter:Show(self.vb.splatCount)
		timerSplatterCD:Start(nil, self.vb.splatCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 298259 then
		if args:IsPlayer() then
			specWarnGooped:Show()
			specWarnGooped:Play("targetyou")
		elseif self.Options.SpecWarn298259dispel and self:CheckDispelFilter("disease") then
			specWarnGoopedDispel:Show(args.destName)
			specWarnGoopedDispel:Play("helpdispel")
		else
			warnGooped:CombinedShow(1, args.destName)
		end
	elseif spellId == 297913 then
		if args:IsPlayer() then
			specWarnGooped:Show()
			specWarnGooped:Play("targetyou")
		elseif self.Options.SpecWarn297913dispel and self:CheckDispelFilter("disease") then
			specWarnToxicGoopDispel:Show(args.destName)
			specWarnToxicGoopDispel:Play("helpdispel")
		end
	end
end
