local mod	= DBM:NewMod(2579, "DBM-Party-WarWithin", 4, 1269)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(210156)
mod:SetEncounterID(2880)
mod:SetUsedIcons(8, 7, 6, 5)
mod:SetHotfixNoticeRev(20240428000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 422233 423200 423538",
	"SPELL_CAST_SUCCESS 443494",
	"SPELL_SUMMON 422261",
	"SPELL_AURA_APPLIED 423228 423246",
	"SPELL_AURA_REMOVED 423228 423246"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE: No need to annouce void discharge, it's just a passive mechanic of FortifiedShell
--TODO, personal warnings for https://www.wowhead.com/beta/spell=435813/void-empowerment ?
--TODO, custom infoframe that shows all player void empowerment stacks AND shield remaining?
--[[
(ability.id = 422233 or ability.id = 423200 or ability.id = 423538) and type = "begincast"
 or ability.id = 443494 and type = "cast"
 or ability.id = 422261
 or (ability.id = 423228 or ability.id = 423246) and (type = "applybuff" or type = "applydebuff" or type = "removebuff" or type = "removedebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnCrystallineEruption				= mod:NewCountAnnounce(443494, 3)
local warnFortifiedShell					= mod:NewCountAnnounce(423200, 2)
local warnShatteredShell					= mod:NewTargetNoFilterAnnounce(423246, 1)

local specWarnCrystallineSmash				= mod:NewSpecialWarningDefensive(422233, nil, nil, nil, 1, 2)
local specWarnCrystallineShard				= mod:NewSpecialWarningSwitchCount(422261, "-Healer", nil, nil, 1, 2)
local specWarnUnstableCrash					= mod:NewSpecialWarningDodgeCount(423538, "-Healer", nil, nil, 1, 2)
--local yellSomeAbility						= mod:NewYell(372107)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerCrystallineSmashCD				= mod:NewCDCountTimer(16.6, 422233, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DAMAGE_ICON)--One timer for smash and shards
local timerUnstableCrashCD					= mod:NewCDCountTimer(19.4, 423538, nil, nil, nil, 3)
local timerFortifiedShellCD					= mod:NewCDCountTimer(40, 423200, nil, nil, nil, 6)

mod:AddSetIconOption("SetIconOnShards", 422261, true, 5, {8, 7, 6, 5})
mod:AddInfoFrameOption(423228)

mod.vb.addIcon = 8
mod.vb.smashCount = 0
mod.vb.eruptionCount = 0
mod.vb.unstablecrashCount = 0
mod.vb.FortifiedShellCount = 0

function mod:OnCombatStart(delay)
	self.vb.smashCount = 0
	self.vb.eruptionCount = 0
	self.vb.unstablecrashCount = 0
	self.vb.FortifiedShellCount = 0
	timerCrystallineSmashCD:Start(3.2-delay, 1)
	timerUnstableCrashCD:Start(10.5-delay, 1)
	timerFortifiedShellCD:Start(37.2-delay, 1)
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 422233 then
		self.vb.addIcon = 8
		self.vb.eruptionCount = 0
		self.vb.smashCount = self.vb.smashCount + 1
		--Timers for next odd are startd in phasing
		if self.vb.smashCount % 2 == 1 then
			timerCrystallineSmashCD:Start(nil, self.vb.smashCount+1)
		end
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnCrystallineSmash:Show()
			specWarnCrystallineSmash:Play("defensive")
		end
	elseif spellId == 423200 then
		self.vb.FortifiedShellCount = self.vb.FortifiedShellCount + 1
		warnFortifiedShell:Show(self.vb.FortifiedShellCount)
		timerCrystallineSmashCD:Stop()
		timerUnstableCrashCD:Stop()
	elseif spellId == 423538 then
		self.vb.unstablecrashCount = self.vb.unstablecrashCount + 1
		specWarnUnstableCrash:Show(self.vb.unstablecrashCount)
		specWarnUnstableCrash:Play("watchstep")
		if self.vb.unstablecrashCount % 2 == 1 then
			timerUnstableCrashCD:Start(nil, self.vb.unstablecrashCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 443494 then
		self.vb.eruptionCount = self.vb.eruptionCount + 1
		warnCrystallineEruption:Show(self.vb.eruptionCount)
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 422261 then
		if self:AntiSpam(3, 1) then
			specWarnCrystallineShard:Show(self.vb.smashCount)
			specWarnCrystallineShard:Play("targetchange")
		end
		if self.Options.SetIconOnShards then
			self:ScanForMobs(args.destGUID, 2, self.vb.addIcon, 1, nil, 12, "SetIconOnShards")
		end
		self.vb.addIcon = self.vb.addIcon - 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 423228 then
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	elseif spellId == 423246 then
		warnShatteredShell:Show(args.destName)
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 423228 then--Crumbling Shell
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	elseif spellId == 423246 then--Shattered Shell
		timerCrystallineSmashCD:Start(5, self.vb.smashCount+1)
		timerUnstableCrashCD:Start(12.2, self.vb.unstablecrashCount+1)
		timerFortifiedShellCD:Start(38.9, self.vb.FortifiedShellCount+1)
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
