local mod	= DBM:NewMod(2590, "DBM-Party-WarWithin", 4, 1269)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213217, 213216)--Brokk, Dorlita
mod:SetEncounterID(2888)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20240717000000)
mod:SetMinSyncRevision(20240717000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 430097 428202 428711",
	"SPELL_CAST_SUCCESS 428508 428535 428120 445541",
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
or (ability.id = 445541 or ability.id = 428508 or ability.id = 428535 or ability.id = 428120) and type = "cast"
or ability.id = 439577 or (target.id = 213217 or target.id = 213216) and type = "death"
or stoppedAbility.id = 430097
or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--General
local warnSilencedSpeaker					= mod:NewTargetNoFilterAnnounce(439577, 4)

local specWarnGTFO							= mod:NewSpecialWarningGTFO(429999, nil, nil, nil, 1, 8)
--Speaker Brokk
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28459))
local warnVentilationOver					= mod:NewEndAnnounce(445541, 1)

local specWarnExhaustVents					= mod:NewSpecialWarningDodgeCount(445541, nil, nil, nil, 2, 2)
local specWarnMoltenMetal					= mod:NewSpecialWarningInterruptCount(430097, "HasInterrupt", nil, nil, 1, 2)
local specWarnScrapSong						= mod:NewSpecialWarningDodgeCount(428202, nil, nil, nil, 2, 2)
--local yellSomeAbility						= mod:NewYell(372107)

