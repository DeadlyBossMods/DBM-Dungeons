local mod	= DBM:NewMod(2584, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(215405)
mod:SetEncounterID(2906)
mod:SetHotfixNoticeRev(20240817000000)
mod:SetMinSyncRevision(20240817000000)
mod:SetZone(2660)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:AddPrivateAuraSoundOption(433740, true, 433740, 1)

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(433740, "runout", 2)
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 435012 439506 433766 442210",
	"SPELL_CAST_SUCCESS 433740",
	"SPELL_AURA_APPLIED 433740",
	"SPELL_AURA_REMOVED 434408 433740"
)
--]]
--[[
(ability.id = 435012 or ability.id = 439506 or ability.id = 433766) and type = "begincast"
 or ability.id = 433740 and type = "cast"
 or ability.id = 434408 and type = "removebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 442210 and (type = "begincast" or type = "cast") or stoppedAbility.id = 442210
--]]
--[[
local warnImpale							= mod:NewCountAnnounce(433425, 3)
local warnBurrowCharge						= mod:NewCountAnnounce(439506, 3)

local specWarnInfestation					= mod:NewSpecialWarningMoveAway(433740, nil, nil, nil, 1, 2)
local yellInfestation						= mod:NewShortYell(433740)
local yellInfestationFades					= mod:NewShortFadesYell(433740)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)
local specWarnSilkenRestraints				= mod:NewSpecialWarningInterrupt(442210, "HasInterrupt", nil, nil, 1, 2, 4)

local timerImpaleCD							= mod:NewCDCountTimer(33.9, 433425, nil, nil, nil, 3)--5.8-18.2
local timerBurrowChargeCD					= mod:NewCDCountTimer(33.9, 439506, nil, nil, nil, 3)
local timerInfestationCD					= mod:NewCDCountTimer(33.9, 433740, nil, nil, nil, 3)
local timerEyeOfTheStormCD					= mod:NewCDCountTimer(33.9, 433766, nil, nil, nil, 6)

mod.vb.timerSet = 1
mod.vb.impaleCount = 0
mod.vb.burrowCount = 0
mod.vb.infestationCount = 0
mod.vb.eyeCount = 0
mod.vb.stormActive = false

--Technically table can be avoided, since
--infestation is just 3 or 4 casts of 10.0-10.8
--and Impale is alternating 4.8 and 14.7
--but it's here for future proofing and just tidier
local allTimers = {
	--Initial set
	[1] = {
		--Impale
		[435012] = {4.8, 12.2, 4.6},--Includes the Burrow Charge Impale
		--Infestation
		[433740] = {0.000001, 10.0, 10.8},--Can queue up to 13, usually 3rd cast is 12.2 but can also be lower
	},
	--2nd set and beyond
	[2] = {
		--Impale
		[435012] = {5.3, 14.7, 4.6, 14.5},--Includes the Burrow Charge Impale
		--Infestation
		[433740] = {0.000001, 10.9, 10.8, 10.8},--Can queue up to 13, usually 3rd cast is 12.2 but can also be lower
	}
}

function mod:OnCombatStart(delay)
	self.vb.timerSet = 1
	self.vb.impaleCount = 0
	self.vb.burrowCount = 0
	self.vb.infestationCount = 0
	self.vb.eyeCount = 0
	self.vb.stormActive = false
	timerImpaleCD:Start(4.4-delay, 1)
	timerBurrowChargeCD:Start(14.2-delay, 1)
	timerEyeOfTheStormCD:Start(30.7-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 435012 then
		self.vb.impaleCount = self.vb.impaleCount + 1
		warnImpale:Show(self.vb.impaleCount)
		--if self:IsTanking("player", "boss1", nil, true) then
		--	specWarnImpale:Show()
		--	specWarnImpale:Play("defensive")
		--end
		if self.vb.stormActive then
			--Cast 3x per storm at static interval
			if self.vb.impaleCount < 3 then
				timerImpaleCD:Start(4, self.vb.impaleCount+1)--(old 8.5-8.8)
			end
		else
			local timer = self:GetFromTimersTable(allTimers, false, self.vb.timerSet, spellId, self.vb.impaleCount+1)
			if timer and timer > 0 then
				timerImpaleCD:Start(timer, self.vb.impaleCount+1)
			end
		end
	elseif spellId == 439506 then
		self.vb.burrowCount = self.vb.burrowCount + 1
		warnBurrowCharge:Show(self.vb.burrowCount)
	elseif spellId == 442210 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSilkenRestraints:Show(args.sourceName)
		specWarnSilkenRestraints:Play("kickcast")
	elseif spellId == 433766 then
		self.vb.eyeCount = self.vb.eyeCount + 1
		self.vb.stormActive = true
		self.vb.impaleCount = 0
		self.vb.infestationCount = 0
		if self.vb.timerSet == 1 then
			self.vb.timerSet = 2
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 433740 then
		self.vb.infestationCount = self.vb.infestationCount + 1
		if self.vb.stormActive then
			--Cast 3x per storm at static interval
			if self.vb.infestationCount < 3 then
				timerInfestationCD:Start(8.5, self.vb.infestationCount+1)
			end
		else
			local timer = self:GetFromTimersTable(allTimers, false, self.vb.timerSet, spellId, self.vb.infestationCount+1)
			if timer and timer > 0 then
				timerInfestationCD:Start(timer, self.vb.infestationCount+1)
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 433740 and args:IsPlayer() then
		specWarnInfestation:Show()
		specWarnInfestation:Play("runout")
		yellInfestation:Yell()
		yellInfestationFades:Countdown(spellId)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 434408 then--Eye of the storm ending
		self.vb.stormActive = false
		self.vb.impaleCount = 0
		self.vb.infestationCount = 0
		--timerInfestationCD:Start(1, 1)--Instantly again
		timerImpaleCD:Stop()
		timerImpaleCD:Start(4.1, 1)
		timerBurrowChargeCD:Start(15, self.vb.burrowCount+1)
		timerEyeOfTheStormCD:Start(46.6, self.vb.eyeCount+1)
	elseif spellId == 433740 then
		if args:IsPlayer() then
			yellInfestationFades:Cancel()
		end
	end
end
--]]
