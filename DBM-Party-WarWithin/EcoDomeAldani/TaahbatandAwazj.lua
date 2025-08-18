local mod	= DBM:NewMod(2676, "DBM-Party-WarWithin", 10, 1303)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234933, 237514) -- Taah'bat and Awazj
mod:SetEncounterID(3108)
mod:SetHotfixNoticeRev(20250728000000)
--mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2830)
--mod.respawnTime = 29
--mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1219700 1236130 1227918 1219482",
	"SPELL_AURA_APPLIED 1219731 1219457 1236126 1219731",
	"SPELL_AURA_REMOVED_DOSE 1219457"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--TODO, nameplate timers for bosses? their abilities kind of go hand in hand so it's awkward for them
--NOTE: Blitz warp strike is spammed (1227900). Target information is unknown without transcriptor but it doesn't appear CLEU logged 1227918 is non blitz cast ID
--[[
ability.id = 1219700 and type = "begincast" or ability.id = 1219731 and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnIncorporeal					= mod:NewStackAnnounce(1219457, 1)
local warnBindingJavelin				= mod:NewTargetNoFilterAnnounce(1236130, 3)
local warnWarpStrike					= mod:NewCountAnnounce(1227918, 3)

local specWarnArcaneBlitz				= mod:NewSpecialWarningCount(1219700, nil, nil, nil, 1, 2)
--local yellWarpStrike					= mod:NewYell(1227918)
local specWarnRiftClaws					= mod:NewSpecialWarningDefensive(1219482, nil, nil, nil, 1, 2)

local timerArcaneBlitzCD				= mod:NewCDCountTimer(30, 1219700, nil, nil, nil, 6)
local timerBindingJavelinCD				= mod:NewCDCountTimer(26.7, 1236130, nil, nil, nil, 3)
local timerWarpStrikeCD					= mod:NewCDCountTimer(26.7, 1227918, nil, nil, nil, 3)
local timerRiftClawsCD					= mod:NewVarCountTimer("v23.5-26.7", 1219482, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerDestabalized					= mod:NewBuffActiveTimer(15, 1219731, nil, nil, nil, 5)

--mod:AddInfoFrameOption(445262)
--mod:AddNamePlateOption("NameplateOnReshape", 428269)

mod.vb.blitzCount = 0
mod.vb.blitzActive = false
mod.vb.javelinCount = 0
mod.vb.warpStrikeCount = 0
mod.vb.riftClawsCount = 0

function mod:OnCombatStart(delay)
	self.vb.blitzCount = 0
	self.vb.blitzActive = false
	self.vb.javelinCount = 0
	self.vb.warpStrikeCount = 0
	self.vb.riftClawsCount = 0
	timerRiftClawsCD:Start(6-delay, 1)
	timerBindingJavelinCD:Start(11.2-delay, 1)
	timerWarpStrikeCD:Start(22.1-delay, 1)
	timerArcaneBlitzCD:Start(34-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 1219700 then
		self.vb.blitzActive = true
		self.vb.blitzCount = self.vb.blitzCount + 1
		specWarnArcaneBlitz:Show(self.vb.blitzCount)
		specWarnArcaneBlitz:Play("specialsoon")
		timerBindingJavelinCD:Stop()
		timerWarpStrikeCD:Stop()
		timerRiftClawsCD:Stop()
	elseif spellId == 1236130 then
		self.vb.javelinCount = self.vb.javelinCount + 1
		timerBindingJavelinCD:Start(nil, self.vb.javelinCount+1)
	elseif spellId == 1227918 then
		self.vb.warpStrikeCount = self.vb.warpStrikeCount + 1
		warnWarpStrike:Show(self.vb.warpStrikeCount)
		timerWarpStrikeCD:Start(nil, self.vb.warpStrikeCount+1)
	elseif spellId == 1219482 then
		self.vb.riftClawsCount = self.vb.riftClawsCount + 1
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnRiftClaws:Show()
			specWarnRiftClaws:Play("defensive")
		end
		timerRiftClawsCD:Start(nil, self.vb.riftClawsCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 1219731 and self.vb.blitzActive then
		self.vb.blitzActive = false
		timerDestabalized:Start()
		timerRiftClawsCD:Start(23.6, self.vb.riftClawsCount+1)
		timerBindingJavelinCD:Start(29.9, self.vb.blitzCount+1)
		timerWarpStrikeCD:Start(40.8, self.vb.warpStrikeCount+1)
		timerArcaneBlitzCD:Start(78.6, self.vb.blitzCount+1)
	elseif spellId == 1219457 then
		warnIncorporeal:Schedule(0.5, args.destName, args.amount or 3)
	elseif spellId == 1236126 then
		warnBindingJavelin:CombinedShow(0.5, args.destName)
	end
end
mod.SPELL_AURA_REMOVED_DOSE = mod.SPELL_AURA_APPLIED

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 445262 then

	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 433067 and destGUID == UnitGUID("player") and self:AntiSpam(3, 3) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
