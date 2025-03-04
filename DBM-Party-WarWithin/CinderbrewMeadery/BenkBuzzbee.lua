local mod	= DBM:NewMod(2588, "DBM-Party-WarWithin", 7, 1272)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(218000)
mod:SetEncounterID(2931)
mod:SetUsedIcons(8, 7, 6)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2661)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 438025 440134 439524",
--	"SPELL_SUMMON 438665",
	"SPELL_AURA_APPLIED 440134 443983",
	"SPELL_AURA_REMOVED 440134 443983",
	"SPELL_PERIODIC_DAMAGE 440141",
	"SPELL_PERIODIC_MISSED 440141"
--	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, UNIT_DIED doesnt actually fire for bees and neither does Bee-Haw!, we're gonna need a UNIT_SPELLCAST event probably
--[[
(ability.id = 438025 or ability.id = 441410 or ability.id = 440134 or ability.id = 439524) and type = "begincast"
 or (ability.id = 438665 or ability.id = 438651) and type = "summon"
 or target.id = 218016 and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 438971 and type = "begincast"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
--]]
local warnSnackTime							= mod:NewCountAnnounce(438025, 3)
local warnHoneymarinade						= mod:NewTargetAnnounce(440134, 2)

local specWarnHoneyMarinade					= mod:NewSpecialWarningMoveAway(440134, nil, nil, nil, 1, 2)
local specWarnHoneyGorged					= mod:NewSpecialWarningMove(443983, nil, nil, nil, 1, 2, 4)
local yellHoneyMarinade						= mod:NewShortYell(440134)
local yellHoneyMarinadeFades				= mod:NewShortFadesYell(440134)
local specWarnFlutteringWing				= mod:NewSpecialWarningCount(439524, nil, nil, nil, 1, 13)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(440141, nil, nil, nil, 1, 8)

local timerSnackTimeCD						= mod:NewNextCountTimer(33, 438025, nil, nil, nil, 3)--33
--local timerShreddingStingCD				= mod:NewCDNPTimer(6, 438971, nil, nil, nil, 3, nil, DBM_COMMON_L.BLEED_ICON)--6-7.2 confirmed on normal
local timerHoneyMarinadeCD					= mod:NewVarCountTimer("v11-18", 440134, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerFlutteringWingCD					= mod:NewNextCountTimer(25, 439524, nil, nil, nil, 2)

mod:AddNamePlateOption("NPOnHoney", 443983)
--mod:AddSetIconOption("SetIconOnBees", 438025, true, 5, {8, 7, 6})

--local castsPerGUID = {}

mod.vb.snackCount = 0
mod.vb.honeyCount = 0
mod.vb.fluteringCount = 0
mod.vb.addIcon = 8

function mod:OnCombatStart(delay)
	self.vb.snackCount = 0
	self.vb.honeyCount = 0
	self.vb.fluteringCount = 0
	timerSnackTimeCD:Start(3, 1)
	timerHoneyMarinadeCD:Start(10, 1)
	timerFlutteringWingCD:Start(22, 1)
	if self.Options.NPOnHoney then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	if self.Options.NPOnHoney then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 438025 then
		self.vb.snackCount = self.vb.snackCount + 1
		self.vb.addIcon = 8
		warnSnackTime:Show(self.vb.snackCount)
		timerSnackTimeCD:Start(nil, self.vb.snackCount+1)
	--elseif spellId == 438971 or spellId == 441410 then--438971 confirmed on normal, 441410 unknown
	--	timerShreddingStingCD:Start(nil, args.sourceGUID)
	elseif spellId == 440134 then
		self.vb.honeyCount = self.vb.honeyCount + 1
		--"Honey Marinade-440134-npc:218002-000034E471 = pull:10.0, 16.0, 16.0, 16.0, 18.0, 14.0, 16.0, 20.0, 11.9",
		timerHoneyMarinadeCD:Start(nil, self.vb.honeyCount+1)
	elseif spellId == 439524 then
		self.vb.fluteringCount = self.vb.fluteringCount + 1
		specWarnFlutteringWing:Show(self.vb.fluteringCount)
		specWarnFlutteringWing:Play("pushbackincoming")
		timerFlutteringWingCD:Start(nil, self.vb.fluteringCount+1)
	end
end

--[[
--event now hidden
function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 438665 then
		if self.Options.SetIconOnBees then
			self:ScanForMobs(args.destGUID, 2, self.vb.addIcon, 1, nil, 12, "SetIconOnBees")
		end
		self.vb.addIcon = self.vb.addIcon - 1
		--timerShreddingStingCD:Start(4, args.destGUID)
	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 440134 then
		if args:IsPlayer() then
			specWarnHoneyMarinade:Show()
			specWarnHoneyMarinade:Play("scatter")
			yellHoneyMarinade:Yell()
			yellHoneyMarinadeFades:Countdown(spellId)
		else
			warnHoneymarinade:Show(args.destName)
		end
	elseif spellId == 443983 then
		if self:IsTanking("player", "boss1", nil, true) then
			--If tanking boss, you're the tank, you have to move the add
			specWarnHoneyGorged:Show()
			specWarnHoneyGorged:Play("moveboss")
		end
		if self.Options.NPOnHoney then
			DBM.Nameplate:Show(true, args.destGUID, spellId)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 440134 then
		if args:IsPlayer() then
			yellHoneyMarinadeFades:Cancel()
		end
	elseif spellId == 443983 then
		if self.Options.NPOnHoney then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 440141 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 218016 then--Ravenous Cinderbee
		--timerShreddingStingCD:Stop(args.destGUID)
	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
