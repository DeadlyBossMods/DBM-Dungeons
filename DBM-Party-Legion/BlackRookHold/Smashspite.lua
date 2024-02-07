local mod	= DBM:NewMod(1664, "DBM-Party-Legion", 1, 740)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(98949)
mod:SetEncounterID(1834)
mod:SetUsedIcons(1)
mod:SetHotfixNoticeRev(20231027000000)
mod:SetMinSyncRevision(20231027000000)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 198073 198245",
	"SPELL_CAST_SUCCESS 198079",
	"SPELL_AURA_APPLIED 198079 198446",
	"SPELL_AURA_REMOVED 198079",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"UNIT_POWER_UPDATE boss1"
)

--TODO, maye GTFO for fire on ground (and timers and other stuff for it too maybe, seems all over place though).
--[[
(ability.id = 198073 or ability.id = 198245) and type = "begincast"
 or (ability.id = 198446 or ability.id = 198079) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnHatefulGaze				= mod:NewTargetNoFilterAnnounce(198079, 4)

local specWarnStomp					= mod:NewSpecialWarningSpell(198073, nil, nil, nil, 2, 2)
local specWarnHatefulGaze			= mod:NewSpecialWarningDefensive(198079, nil, nil, nil, 1, 2)
local yellHatefulGaze				= mod:NewYell(198079)
local specWarnBrutalHaymakerSoon	= mod:NewSpecialWarningSoon(198245, "Tank|Healer", nil, nil, 1, 2)--Face fuck soon
local specWarnBrutalHaymaker		= mod:NewSpecialWarningDefensive(198245, nil, nil, nil, 3, 2)--Incoming face fuck
local specWarnFelVomit				= mod:NewSpecialWarningMoveAway(198446, nil, nil, nil, 1, 2)
local yellFelVomit					= mod:NewYell(198446)

local timerStompCD					= mod:NewCDCountTimer(21.8, 198073, nil, nil, nil, 2)--Next timers but delayed by other casts (changed from 17 to 23 in DF)
local timerHatefulGazeCD			= mod:NewCDCountTimer(25.4, 198079, nil, nil, nil, 3)--Next timers but delayed by other casts

mod:AddInfoFrameOption(224188)
mod:AddSetIconOption("SetIconOnHatefulGaze", 198079, true, false, {1})

mod.vb.stompCount = 0
mod.vb.gazeCount = 0
local superWarned = false

function mod:OnCombatStart(delay)
	self.vb.stompCount = 0
	self.vb.gazeCount = 0
	if not self:IsNormal() then
		timerHatefulGazeCD:Start(5-delay, 1)
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(DBM:GetSpellInfo(224188))
			DBM.InfoFrame:Show(5, "reverseplayerbaddebuffbyspellid", 224188)--Must match spellID to filter other debuffs out
		end
	end
	timerStompCD:Start(12-delay, 1)
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 198073 then
		self.vb.stompCount = self.vb.stompCount + 1
		specWarnStomp:Show(self.vb.stompCount)
		specWarnStomp:Play("carefly")
		timerStompCD:Start(nil, self.vb.stompCount+1)
	elseif spellId == 198245 and not superWarned then--fallback, only 0.7 seconds warning vs 1.2 if power 100 works, but better than naught.
		superWarned = true
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnBrutalHaymaker:Show()
			specWarnBrutalHaymaker:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 198079 then
		self.vb.gazeCount = self.vb.gazeCount + 1
		timerHatefulGazeCD:Start(nil, self.vb.gazeCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 198079 then
		if args:IsPlayer() then
			specWarnHatefulGaze:Show()
			specWarnHatefulGaze:Play("targetyou")
			yellHatefulGaze:Yell()
		else
			warnHatefulGaze:Show(args.destName)
		end
		if self.Options.SetIconOnHatefulGaze then
			self:SetIcon(args.destName, 1)
		end
	elseif spellId == 198446 then
		if args:IsPlayer() then
			specWarnFelVomit:Show()
			specWarnFelVomit:Play("scatter")
			yellFelVomit:Yell()
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 198079 and self.Options.SetIconOnHatefulGaze then
		self:SetIcon(args.destName, 0)
	end
end

do
	local warnedSoon = false
	local UnitPower = UnitPower
	function mod:UNIT_POWER_UPDATE(uId)
		local power = UnitPower(uId)
		if power >= 85 and not warnedSoon then
			warnedSoon = true
			specWarnBrutalHaymakerSoon:Show()
			specWarnBrutalHaymakerSoon:Play("energyhigh")
		elseif power < 50 and warnedSoon then
			warnedSoon = false
			superWarned = false
		elseif power == 100 and not superWarned then--Doing here is about 0.5 seconds faster than SPELL_CAST_START, when it works.
			superWarned = true
			if self:IsTanking("player", "boss1", nil, true) then
				specWarnBrutalHaymaker:Show()
				specWarnBrutalHaymaker:Play("defensive")
			end
		end
	end
end
