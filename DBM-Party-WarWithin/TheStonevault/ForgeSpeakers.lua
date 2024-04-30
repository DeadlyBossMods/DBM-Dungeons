local mod	= DBM:NewMod(2590, "DBM-Party-WarWithin", 4, 1269)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213217, 213216)--Brokk, Dorlita
mod:SetEncounterID(2888)
mod:SetBossHPInfoToHighest()
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 445541 430097 428202 428711",
	"SPELL_CAST_SUCCESS 428508 428535 428120",
	"SPELL_AURA_APPLIED 439577",
	"SPELL_AURA_REMOVED 445541",
	"SPELL_PERIODIC_DAMAGE 429999",
	"SPELL_PERIODIC_MISSED 429999",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, auto mark cube with spell summon event? https://www.wowhead.com/beta/spell=428204/scrap-song
--TODO, need more timer data to know if alternating timers is enough, or if boss needs full sequencing
--[[
(ability.id = 445541 or ability.id = 430097 or ability.id = 428202 or ability.id = 428711) and type = "begincast"
or (ability.id = 428508 or ability.id = 428535 or ability.id = 428120) and type = "cast"
or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--General
local warnSilencedSpeaker					= mod:NewTargetNoFilterAnnounce(439577, 4)

local specWarnGTFO							= mod:NewSpecialWarningGTFO(429999, nil, nil, nil, 1, 8)
--Speaker Brokk
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28459))
local warnVentilationOver					= mod:NewEndAnnounce(445541, 1)

local specWarnActivateVentilation			= mod:NewSpecialWarningDodgeCount(445541, nil, nil, nil, 2, 2)
local specWarnMoltenMetal					= mod:NewSpecialWarningInterruptCount(430097, "HasInterrupt", nil, nil, 1, 2)
local specWarnScrapSong						= mod:NewSpecialWarningDodgeCount(428202, nil, nil, nil, 2, 2)
--local yellSomeAbility						= mod:NewYell(372107)

local timerActivateVentilationCD			= mod:NewCDCountTimer(15.7, 445541, nil, nil, nil, 3)--15.7 and 33.9 alternating?
local timerActivateVentilation				= mod:NewBuffActiveTimer(9, 445541, nil, nil, nil, 5)
local timerMoltenMetalCD					= mod:NewCDCountTimer(10.9, 430097, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerScrapSongCD						= mod:NewCDCountTimer(54.5, 428202, nil, nil, nil, 3)
--Speaker Dorlita
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28461))
local warnDeconstruction					= mod:NewCountAnnounce(428508, 3)

local specWarnMetalSplinters				= mod:NewSpecialWarningCount(428535, nil, nil, nil, 2, 2)--Change to run?
local specWarnMoltenHammer					= mod:NewSpecialWarningDefensive(428711, nil, nil, nil, 1, 2)
local specWarnLavaExpulsion					= mod:NewSpecialWarningDodgeCount(428120, nil, nil, nil, 2, 2)

