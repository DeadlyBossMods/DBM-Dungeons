if DBM:GetTOC() < 100105 then return end
local mod	= DBM:NewMod(2538, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(199000)
mod:SetEncounterID(2673)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20230709000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 416152 411763 410904 416139 416264",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 412027",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"SPELL_PERIODIC_DAMAGE 417413",
	"SPELL_PERIODIC_MISSED 417413",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 410904 or ability.id = 416152 or ability.id = 416139 or ability.id = 416264) and type = "begincast"
 or target.id = 205212 and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
 or (ability.id = 411763 or ability.id = 412027) and type = "begincast"
--]]
--NOTES, chronal burst was only cast once so don't know timer. meanwhile infinite blast is spammed so no timer wanted
--TODO, detect Nozdormu being freed and associated buffs going out?
--TODO, cleaner more robust phase change?
--TODO, review the timer auto correct stuff on live as any tweaks to blizzards code can radically change it
--Stage 1: We Are Infinite
mod:AddTimerLine(DBM:EJ_GetSectionInfo(26751))
local warnSummonInfiniteKeeper						= mod:NewCountAnnounce(416152, 3)
local warnInfinityOrb								= mod:NewCountAnnounce(410904, 3)
local warnAddsLeft									= mod:NewAddsLeftAnnounce(-27151, 2, 416152)

local specWarnChronalBurn							= mod:NewSpecialWarningDispel(412027, "RemoveMagic", nil, nil, 1, 2)
local specWarnInfiniteBlast							= mod:NewSpecialWarningInterrupt(411763, "HasInterrupt", nil, nil, 1, 2)
local specWarnTemporalbreath						= mod:NewSpecialWarningCount(416152, nil, nil, nil, 2, 2)
--local yellManaBomb								= mod:NewYell(386181)
--local yellManaBombFades							= mod:NewShortFadesYell(386181)

