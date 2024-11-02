local mod	= DBM:NewMod(2569, "DBM-Party-WarWithin", 1, 1210)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(210149)
mod:SetEncounterID(2829)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2651)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 421665",
	"SPELL_CAST_SUCCESS 422122 422682",
	"SPELL_AURA_APPLIED 423693",
	"SPELL_AURA_REMOVED 423693"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, need to see and transcribe fight for actual add spawn mechanics to be captured properly
--TODO, https://www.wowhead.com/beta/spell=428268/underhanded-track-tics for mythic
--Note, actual fixate cast is not in combat log, only applied
--[[
ability.id = 421665 and type = "begincast"
or ability.id = 422122 and type = "cast"
 or ability.id = 423693 and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 181113 and type = "cast"
 or (source.type = "NPC" and source.firstSeen = timestamp) or (target.type = "NPC" and target.firstSeen = timestamp)
--]]
local warnNewMobs							= mod:NewCountAnnounce(421875, 3)
local warnFixate							= mod:NewTargetNoFilterAnnounce(423693, 3)
local warnFixateOver						= mod:NewFadesAnnounce(423693, 1)

local specWarnRecklessCharge				= mod:NewSpecialWarningCount(422122, nil, nil, nil, 2, 2)
local specWarnRockBuster					= mod:NewSpecialWarningDefensive(421665, nil, nil, nil, 1, 2)
local specWarnFixate						= mod:NewSpecialWarningYou(423693, nil, nil, nil, 1, 2)
local yellFixate							= mod:NewYell(423693)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerRecklessChargeCD					= mod:NewAITimer(33.9, 422122, nil, nil, nil, 3)
local timerRockBusterCD						= mod:NewAITimer(33.9, 421665, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerNewMobsCD						= mod:NewAITimer(15, 421875, nil, nil, nil, 1)--15 except after a charge then 20? need more data
--local timerFixateCD						= mod:NewAITimer(38.9, 423693, nil, nil, nil, 3)

--local castsPerGUID = {}
mod.vb.chargeCount = 0
mod.vb.busterCount = 0
mod.vb.addsCount = 0

function mod:OnCombatStart(delay)
	self.vb.chargeCount = 0
	self.vb.busterCount = 0
	self.vb.addsCount = 0
	timerRecklessChargeCD:Start(1-delay)
	timerRockBusterCD:Start(1-delay)
	--timerNewMobsCD:Start(1-delay)--Called instantly on pull
	--timerFixateCD:Start(12.1-delay)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 421665 then
		self.vb.busterCount = self.vb.busterCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnRockBuster:Show()
			specWarnRockBuster:Play("defensive")
		end
		timerRockBusterCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 422122 then
		self.vb.chargeCount = self.vb.chargeCount + 1
		specWarnRecklessCharge:Show(self.vb.chargeCount)
		specWarnRecklessCharge:Play("chargemove")
		timerRecklessChargeCD:Start()
	elseif spellId == 422682 and self:AntiSpam(6, 1) then--Crude Weapons
		self.vb.addsCount = self.vb.addsCount + 1
		warnNewMobs:Show(self.vb.addsCount)
		timerNewMobsCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 423693 then
		if args:IsPlayer() then
			specWarnFixate:Show()
			specWarnFixate:Play("runaway")--Or record custom one later that's more descriptive
			yellFixate:Yell()
		else
			warnFixate:Show(args.destName)
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 423693 then
		if args:IsPlayer() then
			warnFixateOver:Show()
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
