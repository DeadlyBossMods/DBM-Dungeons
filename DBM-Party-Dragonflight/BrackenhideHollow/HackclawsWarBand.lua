local mod	= DBM:NewMod(2471, "DBM-Party-Dragonflight", 1, 1196)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186122, 186124, 186125)
mod:SetEncounterID(2570)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20221205000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 381694 378029 381470 377950 378208",
	"SPELL_CAST_SUCCESS 377965",
	"SPELL_AURA_APPLIED 381461 381835 381835 377844 381387 381379 378229 381466",
	"UNIT_DIED"
)

--TODO, two version of decayed senses, which used? Both?
--TODO, add https://www.wowhead.com/beta/spell=378155/earth-bolt ?
--TODO, Target scan mark of butchery? no debuff
--[[
(ability.id = 381694 or ability.id = 378029 or ability.id = 381470 or ability.id = 377950 or ability.id = 378208) and type = "begincast"
 or ability.id = 377965 and type = "cast"
 or (ability.id = 381461 or ability.id = 381835) and type = "applydebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Rira Hackclaw
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24732))
local warnSavageCharge							= mod:NewTargetNoFilterAnnounce(381461, 4)
local warnBladestorm							= mod:NewTargetNoFilterAnnounce(377827, 3)

local specWarnSavageCharge						= mod:NewSpecialWarningYou(381461, nil, nil, nil, 1, 2)
local yellSavageCharge							= mod:NewYell(381461)
local specWarnSavageChargeTarget				= mod:NewSpecialWarningTarget(381461, nil, nil, nil, 1, 2)

local timerSavageChargeCD						= mod:NewCDTimer(59.4, 381461, nil, nil, nil, 3, nil, DBM_COMMON_L.TANK_ICON)
local timerBladestormCD							= mod:NewCDTimer(59.4, 377827, nil, nil, nil, 3)
--Gashtooth
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24733))
local warnMarkedforButchery						= mod:NewTargetCountAnnounce(378229, 4, nil, "Healer", nil, nil, nil, nil, true)

local specWarnDecayedSenses						= mod:NewSpecialWarningDispel(381379, "RemoveMagic", nil, nil, 1, 2)
local specWarnGashFrenzy						= mod:NewSpecialWarningCount(378029, "Healer", nil, nil, 2, 2)
local specWarnMarkedforButchery					= mod:NewSpecialWarningDefensive(378229, nil, nil, nil, 1, 2)

local timerDecayedSensesCD						= mod:NewCDTimer(59.4, 381379, nil, nil, nil, 3)
local timerGashFrenzyCD							= mod:NewCDCountTimer(59.4, 378029, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.BLEED_ICON)
local timerMarkedforButcheryCD					= mod:NewCDCountTimer(59.5, 378229, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
--Tricktotem
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24734))
local warnHextrick								= mod:NewTargetNoFilterAnnounce(381466, 3)
local warnBloodlust								= mod:NewSpellAnnounce(377965, 3)

local specWarnHextrickTotem						= mod:NewSpecialWarningSwitch(381470, "-Healer", nil, nil, 1, 2)
local specWarnGreaterHealingRapids				= mod:NewSpecialWarningInterrupt(377950, "HasInterrupt", nil, nil, 1, 2)

