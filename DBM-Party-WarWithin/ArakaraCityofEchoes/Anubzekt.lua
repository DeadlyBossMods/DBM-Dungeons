local mod	= DBM:NewMod(2584, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(215405)
mod:SetEncounterID(2906)
mod:SetHotfixNoticeRev(20240630000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 435012 439506 433766",
	"SPELL_CAST_SUCCESS 433740",
	"SPELL_AURA_APPLIED 433740",
	"SPELL_AURA_REMOVED 434408"
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO: Charge also casts Impale. Eye also casts Impale AND Infestion. So Impale and Infestation timers will need enough data to separate true CDs from chained mechanics
--TODO: Target scan Burrowing Charge and impale?
--TODO, add Bloodstained Webmage on mythic, including it's web wrap
--[[
(ability.id = 435012 or ability.id = 439506 or ability.id = 433766) and type = "begincast"
 or ability.id = 433740 and type = "cast"
 or ability.id = 434408 and type = "removebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnImpale							= mod:NewCountAnnounce(433425, 3)
local warnBurrowCharge						= mod:NewCountAnnounce(439506, 3)

local specWarnInfestation					= mod:NewSpecialWarningMoveAway(433740, nil, nil, nil, 1, 2)
--local yellSomeAbility						= mod:NewYell(372107)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerImpaleCD							= mod:NewCDCountTimer(33.9, 433425, nil, nil, nil, 3)--5.8-18.2
local timerBurrowChargeCD					= mod:NewCDCountTimer(33.9, 439506, nil, nil, nil, 3)
local timerInfestationCD					= mod:NewCDCountTimer(33.9, 433740, nil, nil, nil, 3)
local timerEyeOfTheStormCD					= mod:NewCDCountTimer(33.9, 433766, nil, nil, nil, 6)

mod.vb.impaleCount = 0
mod.vb.burrowCount = 0
mod.vb.infestationCount = 0
mod.vb.eyeCount = 0
mod.vb.stormActive = false

local allTimers = {
	--Impale
	[435012] = {5.7, 14.7, 4.6},--Includes the Burrow Charge Impale
	--Infestation
	[433740] = {0, 10.7, 12.1},
}

function mod:OnCombatStart(delay)
	self.vb.impaleCount = 0
	self.vb.burrowCount = 0
	self.vb.infestationCount = 0
	self.vb.eyeCount = 0
	self.vb.stormActive = false
--	timerInfestationCD:Start(1-delay, 1)--Instantly on pull
	timerImpaleCD:Start(4.8-delay, 1)
	timerBurrowChargeCD:Start(14.2-delay, 1)
	timerEyeOfTheStormCD:Start(31.5-delay, 1)--31.5
end

--function mod:OnCombatEnd()

--end

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
				timerImpaleCD:Start(8.5, self.vb.impaleCount+1)
			end
		else
			local timer = self:GetFromTimersTable(allTimers, false, false, spellId, self.vb.impaleCount+1)
			if timer then
				timerImpaleCD:Start(timer, self.vb.impaleCount+1)
			end
		end
	elseif spellId == 439506 then
		self.vb.burrowCount = self.vb.burrowCount + 1
		warnBurrowCharge:Show(self.vb.burrowCount)
	elseif spellId == 433766 then
		self.vb.eyeCount = self.vb.eyeCount + 1
		self.vb.stormActive = true
		self.vb.impaleCount = 0
		self.vb.infestationCount = 0
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
			local timer = self:GetFromTimersTable(allTimers, false, false, spellId, self.vb.infestationCount+1)
			if timer then
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
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 434408 then--Eye of the storm ending
		self.vb.stormActive = false
		self.vb.impaleCount = 0
		self.vb.infestationCount = 0
		--Assumed loop, need actual data, pull timers used
		--timerInfestationCD:Start(1, 1)--Instantly again
		timerImpaleCD:Start(4.1, 1)
		timerBurrowChargeCD:Start(14.2, self.vb.burrowCount+1)--15
		timerEyeOfTheStormCD:Start(57.5, self.vb.eyeCount+1)
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
