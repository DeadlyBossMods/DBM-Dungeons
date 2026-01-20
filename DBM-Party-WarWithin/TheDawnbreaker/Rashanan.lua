local mod	= DBM:NewMod(2593, "DBM-Party-WarWithin", 5, 1270)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213937)
mod:SetEncounterID(2839)
mod:SetHotfixNoticeRev(20240706000000)
mod:SetMinSyncRevision(20240706000000)
mod:SetZone(2662)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:AddPrivateAuraSoundOption(434406, true, 434407, 1)--Rolling Acid target
mod:AddPrivateAuraSoundOption(439783, true, 434089, 1)--Spineret's Strands target
mod:AddPrivateAuraSoundOption(438957, true, 438957, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(434406, "targetyou", 2)--Likely dungeon version of Rolling Acid
	self:EnablePrivateAuraSound(439790, "targetyou", 2, 434406)--Likely the raid version of Rolling Acid
	self:EnablePrivateAuraSound(439783, "runout", 12)--Likely the dungeon version of Spinneret's Strands
	self:EnablePrivateAuraSound(434090, "runout", 12, 439783)--Likely the raid version of Spinneret's Strands
	self:EnablePrivateAuraSound(438957, "watchfeet", 8)--Acidic Pools ground effect
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 434407 448213 448888 434089",
	"SPELL_AURA_APPLIED 449042",
	"SPELL_INTERRUPT",
	"SPELL_DAMAGE 434726"
)
--]]

