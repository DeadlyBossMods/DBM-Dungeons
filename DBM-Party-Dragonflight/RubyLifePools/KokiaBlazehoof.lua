local mod	= DBM:NewMod(2485, "DBM-Party-Dragonflight", 7, 1202)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(189232)
mod:SetEncounterID(2609)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 372107 372863 373017 373087 384823",
	"SPELL_CAST_SUCCESS 372858",
	"SPELL_AURA_APPLIED 372858",
--	"SPELL_AURA_REMOVED"
	"SPELL_PERIODIC_DAMAGE 372820",
	"SPELL_PERIODIC_MISSED 372820",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, track https://www.wowhead.com/beta/spell=372860/searing-wounds stacks? there isn't a tank swap so it feels like something that naturally falls off somehow
--TODO, verify Molten Boulder target scan
--[[
(ability.id = 372107 or ability.id = 372863) and type = "begincast"
 or ability.id = 372858 and type = "cast"
 or (ability.id = 373017 or ability.id = 373087) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnBurnout								= mod:NewCastAnnounce(373087, 4)
local warnInferno								= mod:NewCastAnnounce(384823, 3)
local warnBaitBoulder							= mod:NewBaitAnnounce(372107, 3, nil, nil, nil, nil, 8)
local warnBaitAdd								= mod:NewBaitAnnounce(372863, 3, nil, false, 2, nil, 8)

local specWarnSearingBlows						= mod:NewSpecialWarningDefensive(372858, nil, nil, nil, 1, 2)
local specWarnMoltenBoulder						= mod:NewSpecialWarningDodgeCount(372107, nil, nil, nil, 1, 2)
local yellMoltenBoulder							= mod:NewYell(372107)
local specWarnRitualofBlazebinding				= mod:NewSpecialWarningSwitchCount(372863, nil, nil, nil, 1, 2)
local specWarnRoaringBlaze						= mod:NewSpecialWarningInterruptCount(373017, "HasInterrupt", nil, 2, 1, 2)
local specWarnBurnout							= mod:NewSpecialWarningRun(373087, "Melee", nil, nil, 4, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerSearingBlowsCD						= mod:NewCDTimer(32.7, 372858, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.HEALER_ICON)
local timerMoltenBoulderCD						= mod:NewCDCountTimer(16.9, 372107, nil, nil, nil, 3)
local timerRitualofBlazebindingCD				= mod:NewCDCountTimer(33.9, 372863, nil, nil, nil, 1)

local castsPerGUID = {}

mod.vb.ritualCount = 0
mod.vb.boulderCount = 0
mod.vb.addsAlive = 0

function mod:BoulderTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellMoltenBoulder:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.ritualCount = 0
	self.vb.boulderCount = 0
	self.vb.addsAlive = 0
	table.wipe(castsPerGUID)
	timerRitualofBlazebindingCD:Start(6.9-delay, 1)
	timerMoltenBoulderCD:Start(14.2-delay, 1)
	timerSearingBlowsCD:Start(21.4-delay)
end

function mod:OnCombatEnd()
	table.wipe(castsPerGUID)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 372107 then
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "BoulderTarget", 0.1, 8, true)
		self.vb.boulderCount = self.vb.boulderCount + 1
		specWarnMoltenBoulder:Show(self.vb.boulderCount)
		specWarnMoltenBoulder:Play("shockwave")
		timerMoltenBoulderCD:Start(nil, self.vb.boulderCount+1)
		warnBaitBoulder:ScheduleVoice(13.4, "bait")--3.5 seconds before
	elseif spellId == 372863 then
		self.vb.ritualCount = self.vb.ritualCount + 1
		specWarnRitualofBlazebinding:Show(self.vb.ritualCount)
		specWarnRitualofBlazebinding:Play("killmob")
		timerRitualofBlazebindingCD:Start(nil, self.vb.ritualCount+1)
		warnBaitAdd:ScheduleVoice(29.2, "bait")--3.5 seconds before
	elseif spellId == 373017 then
		if not castsPerGUID[args.sourceGUID] then
			castsPerGUID[args.sourceGUID] = 0
			self.vb.addsAlive = self.vb.addsAlive + 1
		end
		castsPerGUID[args.sourceGUID] = castsPerGUID[args.sourceGUID] + 1
		local count = castsPerGUID[args.sourceGUID]
		--Scope it to only target/focus if more than 1 add is up else no scoping
		if self.vb.addsAlive <= 1 or self:CheckInterruptFilter(args.sourceGUID, false, false) then
			specWarnRoaringBlaze:Show(args.sourceName, count)
			if count == 1 then
				specWarnRoaringBlaze:Play("kick1r")
			elseif count == 2 then
				specWarnRoaringBlaze:Play("kick2r")
			elseif count == 3 then
				specWarnRoaringBlaze:Play("kick3r")
			elseif count == 4 then
				specWarnRoaringBlaze:Play("kick4r")
			elseif count == 5 then
				specWarnRoaringBlaze:Play("kick5r")
			else
				specWarnRoaringBlaze:Play("kickcast")
			end
		end
	elseif spellId == 373087 then
		if self.Options.SpecWarn373087run then
			specWarnBurnout:Show()
			specWarnBurnout:Play("justrun")
		else
			warnBurnout:Show()
		end
	elseif spellId == 384823 then
		warnInferno:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 372858 then
		timerSearingBlowsCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 372858 then
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSearingBlows:Show()
			specWarnSearingBlows:Play("defensive")
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 189886 then--Blazebound Firestorm
		if self.vb.addsAlive > 0 then
			self.vb.addsAlive = self.vb.addsAlive - 1
		end
	end
end