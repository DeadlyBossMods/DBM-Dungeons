local mod	= DBM:NewMod(2590, "DBM-Party-WarWithin", 4, 1269)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213217, 213216)--Brokk, Dorlita
mod:SetEncounterID(2888)
mod:SetBossHPInfoToHighest()
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

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

--TODO, watch for more tuning. timers already changed once in first weekend dungeon was up. It's also prone to spell queing issues exagerbated by interrupt timing
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

local timerActivateVentilationCD			= mod:NewCDCountTimer(15.7, 445541, nil, nil, nil, 3)
local timerActivateVentilation				= mod:NewBuffActiveTimer(9, 445541, nil, nil, nil, 5)
local timerMoltenMetalCD					= mod:NewCDCountTimer(6.9, 430097, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--6.9 + spell lockout time?
local timerScrapSongCD						= mod:NewCDCountTimer(54.5, 428202, nil, nil, nil, 3)
--Speaker Dorlita
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28461))
local warnDeconstruction					= mod:NewCountAnnounce(428508, 3)

local specWarnMetalSplinters				= mod:NewSpecialWarningRunCount(428535, nil, nil, nil, 4, 2)
local specWarnMoltenHammer					= mod:NewSpecialWarningDefensive(428711, nil, nil, nil, 1, 2)
local specWarnLavaExpulsion					= mod:NewSpecialWarningDodgeCount(428120, nil, nil, nil, 2, 2)

local timerDeconstructionCD					= mod:NewCDCountTimer(52.2, 428508, nil, nil, nil, 2)
local timerMetalSplintersCD					= mod:NewNextCountTimer(7, 428535, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.DEADLY_ICON)
--local timerMetalSplinters					= mod:NewBuffActiveTimer(15, 428535, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.DEADLY_ICON)
local timerMoltenHammerCD					= mod:NewCDCountTimer(12.1, 428711, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerLavaExpulsionCD					= mod:NewCDCountTimer(16.1, 428120, nil, nil, nil, 3)

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
	timerMoltenMetalCD:Start(4.4-delay, 1)
	timerActivateVentilationCD:Start(9.3-delay, 1)
	timerScrapSongCD:Start(19-delay, 1)
	--
	timerMoltenHammerCD:Start(6.9-delay, 1)
	timerLavaExpulsionCD:Start(12.1-delay, 1)
	timerDeconstructionCD:Start(51-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 445541 then
		self.vb.ventilationCount = self.vb.ventilationCount  + 1
		specWarnActivateVentilation:Show(self.vb.ventilationCount)
		specWarnActivateVentilation:Play("watchstep")
		timerActivateVentilationCD:Start(15.7, self.vb.ventilationCount+1)
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
		specWarnScrapSong:Play("runtoedge")--Or shockwave?
		timerScrapSongCD:Start(nil, self.vb.cubeCount+1)
		--These timers restart
		timerMoltenMetalCD:Stop()
		timerMoltenMetalCD:Start(7.3, self.vb.moltenMetalCount+1)
		timerActivateVentilationCD:Stop()
		timerActivateVentilationCD:Start(23.2, self.vb.ventilationCount+1)
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

		--This resets bosses other two abilities
		--Above is no longer true in newer beta builds
--		timerMoltenHammerCD:Stop()--No Longer resets here
--		timerMoltenHammerCD:Start(13, self.vb.hammerCount+1)
--		timerLavaExpulsionCD:Stop()
--		timerLavaExpulsionCD:Start(19, self.vb.orbCount+1)
	elseif spellId == 428535 then
		specWarnMetalSplinters:Show(self.vb.deconstructCount)
		specWarnMetalSplinters:Play("justrun")
--		timerMetalSplinters:Start()
	elseif spellId == 428120 then
		self.vb.orbCount = self.vb.orbCount + 1
		specWarnLavaExpulsion:Show(self.vb.orbCount)
		specWarnLavaExpulsion:Play("watchorb")
		timerLavaExpulsionCD:Start(nil, self.vb.orbCount+1)
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
--		timerMetalSplinters:Stop()
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
