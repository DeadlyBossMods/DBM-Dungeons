local mod	= DBM:NewMod(2569, "DBM-Party-WarWithin", 1, 1210)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(210149)
mod:SetEncounterID(2829)
mod:SetHotfixNoticeRev(20250222000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2651)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 422245",
--	"SPELL_CAST_SUCCESS 422122 422682",
--	"SPELL_AURA_APPLIED 423693",
	"SPELL_AURA_REMOVED 423693",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_RAID_WARNING",--TEMP til blizzard fixes event (if they do)
	"RAID_BOSS_WHISPER",
	"UNIT_SPELLCAST_START boss1"
)

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
local warnNewCandle							= mod:NewTargetNoFilterAnnounce(423693, 3)
local warnFixateOver						= mod:NewFadesAnnounce(423693, 1)
local warnCharge							= mod:NewTargetAnnounce(422122, 2)

local specWarnRecklessCharge				= mod:NewSpecialWarningYouCount(422122, nil, nil, nil, 2, 2)
local yellCharge							= mod:NewShortYell(422122)
local yellChargeFades						= mod:NewShortFadesYell(422122)
local specWarnRockBuster					= mod:NewSpecialWarningDefensive(422245, nil, nil, nil, 1, 2)
local specWarnCandle						= mod:NewSpecialWarningYou(423693, nil, nil, nil, 1, 2)
local yellCandle							= mod:NewShortYell(423693, nil, false)
local specWarnUnderhandedTactic				= mod:NewSpecialWarningSwitchCount(428268, "Dps", nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerUnderhandedTacticCD				= mod:NewCDCountTimer(80, 428268, nil, nil, nil, 1, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerRecklessChargeCD					= mod:NewVarCountTimer("v35.2-36.2", 422122, nil, nil, nil, 3)--Can sometimes skip casts
local timerRockBusterCD						= mod:NewVarCountTimer("v13.4-37.7", 422245, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Can also sometimes skip casts
local timerLuringCandleCD					= mod:NewCDCountTimer(38.4, 422162, nil, nil, nil, 1)

--local castsPerGUID = {}
mod.vb.chargeCount = 0
mod.vb.busterCount = 0
mod.vb.candleCount = 0
mod.vb.tacticsCount = 0

function mod:OnCombatStart(delay)
	self.vb.chargeCount = 0
	self.vb.busterCount = 0
	self.vb.candleCount = 0
	self.vb.tacticsCount = 0
	--timerRockBusterCD:Start(1.0-delay, 1)--Used right away
	timerLuringCandleCD:Start(6-delay, 1)
	timerRecklessChargeCD:Start(28-delay, 1)
	if self:IsMythic() then
		timerUnderhandedTacticCD:Start(9-delay, 1)
	end
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 422245 then
		self.vb.busterCount = self.vb.busterCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnRockBuster:Show()
			specWarnRockBuster:Play("defensive")
		end
		timerRockBusterCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 422122 then
		self.vb.chargeCount = self.vb.chargeCount + 1
		specWarnRecklessCharge:Show(self.vb.chargeCount)
		specWarnRecklessCharge:Play("chargemove")
		timerRecklessChargeCD:Start()
	end
end
--]]

--[[
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
--]]

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

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg:find("spell:428268") then
		self.vb.tacticsCount = self.vb.tacticsCount + 1
		specWarnUnderhandedTactic:Show(self.vb.tacticsCount)
		specWarnUnderhandedTactic:Play("targetchange")
		--The alternation of 48 and 32 results in old 80 timing combined
		if self.vb.tacticsCount % 2 == 0 then
			timerUnderhandedTacticCD:Start(48, self.vb.tacticsCount+1)
		else
			timerUnderhandedTacticCD:Start(32, self.vb.tacticsCount+1)
		end
	end
end
mod.CHAT_MSG_RAID_WARNING = mod.CHAT_MSG_RAID_BOSS_EMOTE

function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("spell:423693") then
		specWarnCandle:Show()
		specWarnCandle:Play("justrun")
		yellCandle:Yell()
	end
end

function mod:OnTranscriptorSync(msg, targetName)
	if msg:find("423693") and targetName and self:AntiSpam(5, targetName) then
		targetName = Ambiguate(targetName, "none")
		warnNewCandle:Show(targetName)
	end
end

do
	--UNIT target scanners don't support scanning time in a clean way
	function mod:ChargeTarget(targetname)
		if not targetname then return end
		if targetname == UnitName("player") and self:AntiSpam(5, 5) then
			specWarnRecklessCharge:Show(self.vb.chargeCount)
			specWarnRecklessCharge:Play("runout")
			yellCharge:Yell()
			yellChargeFades:Countdown(4.9)--Just subtracking .1 outright
		else
			warnCharge:Show(targetname)
		end
	end

	function mod:UNIT_SPELLCAST_START(uId, _, spellId)
		if spellId == 422116 then
			self.vb.chargeCount = self.vb.chargeCount + 1
			timerRecklessChargeCD:Start(nil, self.vb.chargeCount+1)
			self:BossUnitTargetScanner(uId, "ChargeTarget")
		elseif spellId == 422163 then
			self.vb.candleCount = self.vb.candleCount + 1
			timerLuringCandleCD:Start(nil, self.vb.candleCount+1)
		end
	end
end