--local timerManaBombsCD							= mod:NewAITimer(19.4, 386173, nil, nil, nil, 3)
local timerSummonInfiniteKeeperCD					= mod:NewCDCountTimer(20.2, 416152, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerInfinityOrbCD							= mod:NewCDCountTimer(14.5, 410904, nil, nil, nil, 3)
local timerTemporalBreathCD							= mod:NewCDCountTimer(17, 416152, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--Stage 2: Lord of the Infinite
mod:AddTimerLine(DBM:EJ_GetSectionInfo(26757))
local specWarnInfiniteCorruption					= mod:NewSpecialWarningDodgeCount(416264, nil, nil, nil, 2, 2)
local specWarnGTFO									= mod:NewSpecialWarningGTFO(417413, nil, nil, nil, 1, 8)

local timerInfiniteCorruptionCD						= mod:NewCDCountTimer(24.2, 416264, nil, nil, nil, 3)

--mod:AddInfoFrameOption(391977, true)
mod:GroupSpells(416152, -27151)

mod.vb.keeperCount = 0
mod.vb.orbCount = 0
mod.vb.breathCount = 0
mod.vb.addsLeft = 4

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.keeperCount = 0
	self.vb.orbCount = 0
	self.vb.breathCount = 0
	self.vb.addsLeft = 4
	timerTemporalBreathCD:Start(9.6-delay, 1)
	timerSummonInfiniteKeeperCD:Start(15-delay, 1)
	timerInfinityOrbCD:Start(19.3-delay, 1)
end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

--https://www.warcraftlogs.com/reports/7WYTrKcjtkf68VCd#fight=last&type=summary&hostility=1&pins=2%24Off%24%23244F4B%24expression%24(ability.id%20%3D%20410904%20or%20ability.id%20%3D%20416152%20or%20ability.id%20%3D%20416139%20or%20ability.id%20%3D%20416264)%20and%20type%20%3D%20%22begincast%22%0A%20or%20target.id%20%3D%20205212%20and%20type%20%3D%20%22death%22%0A%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22%20or%20source.name%20%3D%20%22Nozdormu%22%20or%20target.name%20%3D%20%22Nozdormu%22&view=events
--Timer Notes
--Actual Infinite Breath Cd is unknown in phase 2 due to fact it's delayed 100% of time by corruption or orbs
--Actual Cd on orbs is also unknown for same reason, it's always pushed back by something (usually temporal breath)
--Temporal Breath causes a 7.2 spell lockout on Orbs but not adds or infinite corruption
--Infinity Orb causes a 6 second spell lockout on Temporal brearh but this is super rare, takes a really long pull for this to happen, causes 2.8 on Infinite Corruption
--Infinite Corruption causes a 14.1 second lockout on Temporal Breath,
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 416152 then
		self.vb.keeperCount = self.vb.keeperCount + 1
		warnSummonInfiniteKeeper:Show(self.vb.keeperCount)
		if self.vb.keeperCount < 3 then--3 casts, first two is 1 add 3rd cast is 2
			timerSummonInfiniteKeeperCD:Start(nil, self.vb.keeperCount+1)
		end
	elseif spellId == 411763 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnInfiniteBlast:Show(args.sourceName)
		specWarnInfiniteBlast:Play("kickcast")
	elseif spellId == 410904 then
		self.vb.orbCount = self.vb.orbCount + 1
		warnInfinityOrb:Show(self.vb.orbCount)
		if self:GetStage(1) then
			timerInfinityOrbCD:Start(14.5, self.vb.orbCount+1)--14.5 unless delayed by temporal breath (which is like 90% of time)
		else
			timerInfinityOrbCD:Start(23, self.vb.orbCount+1)--23-24.3 (possibly lower, unknown due to spell queue effects)
		end
		--Correct timer with forced ICD of this ability
		if timerTemporalBreathCD:GetRemaining(self.vb.breathCount+1) < 6 then
			local elapsed, total = timerTemporalBreathCD:GetTime(self.vb.breathCount+1)
			local extend = 6 - (total-elapsed)
			DBM:Debug("timerTemporalBreathCD extended by: "..extend, 2)
			timerTemporalBreathCD:Update(elapsed, total+extend, self.vb.breathCount+1)
		end
	elseif spellId == 416139 then
		self.vb.breathCount = self.vb.breathCount + 1
		specWarnTemporalbreath:Show(self.vb.breathCount)
		specWarnTemporalbreath:Play("breathsoon")
		if self:GetStage(1) then
			if self.vb.breathCount < 4 then--Seems to stop casting it after 4 casts in P1
				timerTemporalBreathCD:Start(17, self.vb.breathCount+1)
			end
		else
			timerTemporalBreathCD:Start(18)--24.2 most of time due to spell queues but can be as low as 18 (maybe even lower)
		end
		--Correct timer with forced ICD of this ability
		if timerInfinityOrbCD:GetRemaining(self.vb.orbCount+1) < 7.2 then
			local elapsed, total = timerInfinityOrbCD:GetTime(self.vb.orbCount+1)
			local extend = 7.2 - (total-elapsed)
			DBM:Debug("timerInfinityOrbCD extended by: "..extend, 2)
			timerInfinityOrbCD:Update(elapsed, total+extend, self.vb.orbCount+1)
		end
	elseif spellId == 416264 then
		self.vb.keeperCount = self.vb.keeperCount + 1
		specWarnInfiniteCorruption:Show(self.vb.keeperCount)
		specWarnInfiniteCorruption:Play("watchstep")
		timerInfiniteCorruptionCD:Start(24.2, self.vb.keeperCount+1)
		--Correct timer with forced ICD of this ability
		if timerTemporalBreathCD:GetRemaining(self.vb.breathCount+1) < 14.1 then
			local elapsed, total = timerTemporalBreathCD:GetTime(self.vb.breathCount+1)
			local extend = 14.1 - (total-elapsed)
			DBM:Debug("timerTemporalBreathCD extended by: "..extend, 2)
			timerTemporalBreathCD:Update(elapsed, total+extend, self.vb.breathCount+1)
		end
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 387691 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 412027 and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") then
		specWarnChronalBurn:Show(args.destName)
		specWarnChronalBurn:Play("helpdispel")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 386181 then

	end
end
--]]

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 417413 and destGUID == UnitGUID("player") and self:AntiSpam(3, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 205212 then--Infinite keeper
		self.vb.addsLeft = self.vb.addsLeft - 1
		warnAddsLeft:Show(self.vb.addsLeft)
		if self.vb.addsLeft == 0 then
			self:SetStage(2)
			self.vb.breathCount = 0
			self.vb.orbCount = 0
			self.vb.keeperCount = 0--Reused for Infinite Corruption
			timerTemporalBreathCD:Restart(6.2, 1)
			timerInfinityOrbCD:Restart(13.5, 1)
			timerInfiniteCorruptionCD:Start(15.1, 1)
		end
	end
end

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