local timerDeconstructionCD					= mod:NewCDCountTimer(54.5, 428508, nil, nil, nil, 2)
local timerMetalSplintersCD					= mod:NewNextCountTimer(7, 428535, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.DEADLY_ICON)
local timerMetalSplinters					= mod:NewBuffActiveTimer(15, 428535, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.DEADLY_ICON)
local timerMoltenHammerCD					= mod:NewCDCountTimer(12.1, 428711, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerLavaExpulsionCD					= mod:NewCDCountTimer(16.9, 428120, nil, nil, nil, 3)--16.9 and 37.6 alternating?

--Brokk
mod.vb.ventilationCount = 0
mod.vb.moltenMetalCount = 0
mod.vb.cubeCount = 0
--Dorlita
mod.vb.deconstructCount = 0
mod.vb.hammerCount = 0
mod.vb.orbCount = 0

--local castsPerGUID = {}

function mod:OnCombatStart(delay)
	self.vb.ventilationCount = 0
	self.vb.moltenMetalCount = 0
	self.vb.cubeCount = 0
	self.vb.deconstructCount = 0
	self.vb.hammerCount = 0
	self.vb.orbCount = 0
	timerMoltenMetalCD:Start(4.8-delay, 1)
	timerActivateVentilationCD:Start(9.6-delay, 1)
	timerScrapSongCD:Start(19.3-delay, 1)
	--
	timerLavaExpulsionCD:Start(12.1-delay, 1)
	timerMoltenHammerCD:Start(26.6-delay, 1)
	timerDeconstructionCD:Start(47.3-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 445541 then
		self.vb.ventilationCount  = self.vb.ventilationCount  + 1
		specWarnActivateVentilation:Show(self.vb.ventilationCount)
		specWarnActivateVentilation:Play("watchstep")
		if self.vb.ventilationCount % 2 == 0 then
			timerActivateVentilationCD:Start(15.7, self.vb.ventilationCount+1)
		else
			timerActivateVentilationCD:Start(33.9, self.vb.ventilationCount+1)
		end
		timerActivateVentilation:Start()--3 + 6
	elseif spellId == 430097 then
		if self.vb.moltenMetalCount == 2 then self.vb.moltenMetalCount = 0 end
		self.vb.moltenMetalCount = self.vb.moltenMetalCount + 1
		local kickCount = self.vb.moltenMetalCount
		specWarnMoltenMetal:Show(args.sourceName, kickCount)
		timerMoltenMetalCD:Start(nil, self.vb.moltenMetalCount+1)
		if kickCount == 1 then
			specWarnMoltenMetal:Play("kick1r")
		elseif kickCount == 2 then
			specWarnMoltenMetal:Play("kick2r")
		end
	elseif spellId == 428202 then
		self.vb.cubeCount = self.vb.cubeCount + 1
		specWarnScrapSong:Show(self.vb.cubeCount)
		specWarnScrapSong:Play("watchstep")--Or shockwave?
		timerScrapSongCD:Start(nil, self.vb.cubeCount+1)
	elseif spellId == 428711 then
		self.vb.hammerCount = self.vb.hammerCount + 1
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnMoltenHammer:Show()
			specWarnMoltenHammer:Play("defensive")
		end
		timerMoltenHammerCD:Start(nil, self.vb.hammerCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 428508 then
		self.vb.deconstructCount = self.vb.deconstructCount + 1
		warnDeconstruction:Show(self.vb.deconstructCount)
		--timerDeconstructionCD:Start(nil, self.vb.deconstructCount+1)--Maybe move this somewhere else
		timerMetalSplintersCD:Start(nil, self.vb.deconstructCount)--1 + 6
	elseif spellId == 428535 then
		specWarnMetalSplinters:Show()
		specWarnMetalSplinters:Play("aesoon")
		timerMetalSplinters:Start()
	elseif spellId == 428120 then
		self.vb.orbCount = self.vb.orbCount + 1
		specWarnLavaExpulsion:Show(self.vb.orbCount)
		specWarnLavaExpulsion:Play("watchorb")
		if self.vb.orbCount % 2 == 0 then
			timerLavaExpulsionCD:Start(37.6, self.vb.orbCount+1)
		else
			timerLavaExpulsionCD:Start(16.9, self.vb.orbCount+1)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 439577 then
		warnSilencedSpeaker:Show(args.destName)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 445541 then
		warnVentilationOver:Show()
		timerActivateVentilation:Stop()
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 429999 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 213217 then--Brokk
		timerActivateVentilationCD:Stop()
		timerMoltenMetalCD:Stop()
		timerScrapSongCD:Stop()
	elseif cid == 213216 then--Dorlita
		timerDeconstructionCD:Stop()
		timerMoltenHammerCD:Stop()
		timerLavaExpulsionCD:Stop()
		timerMetalSplintersCD:Stop()
		timerMetalSplinters:Stop()
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