local timerHexrickTotemCD						= mod:NewCDTimer(59.4, 381470, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerGreaterHealingRapidsCD				= mod:NewCDCountTimer(15.7, 377950, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

mod.vb.healingRapidsCount = 0
mod.vb.frenzyCount = 0
mod.vb.markedCount = 0

local function scanBosses(self, delay)
	for i = 1, 3 do
		local unitID = "boss"..i
		if UnitExists(unitID) then
			local cid = self:GetUnitCreatureId(unitID)
			local bossGUID = UnitGUID(unitID)
			if cid == 186122 then--Rira Hackclaw
				timerBladestormCD:Start(19.2-delay, bossGUID)
				timerSavageChargeCD:Start(48.3-delay, bossGUID)
			elseif cid == 186124 then--Gashtooth
				timerGashFrenzyCD:Start(2.4-delay, 1, bossGUID)
				timerDecayedSensesCD:Start(45.8-delay, bossGUID)
				if self:IsMythic() then
					timerMarkedforButcheryCD:Start(12.1-delay, 1, bossGUID)
				end
			else--Tricktotem
				timerGreaterHealingRapidsCD:Start(10.7-delay, 1, bossGUID)
				timerHexrickTotemCD:Start(44.8-delay, bossGUID)
			end
		end
	end
end

function mod:MarkedTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnMarkedforButchery:Show()
		specWarnMarkedforButchery:Play("defensive")
	else
		warnMarkedforButchery:Show(self.vb.markedCount, targetname)
	end
end

function mod:OnCombatStart(delay)
	self.vb.healingRapidsCount = 0
	self.vb.frenzyCount = 0
	self.vb.markedCount = 0
	self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss guids
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 381694 then
		timerDecayedSensesCD:Start(nil, args.sourceGUID)
	elseif spellId == 378029 then
		self.vb.frenzyCount = self.vb.frenzyCount + 1
		specWarnGashFrenzy:Show(self.vb.frenzyCount)
		specWarnGashFrenzy:Play("healfull")
		timerGashFrenzyCD:Start(nil, self.vb.frenzyCount+1, args.sourceGUID)
	elseif spellId == 381470 then
		specWarnHextrickTotem:Show()
		specWarnHextrickTotem:Play("attacktotem")
		timerHexrickTotemCD:Start(nil, args.sourceGUID)
	elseif spellId == 377950 then
		self.vb.healingRapidsCount = self.vb.healingRapidsCount + 1
		--12, 23, 20.6, 15.7
		--12, 21.8, 21.8, 15.8, 21.8, 21.8
		--12, 21.8, 21.8, 15.8, 21.8, 21.8, 15.8
		if self.vb.healingRapidsCount % 3 == 0 then
			timerGreaterHealingRapidsCD:Start(15.8, self.vb.healingRapidsCount+1, args.sourceGUID)
		else
			timerGreaterHealingRapidsCD:Start(19.4, self.vb.healingRapidsCount+1, args.sourceGUID)
		end
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGreaterHealingRapids:Show(args.sourceName)
			specWarnGreaterHealingRapids:Play("kickcast")
		end
	elseif spellId == 378208 then
		self.vb.markedCount = self.vb.markedCount + 1
		timerMarkedforButcheryCD:Start(nil, self.vb.markedCount+1, args.sourceGUID)
		self:BossTargetScanner(args.sourceGUID, "MarkedTarget", 0.2, 8, true, nil, nil, nil, true)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 377965 then
		warnBloodlust:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 381461 then
		if args:IsPlayer() then
			specWarnSavageCharge:Show()
			specWarnSavageCharge:Play("targetyou")
			yellSavageCharge:Yell()
		elseif self:IsTank() then
			specWarnSavageChargeTarget:Show(args.destName)
			specWarnSavageChargeTarget:Play("helpsoak")
		else
			warnSavageCharge:Show(args.destName)
		end
--		timerSavageChargeCD:Start()
	elseif args:IsSpellID(381835, 377844) then--381835 initial, 377844 target swaps
		if spellId == 381835 then
			timerBladestormCD:Start(nil, args.sourceGUID)
		end
		warnBladestorm:Show(args.destName)
	elseif args:IsSpellID(381387, 381379) and args:IsDestTypePlayer() and self:CheckDispelFilter("magic") then
		specWarnDecayedSenses:Show(args.destName)
		specWarnDecayedSenses:Play("helpdispel")
--	elseif spellId == 378229 then
--		if args:IsPlayer() then
--			specWarnMarkedforButchery:Show()
--			specWarnMarkedforButchery:Play("defensive")
--		else
--			warnMarkedforButchery:Show(args.destName)
--		end
	elseif spellId == 381466 then
		warnHextrick:Show(args.destName)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 186122 then--Rira Hackclaw
		timerSavageChargeCD:Stop(args.destGUID)
		timerBladestormCD:Stop(args.destGUID)
	elseif cid == 186124 then--Gashtooth
		timerDecayedSensesCD:Stop(args.destGUID)
		timerGashFrenzyCD:HardStop(args.destGUID)
		timerMarkedforButcheryCD:HardStop(args.destGUID)
	elseif cid == 186125 then--Tricktotem
		timerHexrickTotemCD:Stop(args.destGUID)
		timerGreaterHealingRapidsCD:HardStop(args.destGUID)
	end
end
