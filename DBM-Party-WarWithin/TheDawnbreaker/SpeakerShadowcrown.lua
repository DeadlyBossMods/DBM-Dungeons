local mod	= DBM:NewMod(2580, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(211087)
mod:SetEncounterID(2837)
mod:SetHotfixNoticeRev(20240818000000)
mod:SetMinSyncRevision(20240706000000)
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
)

--TODO, do something with https://www.wowhead.com/beta/spell=426736/shadow-shroud ? i can't think of anything productive. It's more of unit frames thing
--[[
(ability.id = 425264 or ability.id = 453212 or ability.id = 445996 or ability.id = 453140 or ability.id = 426734) and type = "begincast"
 or ability.id = 453859 and (type = "applybuff" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnBurnignShadows					= mod:NewTargetNoFilterAnnounce(426734, 3, nil, "RemoveMagic|Healer")

local specWarnDarknessComes					= mod:NewSpecialWarningCount(453859, nil, nil, nil, 3, 2)
local specWarnObsidianBlast					= mod:NewSpecialWarningDefensive(425264, nil, nil, nil, 1, 2)--Heroic and Lower
local specWarnObsidianBeam					= mod:NewSpecialWarningDefensive(453212, nil, nil, nil, 1, 2, 4)--Mythic and Higher
local specWarnCollapsingDarkness			= mod:NewSpecialWarningDodgeCount(445996, nil, nil, nil, 2, 2)--Heroic and Lower
local specWarnCollapsingNight				= mod:NewSpecialWarningDodgeCount(453140, nil, nil, nil, 2, 2, 4)--Mythic and Higher
local specWarnBurningShadows				= mod:NewSpecialWarningYou(426734, nil, nil, nil, 1, 2)
--local yellSomeAbility						= mod:NewYell(372107)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

--Like all bosses in this zone, shorted cooldowns are not fully known. Boss has long ICDs and spell queue issues
local timerObsidianBlastCD					= mod:NewCDCountTimer(17, 425264, nil, nil, nil, 5)--Heroic and Lower
local timerObsidianBeamCD					= mod:NewCDCountTimer(24.3, 453212, nil, nil, nil, 5)--Mythic and Higher
local timerCollapsingDarknessCD				= mod:NewCDCountTimer(18, 445996, nil, nil, nil, 3)--Heroic and Lower
local timerCollapsingNightCD				= mod:NewCDCountTimer(25.9, 453140, nil, nil, nil, 3)--Mythic and Higher
local timerBurningShadowsCD					= mod:NewCDCountTimer(17, 426734, nil, nil, nil, 3)

mod.vb.darknessCount = 0
mod.vb.obsidianCount = 0
mod.vb.collapsingCount = 0
mod.vb.shadowsCount = 0

--Attempt at handling the predictable spell queues with hardcoded table
--if this fails, ugglier updateAllTimers will be used as fallback
local warnedTimerMissing = false--Single warn for single spell to avoid spam. As long as user finds ONE missing timer, their log is useful
local allTimers = {
	[1] = {
		[425264] = {6},--Obsidian Blast (Non Mythic)
		[453212] = {7.1, 32.4, 26.2},--Obsidian Beam (Mythic)
		[445996] = {13.1},--Collapsing Darkness (Non Mythic)
		[453140] = {23.3, 28.6, 26.3},--Collapsing Night (Mythic)
		[4267341] = {9.3},--Burning Shadows (Non Mythic)
		[4267342] = {19.2, 16.2, 24.8},--Burning Shadows (Mythic)
	},
	[2] = {
		[425264] = {6.8, 17},--Obsidian Blast (Non Mythic)
		[453212] = {18.2, 23.5, 25.1, 24.4, 26.9},--Obsidian Beam (Mythic)
		[445996] = {13.8, 18},--Collapsing Darkness (Non Mythic)
		[453140] = {8.7, 28, 25.1, 25.1, 26.7},--Collapsing Night (Mythic)
		[4267341] = {10.1, 25.2},--Burning Shadows (Non Mythic)
		[4267342] = {14.5, 19.2, 21.9, 21.1, 25.1},--Burning Shadows (Mythic)
	},								---23.5
}

--The ability queue priority is so predictable, it may be possible to fully sequence this bosses timers in a table, but I want to see a LOT more tables first
--Collapsing Night and Collapsing Darkness triggers 3.4 second ICD
--Burning Shadows triggers 3.7-4.1 second ICD
--Obsidian Blast triggers 3.4 second ICD
--Obsidian Beam triggers 12.1 second ICD in stage 1 and unknown 10.8 second ICD in stage 2
--[[
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerBurningShadowsCD:GetRemaining(self.vb.shadowsCount+1) < ICD then
		local elapsed, total = timerBurningShadowsCD:GetTime(self.vb.shadowsCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerBurningShadowsCD extended by: "..extend, 2)
		timerBurningShadowsCD:Update(elapsed, total+extend, self.vb.shadowsCount+1)
	end
	if self:IsMythic() then
		if timerObsidianBeamCD:GetRemaining(self.vb.obsidianCount+1) < ICD then
			local elapsed, total = timerObsidianBeamCD:GetTime(self.vb.obsidianCount+1)
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerObsidianBeamCD extended by: "..extend, 2)
			timerObsidianBeamCD:Update(elapsed, total+extend, self.vb.obsidianCount+1)
		end
		if timerCollapsingNightCD:GetRemaining(self.vb.collapsingCount+1) < ICD then
			local elapsed, total = timerCollapsingNightCD:GetTime(self.vb.collapsingCount+1)
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerCollapsingNightCD extended by: "..extend, 2)
			timerCollapsingNightCD:Update(elapsed, total+extend, self.vb.collapsingCount+1)
		end
	else
		if timerObsidianBlastCD:GetRemaining(self.vb.obsidianCount+1) < ICD then
			local elapsed, total = timerObsidianBlastCD:GetTime(self.vb.obsidianCount+1)
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerObsidianBlastCD extended by: "..extend, 2)
			timerObsidianBlastCD:Update(elapsed, total+extend, self.vb.obsidianCount+1)
		end
		if timerCollapsingDarknessCD:GetRemaining(self.vb.collapsingCount+1) < ICD then
			local elapsed, total = timerCollapsingDarknessCD:GetTime(self.vb.collapsingCount+1)
			local extend = ICD - (total-elapsed)
			DBM:Debug("timerCollapsingDarknessCD extended by: "..extend, 2)
			timerCollapsingDarknessCD:Update(elapsed, total+extend, self.vb.collapsingCount+1)
		end
	end
end
--]]

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.darknessCount = 0
	self.vb.obsidianCount = 0
	self.vb.collapsingCount = 0
	self.vb.shadowsCount = 0
	if self:IsMythic() then
		timerObsidianBeamCD:Start(7.1-delay, 1)
		timerBurningShadowsCD:Start(19.2-delay, 1)
		timerCollapsingNightCD:Start(23.3-delay, 1)
	else
		timerObsidianBlastCD:Start(6-delay, 1)
		timerBurningShadowsCD:Start(9.3-delay, 1)--9.3-11.3
		timerCollapsingDarknessCD:Start(13.1-delay, 1)--13.1-15.1
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 425264 then--Non Mythic
		self.vb.obsidianCount = self.vb.obsidianCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnObsidianBlast:Show()
			specWarnObsidianBlast:Play("defensive")
		end
		local timer = self:GetFromTimersTable(allTimers, false, self.vb.phase, 425264, self.vb.obsidianCount+1)
		if timer then
			timerObsidianBlastCD:Start(timer, self.vb.obsidianCount+1)
		else
			timerObsidianBlastCD:Start(17, self.vb.obsidianCount+1)--Still start a timer with lowest known value
			if not warnedTimerMissing then
				warnedTimerMissing = true
				DBM:AddMsg("Obsidian Blast timer missing for count: "..self.vb.obsidianCount+1 .. ". Please share your log on GitHub or DBM Discord", 1)
			end
		end
--		updateAllTimers(self, 3.4)
	elseif spellId == 453212 then--Mythic
		self.vb.obsidianCount = self.vb.obsidianCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnObsidianBeam:Show()
			specWarnObsidianBeam:Play("defensive")
		end
		local timer = self:GetFromTimersTable(allTimers, true, self.vb.phase, 453212, self.vb.obsidianCount+1)
		if timer then
			timerObsidianBeamCD:Start(timer, self.vb.obsidianCount+1)
		else
			timerObsidianBeamCD:Start(24.3, self.vb.obsidianCount+1)--Still start a timer with lowest known value
			if not warnedTimerMissing then
				warnedTimerMissing = true
				DBM:AddMsg("Obsidian Beam timer missing for count: "..self.vb.obsidianCount+1 .. ". Please share your log on GitHub or DBM Discord", 1)
			end
		end
--		updateAllTimers(self, self:GetStage(1) and 12.1 or 10.8)
	elseif spellId == 445996 then--Non Mythic
		self.vb.collapsingCount = self.vb.collapsingCount + 1
		specWarnCollapsingDarkness:Show(self.vb.collapsingCount)
		specWarnCollapsingDarkness:Play("watchstep")
		local timer = self:GetFromTimersTable(allTimers, false, self.vb.phase, 445996, self.vb.collapsingCount+1)
		if timer then
			timerCollapsingDarknessCD:Start(timer, self.vb.collapsingCount+1)
		else
			timerCollapsingDarknessCD:Start(18, self.vb.collapsingCount+1)--Still start a timer with lowest known value
			if not warnedTimerMissing then
				warnedTimerMissing = true
				DBM:AddMsg("Collapsing Darkness timer missing for count: "..self.vb.collapsingCount+1 .. ". Please share your log on GitHub or DBM Discord", 1)
			end
		end
--		updateAllTimers(self, 3.4)
	elseif spellId == 453140 then--Mythic
		self.vb.collapsingCount = self.vb.collapsingCount + 1
		specWarnCollapsingNight:Show(self.vb.collapsingCount)
		specWarnCollapsingNight:Play("watchstep")
		local timer = self:GetFromTimersTable(allTimers, true, self.vb.phase, 453140, self.vb.collapsingCount+1)
		if timer then
			timerCollapsingNightCD:Start(timer, self.vb.collapsingCount+1)
		else
			timerCollapsingNightCD():Start(25.9, self.vb.collapsingCount+1)--Still start a timer with lowest known value
			if not warnedTimerMissing then
				warnedTimerMissing = true
				DBM:AddMsg("Collapsing Night timer missing for count: "..self.vb.collapsingCount+1 .. ". Please share your log on GitHub or DBM Discord", 1)
			end
		end
--		updateAllTimers(self, 3.4)
	elseif spellId == 426734 then
		self.vb.shadowsCount = self.vb.shadowsCount + 1
		local timer = self:GetFromTimersTable(allTimers, false, self.vb.phase, self:IsMythic() and 4267342 or 4267341, self.vb.shadowsCount+1)
		if timer then
			timerBurningShadowsCD:Start(timer, self.vb.shadowsCount+1)
		else
			timerBurningShadowsCD:Start(17, self.vb.shadowsCount+1)--Still start a timer with lowest known value
			if not warnedTimerMissing then
				warnedTimerMissing = true
				DBM:AddMsg("Burning Shadows timer missing for count: "..self.vb.shadowsCount+1 .. ". Please share your log on GitHub or DBM Discord", 1)
			end
		end
--		updateAllTimers(self, 3.7)
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
		--Stop Timers
		timerObsidianBlastCD:Stop()
		timerCollapsingDarknessCD:Stop()
		timerBurningShadowsCD:Stop()
		timerObsidianBeamCD:Stop()
		timerCollapsingNightCD:Stop()
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
		if self.vb.darknessCount == 1 then--First one at 50%
			self:SetStage(2)
			--Restart timers
			if self:IsMythic() then
				timerCollapsingNightCD:Start(8.7, 1)
				timerBurningShadowsCD:Start(14.6, 1)
				timerObsidianBeamCD:Start(18.2, 1)
			else
				timerObsidianBlastCD:Start(6.8, 1)
				timerBurningShadowsCD:Start(10.1, 1)
				timerCollapsingDarknessCD:Start(13.8, 1)
			end
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
