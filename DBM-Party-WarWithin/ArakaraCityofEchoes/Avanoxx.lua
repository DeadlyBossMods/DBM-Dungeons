local mod	= DBM:NewMod(2583, "DBM-Party-WarWithin", 6, 1271)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(213179)
mod:SetEncounterID(2926)
mod:SetUsedIcons(1, 2, 3, 4)
mod:SetHotfixNoticeRev(20240630000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 438471 438476 438473",
--	"SPELL_CAST_SUCCESS",
	"SPELL_SUMMON 439040",
	"SPELL_AURA_APPLIED 446794 439070 436614",
	"SPELL_AURA_APPLIED_DOSE 446794 434830"
--	"SPELL_AURA_REMOVED"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, if higher difficulties kill adds instead of CC/control them, swap to 8-5 icons instead of 1-4
--TODO, longer pulls to complete timer set?
--[[
(ability.id = 438471 or ability.id = 438476 or ability.id = 438473) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnInsatiable						= mod:NewStackAnnounce(446794, 4)
local warnAlertingShrill					= mod:NewCountAnnounce(438476, 2)
local warnGossamerOnsalught					= mod:NewCountAnnounce(438473, 2)
local warnVileWebbing						= mod:NewCountAnnounce(434830, 3, nil, nil, DBM_CORE_L.AUTO_ANNOUNCE_OPTIONS.stack:format(434830))--Player
local warnWebWrap							= mod:NewTargetNoFilterAnnounce(436614, 2, nil, "RemoveMagic")

local specWarnVoraciousBite					= mod:NewSpecialWarningDefensive(438471, nil, nil, nil, 1, 2)
local specWarnHunger						= mod:NewSpecialWarningRun(439070, nil, nil, nil, 1, 2)
--local yellSomeAbility						= mod:NewYell(372107)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerVoraciousBiteCD					= mod:NewCDCountTimer(14.5, 438471, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerAlertingShrillCD					= mod:NewCDCountTimer(38.7, 438476, nil, nil, nil, 1)--38.7-40.1
local timerGossamerOnslaughtCD				= mod:NewCDCountTimer(38.7, 438473, nil, nil, nil, 3)--38.7-40.1

mod:AddSetIconOption("SetIconOnAdds", 438476, true, 5, {1, 2, 3, 4})

mod.vb.biteCount = 0
mod.vb.shrillCount = 0
mod.vb.onslaughtCount = 0
mod.vb.mobIcon = 1

function mod:OnCombatStart(delay)
	self.vb.biteCount = 0
	self.vb.shrillCount = 0
	self.vb.onslaughtCount = 0
	self.vb.mobIcon = 1
	timerVoraciousBiteCD:Start(3.3-delay, 1)
	timerAlertingShrillCD:Start(10.6-delay, 1)
	timerGossamerOnslaughtCD:Start(30.0-delay, 1)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 438471 then
		self.vb.biteCount = self.vb.biteCount + 1
		timerVoraciousBiteCD:Start(nil, self.vb.biteCount+1)
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnVoraciousBite:Show()
			specWarnVoraciousBite:Play("defensive")
		end
	elseif spellId == 438476 then
		self.vb.mobIcon = 1
		self.vb.shrillCount = self.vb.shrillCount + 1
		warnAlertingShrill:Show(self.vb.shrillCount)
		timerAlertingShrillCD:Start(nil, self.vb.shrillCount+1)
	elseif spellId == 438473 then
		self.vb.onslaughtCount = self.vb.onslaughtCount + 1
		warnGossamerOnsalught:Show(self.vb.onslaughtCount)
		timerGossamerOnslaughtCD:Start(nil, self.vb.onslaughtCount+1)
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 372858 then

	end
end
--]]

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 439040 then
		if self.Options.SetIconOnAdds then
			self:ScanForMobs(args.destGUID, 2, self.vb.mobIcon, 1, nil, 12, "SetIconOnAdds")
		end
		self.vb.mobIcon = self.vb.mobIcon + 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 446794 then
		warnInsatiable:Cancel()
		warnInsatiable:Schedule(1, args.destName, args.amount or 1)
	elseif spellId == 439070 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnHunger:Show()
		specWarnHunger:Play("justrun")
	elseif spellId == 434830 and args:IsPlayer() then
		if (args.amount % 3 == 0) or args.amount >= 8 then
			warnVileWebbing:Show(args.amount)
		end
	elseif spellId == 436614 then
		warnWebWrap:Show(args.destName)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

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