--https://www.warcraftlogs.com/reports/a1Dz7jN4xKWLbHvC#fight=last&pins=2%24Off%24%23244F4B%24expression%24(ability.id%20%3D%20434407%20or%20ability.id%20%3D%20448213%20or%20ability.id%20%3D%20448888%20or%20ability.id%20%3D%20439784%20or%20ability.id%20%3D%20434089)%20and%20type%20%3D%20%22begincast%22%0A%20or%20ability.id%20%3D%20438875%20and%20type%20%3D%20%22cast%22%0A%20or%20ability.id%20%3D%20449734%20and%20(type%20%3D%20%22begincast%22%20or%20type%20%3D%20%22removebuff%22)%20or%20stoppedAbility.id%20%3D%20449734%0A%20or%20ability.id%20%3D%20434726%20and%20type%20%3D%20%22damage%22%0A%20or%20type%20%3D%20%22dungeonencounterstart%22%20or%20type%20%3D%20%22dungeonencounterend%22&view=events
--NOTE, some spellIds might be mixed up with raid version (and viceversa). Both are included for safety.
--NOTE, throw bomb is inaccurate for tracking actual bombs hitting boss. Have at least one log where one bomb missed, so spell damage event is more accurate
--[[
(ability.id = 434407 or ability.id = 448213 or ability.id = 448888 or ability.id = 439784 or ability.id = 434089) and type = "begincast"
 or ability.id = 449734 and (type = "begincast" or type = "removebuff") or stoppedAbility.id = 449734
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 438875 and type = "cast"
 or ability.id = 434726 and type = "damage"
--]]
--[[
local warnBlazing							= mod:NewCountAnnounce(434726, 1)
local warnRollingAcid						= mod:NewIncomingCountAnnounce(434407, 2)--General announce, private aura sound will be personal emphasis
local warnRadiantLight						= mod:NewYouAnnounce(449042, 1)
local warnSpinneretsStrands					= mod:NewIncomingCountAnnounce(434089, 3)--General announce, private aura sound will be personal emphasis

local specWarnExpelWebs						= mod:NewSpecialWarningDodgeCount(448213, nil, nil, nil, 1, 2, 4)
local specWarnErosiveSpray					= mod:NewSpecialWarningCount(448888, nil, nil, nil, 2, 2)

--most timers actual value not known, due to fact that they are ICD impacted. Lowest seen on mythic is 15.2, lowest seen on non mythic is 20
local timerRollingAcidCD					= mod:NewCDCountTimer(15.2, 434407, nil, nil, nil, 3)
local timerExpelWebsCD						= mod:NewCDCountTimer(15.2, 448213, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerErosiveSprayCD					= mod:NewCDCountTimer(15.2, 448888, nil, nil, nil, 2, nil, DBM_COMMON_L.HEALER_ICON)
local timerAcidicEruptionCD					= mod:NewNextTimer(60, 449734, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSpinneretsStrandsCD				= mod:NewCDCountTimer(15.2, 434089, nil, nil, nil, 3)--16 lowest seen, takes a REALLY long p2 pull for it to avoid ICD queuing to 22

mod:AddPrivateAuraSoundOption(434406, true, 434407, 1)--Rolling Acid target
mod:AddPrivateAuraSoundOption(439783, true, 434089, 1)--Spineret's Strands target

mod.vb.bombCount = 0
mod.vb.rollingCount = 0
mod.vb.expelCount = 0
mod.vb.sprayCount = 0
mod.vb.strandsCount = 0

--RULES need reworking when I have time. ICDs are true, but the way boss prioritizes abilities is that any ability that's late, it tries to get back on track by making next one early
--So with that knowledge, you can order the corrections in a way that is more predictive

--Explosive spray triggers 6.66 ICD in stage 1 and 7.4 ICD in stage 2
--Rolling Acid triggers 6 second ICD in stage 1 and 6.66 ICD stage 2
--Expel Webs triggers 4 second ICD??
--Spinneret's Strands triggers 5.9 second ICD now (formerly 5.3)
--Results in most timers followinga  18-20 second cadaence in stage 1 and 22-24 second cadence in stage 2
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerRollingAcidCD:GetRemaining(self.vb.rollingCount+1) < ICD then
		local elapsed, total = timerRollingAcidCD:GetTime(self.vb.rollingCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerRollingAcidCD extended by: "..extend, 2)
		timerRollingAcidCD:Update(elapsed, total+extend, self.vb.rollingCount+1)
	end
	if timerExpelWebsCD:GetRemaining(self.vb.expelCount+1) < ICD then
		local elapsed, total = timerExpelWebsCD:GetTime(self.vb.expelCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerExpelWebsCD extended by: "..extend, 2)
		timerExpelWebsCD:Update(elapsed, total+extend, self.vb.expelCount+1)
	end
	if timerErosiveSprayCD:GetRemaining(self.vb.sprayCount+1) < ICD then
		local elapsed, total = timerErosiveSprayCD:GetTime(self.vb.sprayCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerErosiveSprayCD extended by: "..extend, 2)
		timerErosiveSprayCD:Update(elapsed, total+extend, self.vb.sprayCount+1)
	end
	if self:GetStage(2) and timerSpinneretsStrandsCD:GetRemaining(self.vb.strandsCount+1) < ICD then
		local elapsed, total = timerSpinneretsStrandsCD:GetTime(self.vb.strandsCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerSpinneretsStrandsCD extended by: "..extend, 2)
		timerSpinneretsStrandsCD:Update(elapsed, total+extend, self.vb.strandsCount+1)
	end
end

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.bombCount = 0
	self.vb.rollingCount = 0
	self.vb.expelCount = 0
	self.vb.sprayCount = 0
	self.vb.strandsCount = 0
	if self:IsMythic() then
		timerExpelWebsCD:Start(6.6-delay, 1)
	end
	timerRollingAcidCD:Start(9.3-delay, 1)
	timerErosiveSprayCD:Start(20-delay, 1)
	self:EnablePrivateAuraSound(434406, "targetyou", 2)--Likely dungeon version of Rolling Acid
	self:EnablePrivateAuraSound(439790, "targetyou", 2, 434406)--Likely the raid version of Rolling Acid
	self:EnablePrivateAuraSound(439783, "runout", 12)--Likely the dungeon version of Spinneret's Strands
	self:EnablePrivateAuraSound(434090, "runout", 12, 439783)--Likely the raid version of Spinneret's Strands
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 434407 then
		self.vb.rollingCount = self.vb.rollingCount + 1
		warnRollingAcid:Show(self.vb.rollingCount)
		timerRollingAcidCD:Start(self:IsMythic() and 15.2 or (self:GetStage(2) and 25 or 18.6), self.vb.rollingCount+1)
		updateAllTimers(self, self:GetStage(1) and 6 or 6.6)
	elseif spellId == 448213 then
		self.vb.expelCount = self.vb.expelCount + 1
		specWarnExpelWebs:Show(self.vb.expelCount)
		specWarnExpelWebs:Play("watchstep")
		timerExpelWebsCD:Start(self:IsMythic() and 9.9 or (self:GetStage(2) and 23 or 20), self.vb.expelCount+1)
		updateAllTimers(self, 4)
	elseif spellId == 448888 then
		self.vb.sprayCount = self.vb.sprayCount + 1
		specWarnErosiveSpray:Show(self.vb.sprayCount)
		specWarnErosiveSpray:Play("aesoon")
		timerErosiveSprayCD:Start(self:IsMythic() and 15.2 or (self:GetStage(2) and 25 or 20), self.vb.sprayCount+1)--Could be even shorter, hard to say since it's always ICD impacted
		updateAllTimers(self, self:GetStage(1) and 6.6 or 7.4)
	elseif spellId == 434089 then
		self.vb.strandsCount = self.vb.strandsCount + 1
		warnSpinneretsStrands:Show(self.vb.strandsCount)
		timerSpinneretsStrandsCD:Start(self:IsMythic() and 15.2 or (self:GetStage(2) and 25 or 20), self.vb.strandsCount+1)
		updateAllTimers(self, 5.9)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 449042 and args:IsPlayer() then
		warnRadiantLight:Show()
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and args.extraSpellId == 449734 then
		self:SetStage(2)
		timerRollingAcidCD:Start(4, self.vb.rollingCount+1)
		timerSpinneretsStrandsCD:Start(12, 1)
		if self:IsMythic() then
			timerExpelWebsCD:Start(17.3, self.vb.expelCount+1)
			timerErosiveSprayCD:Start(21.3, self.vb.sprayCount+1)--Affected by expel webs 4 second ICD
		else
			timerErosiveSprayCD:Start(20, self.vb.sprayCount+1)--Not affected by expel webs ICD
		end
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, _, _, _, _, spellId)
	if spellId == 434726 then
		self.vb.bombCount = self.vb.bombCount + 1
		warnBlazing:Show(self.vb.bombCount)
		if self.vb.bombCount == 5 then--Journal says 6, but 5 is pushing boss in all logs (including mythic)
			self:SetStage(1.5)
			--Maybe cancel timers on a later event if one found, damage events suck
			timerRollingAcidCD:Stop()
			timerErosiveSprayCD:Stop()
			timerExpelWebsCD:Stop()
			timerAcidicEruptionCD:Start(60)--60-63, give or take for boss position for lift off
		end
	end
end
--]]