--Pretty much all of his timers can be delayed by up to 6 seconds by spell lockouts from interrupts
local timerExhaustVentsCD					= mod:NewCDCountTimer(27, 445541, nil, nil, nil, 3)
local timerExhaustVents						= mod:NewBuffActiveTimer(6, 445541, nil, nil, nil, 5)
local timerMoltenMetalCD					= mod:NewCDCountTimer(14.5, 430097, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerScrapSongCD						= mod:NewCDCountTimer(49.7, 428202, nil, nil, nil, 3)
--Speaker Dorlita
mod:AddTimerLine(DBM:EJ_GetSectionInfo(28461))
local warnBlazingCrescendo					= mod:NewPreWarnAnnounce(428508, 7, 4)

local specWarnBlazingCrescendo				= mod:NewSpecialWarningRunCount(428508, nil, nil, nil, 4, 2)
local specWarnIgneousHammer					= mod:NewSpecialWarningDefensive(428711, nil, nil, nil, 1, 2)
local specWarnLavaCannon					= mod:NewSpecialWarningDodgeCount(428120, nil, nil, nil, 2, 2)

local timerBlazingCrescendoCD				= mod:NewCDCountTimer(52.2, 428508, nil, nil, nil, 2)
local timerBlazingCrescendo					= mod:NewCastTimer(7, 428508, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.DEADLY_ICON)
local timerIgneousHammerCD					= mod:NewCDCountTimer(12.1, 428711, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerLavaCannonCD						= mod:NewCDCountTimer(16.9, 428120, nil, nil, nil, 3)

--Brokk
mod.vb.ventilationCount = 0
mod.vb.moltenMetalCount = 0
mod.vb.cubeCount = 0
--Dorlita
mod.vb.deconstructCount = 0
mod.vb.hammerCount = 0
mod.vb.orbCount = 0

--Lava Cannon triggers 3.5 second ICD on all of Dorlita's other abilities
--Igneous Hammer 2 second ICD on all of Dorlita's other abilities
--Blazing Crescendo may trigger 13 second ICD on all of Dorlita's other abilities
local function updateDorlitaTimers(self, ICD)
	if timerIgneousHammerCD:GetRemaining(self.vb.hammerCount+1) < ICD then
		local elapsed, total = timerIgneousHammerCD:GetTime(self.vb.hammerCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerIgneousHammerCD extended by: "..extend, 2)
		timerIgneousHammerCD:Update(elapsed, total+extend, self.vb.hammerCount+1)
	end
	if timerLavaCannonCD:GetRemaining(self.vb.orbCount+1) < ICD then
		local elapsed, total = timerLavaCannonCD:GetTime(self.vb.orbCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerLavaCannonCD extended by: "..extend, 2)
		timerLavaCannonCD:Update(elapsed, total+extend, self.vb.orbCount+1)
	end
	if timerBlazingCrescendoCD:GetRemaining(self.vb.deconstructCount+1) < ICD then
		local elapsed, total = timerBlazingCrescendoCD:GetTime(self.vb.deconstructCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerBlazingCrescendoCD extended by: "..extend, 2)
		timerBlazingCrescendoCD:Update(elapsed, total+extend, self.vb.deconstructCount+1)
	end
end

--Scrap Song Triggers 7.2 ICD on all of Brokk's other abilities
--Exhaust Vents Triggers 3.6 second ICD on all of Brokk's other abilities
local function updateBrokkTimers(self, ICD)
	if timerScrapSongCD:GetRemaining(self.vb.cubeCount+1) < ICD then
		local elapsed, total = timerScrapSongCD:GetTime(self.vb.cubeCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerScrapSongCD extended by: "..extend, 2)
		timerScrapSongCD:Update(elapsed, total+extend, self.vb.cubeCount+1)
	end
	if timerMoltenMetalCD:GetRemaining(self.vb.moltenMetalCount+1) < ICD then
		local elapsed, total = timerMoltenMetalCD:GetTime(self.vb.moltenMetalCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerMoltenMetalCD extended by: "..extend, 2)
		timerMoltenMetalCD:Update(elapsed, total+extend, self.vb.moltenMetalCount+1)
	end
	if timerExhaustVentsCD:GetRemaining(self.vb.ventilationCount+1) < ICD then
		local elapsed, total = timerExhaustVentsCD:GetTime(self.vb.ventilationCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerExhaustVentsCD extended by: "..extend, 2)
		timerExhaustVentsCD:Update(elapsed, total+extend, self.vb.ventilationCount+1)
	end
end

function mod:OnCombatStart(delay)
	self.vb.ventilationCount = 0
	self.vb.moltenMetalCount = 0
	self.vb.cubeCount = 0
	self.vb.deconstructCount = 0
	self.vb.hammerCount = 0
	self.vb.orbCount = 0
	if self:IsMythic() then
		timerMoltenMetalCD:Start(4-delay, 1)--4-5.2
		timerScrapSongCD:Start(18.2-delay, 1)
		timerExhaustVentsCD:Start(34.1-delay, 1)--34.1-41 based on spell lockouts from interrupts
		--
		timerIgneousHammerCD:Start(6-delay, 1)
		timerLavaCannonCD:Start(12.1-delay, 1)
		timerBlazingCrescendoCD:Start(45, 1)--45-53 based on spell lockouts from interrupts
	else
		timerMoltenMetalCD:Start(3.3-delay, 1)--3.3-5.2
		timerExhaustVentsCD:Start(8.3-delay, 1)--At least on follower, don't know about heroic or normal yet
		timerScrapSongCD:Start(18.0-delay, 1)
		--
		timerIgneousHammerCD:Start(6.9-delay, 1)
		timerLavaCannonCD:Start(13.0-delay, 1)
		timerBlazingCrescendoCD:Start(45.2, 1)
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 430097 then
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
		--These timers extend if remaining Cd under these values otherwise roll over
		--if timerMoltenMetalCD:GetRemaining(self.vb.moltenMetalCount+1) < 7.2 then
		--	local elapsed, total = timerMoltenMetalCD:GetTime(self.vb.moltenMetalCount+1)
		--	local extend = 7.2 - (total-elapsed)
		--	DBM:Debug("timerMoltenMetalCD extended by: "..extend, 2)
		--	timerMoltenMetalCD:Update(elapsed, total+extend, self.vb.moltenMetalCount+1)
		--end
		--if timerExhaustVentsCD:GetRemaining(self.vb.ventilationCount+1) < 17 then
		--	local elapsed, total = timerExhaustVentsCD:GetTime(self.vb.ventilationCount+1)
		--	local extend = 17 - (total-elapsed)
		--	DBM:Debug("timerExhaustVentsCD extended by: "..extend, 2)
		--	timerExhaustVentsCD:Update(elapsed, total+extend, self.vb.ventilationCount+1)
		--end
		updateBrokkTimers(self, 7.2)
	elseif spellId == 428711 then
		self.vb.hammerCount = self.vb.hammerCount + 1
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnIgneousHammer:Show()
			specWarnIgneousHammer:Play("defensive")
		end
		timerIgneousHammerCD:Start(nil, self.vb.hammerCount+1)
		updateDorlitaTimers(self, 2)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 428508 then
		self.vb.deconstructCount = self.vb.deconstructCount + 1
		warnBlazingCrescendo:Show()
		timerBlazingCrescendoCD:Start(nil, self.vb.deconstructCount+1)
		timerBlazingCrescendo:Start(nil, self.vb.deconstructCount)--1 + 6

		--These timers extend if remaining Cd under these values otherwise roll over
		--This may still be wrong, it just needs monitoring
		if timerIgneousHammerCD:GetRemaining(self.vb.hammerCount+1) < 13 then
			local elapsed, total = timerIgneousHammerCD:GetTime(self.vb.hammerCount+1)
			local extend = 13 - (total-elapsed)
			DBM:Debug("timerIgneousHammerCD extended by: "..extend, 2)
			timerIgneousHammerCD:Update(elapsed, total+extend, self.vb.hammerCount+1)
		end
		if timerLavaCannonCD:GetRemaining(self.vb.orbCount+1) < 19 then
			local elapsed, total = timerLavaCannonCD:GetTime(self.vb.orbCount+1)
			local extend = 19 - (total-elapsed)
			DBM:Debug("timerLavaCannonCD extended by: "..extend, 2)
			timerLavaCannonCD:Update(elapsed, total+extend, self.vb.orbCount+1)
		end
		--BlazingCrescendo seems to get SHORTENED if it's > than this value (which is pretty much 100% of time)
		if timerExhaustVentsCD:GetRemaining(self.vb.ventilationCount+1) > 16.2 then
			timerExhaustVentsCD:Stop()
			timerExhaustVentsCD:Start(16.2, self.vb.ventilationCount+1)
		end
		--updateDorlitaTimers(self, 13)--Technically right, but
	elseif spellId == 428535 then
		specWarnBlazingCrescendo:Show(self.vb.deconstructCount)
		specWarnBlazingCrescendo:Play("justrun")
	elseif spellId == 428120 then
		self.vb.orbCount = self.vb.orbCount + 1
		specWarnLavaCannon:Show(self.vb.orbCount)
		specWarnLavaCannon:Play("watchorb")
		timerLavaCannonCD:Start(nil, self.vb.orbCount+1)
		updateDorlitaTimers(self, 3.5)
	elseif spellId == 445541 then
		self.vb.ventilationCount = self.vb.ventilationCount  + 1
		specWarnExhaustVents:Show(self.vb.ventilationCount)
		specWarnExhaustVents:Play("watchstep")
		--This seems to actually have a higher Cd when it's not interfered with, it just gets interferred with a lot
		timerExhaustVentsCD:Start(26.7, self.vb.ventilationCount+1)
		timerExhaustVents:Start()--6
		updateBrokkTimers(self, 3.6)--Can't cast anything else while channeling this
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
		timerExhaustVents:Stop()
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
		timerExhaustVentsCD:Stop()
		timerMoltenMetalCD:Stop()
		timerScrapSongCD:Stop()
		timerBlazingCrescendoCD:Stop()
	elseif cid == 213216 then--Dorlita
		timerScrapSongCD:Stop()
		timerBlazingCrescendoCD:Stop()
		timerIgneousHammerCD:Stop()
		timerLavaCannonCD:Stop()
		timerBlazingCrescendo:Stop()
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
