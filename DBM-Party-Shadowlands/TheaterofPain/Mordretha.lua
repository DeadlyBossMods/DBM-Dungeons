local mod	= DBM:NewMod(2417, "DBM-Party-Shadowlands", 6, 1187)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(165946)
mod:SetEncounterID(2404)
mod:SetZone(2293)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 324079 323608 324589 323683 339573 339550 339706",
	"SPELL_CAST_SUCCESS 324449",
	"SPELL_AURA_APPLIED 324449 323831",
	"SPELL_AURA_REMOVED 324449"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, interrupt Cd long enough to justify timers for up to 5 adds at once?
--https://shadowlands.wowhead.com/npc=166524/deathwalker
--[[
(ability.id = 324079 or ability.id = 323608 or ability.id = 323683 or ability.id = 339550 or ability.id = 339706 or ability.id = 339573) and type = "begincast"
 or (ability.id = 324449) and type = "cast"
--]]
local warnDeathGrasp				= mod:NewTargetNoFilterAnnounce(323831, 4)

local specWarnReapingScythe			= mod:NewSpecialWarningDefensive(324079, nil, nil, nil, 1, 2)
local specWarnDarkDevastation		= mod:NewSpecialWarningDodgeCount(323608, nil, nil, nil, 2, 2)
local specWarnManifestDeath			= mod:NewSpecialWarningMoveAway(324449, nil, nil, nil, 1, 2)
local yellManifestDeath				= mod:NewShortYell(324449)--Everyone gets, so short yell (no player names)
local yellManifestDeathFades		= mod:NewShortFadesYell(324449)
local specWarnDeathBolt				= mod:NewSpecialWarningInterrupt(324589, "HasInterrupt", nil, nil, 1, 2)
local specWarnGraspingRift			= mod:NewSpecialWarningRunCount(323685, nil, nil, nil, 4, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerReapingScytheCD			= mod:NewCDCountTimer(17, 324079, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerDarkDevastationCD		= mod:NewCDCountTimer(21.9, 323608, nil, nil, nil, 3)--21.9-26.8
local timerManifesstDeathCD			= mod:NewCDCountTimer(46.1, 324449, nil, nil, nil, 3)--46.1-52.2
local timerGraspingriftCD			= mod:NewCDCountTimer(30.4, 323685, nil, nil, nil, 3)

local timerEchoofBattleCD			= mod:NewCDCountTimer(23.5, 339550, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)--23.5-30.3
local timerGhostlyChargeCD			= mod:NewCDCountTimer(24.2, 339706, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)--24.2-31.6

mod.vb.reapingCount = 0
mod.vb.darkCount = 0
mod.vb.manifestCount = 0
mod.vb.graspingCount = 0
mod.vb.echoCount = 0
mod.vb.ghostlyCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.reapingCount = 0
	self.vb.darkCount = 0
	self.vb.manifestCount = 0
	self.vb.graspingCount = 0
	self.vb.echoCount = 0
	self.vb.ghostlyCount = 0
	timerReapingScytheCD:Start(8.1-delay, 1)
	timerDarkDevastationCD:Start(15.7-delay, 1)
	timerGraspingriftCD:Start(22.7-delay, 1)
	timerManifesstDeathCD:Start(23.9-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 324079 then
		self.vb.reapingCount = self.vb.reapingCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnReapingScythe:Show()
			specWarnReapingScythe:Play("defensive")
		end
		timerReapingScytheCD:Start(nil, self.vb.reapingCount+1)
	elseif spellId == 323608 then
		self.vb.darkCount = self.vb.darkCount + 1
		specWarnDarkDevastation:Show(self.vb.darkCount)
		specWarnDarkDevastation:Play("farfromline")
		timerDarkDevastationCD:Start(nil, self.vb.darkCount+1)
	elseif spellId == 324589 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnDeathBolt:Show(args.sourceName)
		specWarnDeathBolt:Play("kickcast")
	elseif spellId == 323683 then
		self.vb.graspingCount = self.vb.graspingCount + 1
		specWarnGraspingRift:Show(self.vb.graspingCount)
		specWarnGraspingRift:Play("justrun")
		timerGraspingriftCD:Start(nil, self.vb.graspingCount+1)
	elseif spellId == 339550 and self:AntiSpam(3, 1) then
		self.vb.echoCount = self.vb.echoCount + 1
		timerEchoofBattleCD:Start(nil, self.vb.echoCount+1)
	elseif spellId == 339706 and self:AntiSpam(3, 2) then
		self.vb.ghostlyCount = self.vb.ghostlyCount + 1
		timerGhostlyChargeCD:Start(nil, self.vb.ghostlyCount+1)
	elseif spellId == 339573 then--Echos of Carnage, Phase 2 activation
		self:SetStage(2)
		self.vb.reapingCount = 0
		self.vb.darkCount = 0
		self.vb.manifestCount = 0
		self.vb.graspingCount = 0
		self.vb.echoCount = 0
		self.vb.ghostlyCount = 0
		timerReapingScytheCD:Stop()
		timerDarkDevastationCD:Stop()
		timerGraspingriftCD:Stop()
		timerManifesstDeathCD:Stop()

		timerEchoofBattleCD:Start(7, 1)
		timerReapingScytheCD:Start(10.8, 1)
		timerGhostlyChargeCD:Start(17, 1)
		timerDarkDevastationCD:Start(18.2, 1)
		timerGraspingriftCD:Start(25.5, 1)
		timerManifesstDeathCD:Start(26.7, 1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 324449 then
		self.vb.manifestCount = self.vb.manifestCount + 1
		timerManifesstDeathCD:Start(nil, self.vb.manifestCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 324449 then
		if args:IsPlayer() then
			specWarnManifestDeath:Show()
			specWarnManifestDeath:Play("runout")
			yellManifestDeath:Yell()
			yellManifestDeathFades:Countdown(spellId)
		end
	elseif spellId == 323831 then
		warnDeathGrasp:CombinedShow(0.3, args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 324449 then
		if args:IsPlayer() then
			yellManifestDeathFades:Cancel()
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 3) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
