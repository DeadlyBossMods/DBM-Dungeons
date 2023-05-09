local mod	= DBM:NewMod(2471, "DBM-Party-Dragonflight", 1, 1196)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186122, 186124, 186125)
mod:SetEncounterID(2570)
--mod:SetUsedIcons(1, 2, 3)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20221205000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 381694 378029 381470 377950 378208",
	"SPELL_CAST_SUCCESS 377965",
	"SPELL_AURA_APPLIED 381461 381835 381835 377844 381387 381379 378229 381466",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED 361966 361018 361651"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
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
local warnSavageCharge							= mod:NewTargetNoFilterAnnounce(381461, 4)--Not special waring for now, since it is 14 sec cast time
local warnBladestorm							= mod:NewTargetNoFilterAnnounce(377827, 3)

local specWarnSavageCharge						= mod:NewSpecialWarningYou(381461, nil, nil, nil, 1, 2)
local yellSavageCharge							= mod:NewYell(381461)
local specWarnSavageChargeTarget				= mod:NewSpecialWarningTarget(381461, nil, nil, nil, 1, 2)

local timerSavageChargeCD						= mod:NewCDTimer(59.4, 381461, nil, nil, nil, 3, nil, DBM_COMMON_L.TANK_ICON)
local timerBladestormCD							= mod:NewCDTimer(59.4, 377827, nil, nil, nil, 3)
--Gashtooth
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24733))
local warnMarkedforButchery						= mod:NewCastAnnounce(378229, 3, nil, nil, "Healer")

local specWarnDecayedSenses						= mod:NewSpecialWarningDispel(381379, "RemoveMagic", nil, nil, 1, 2)
local specWarnGashFrenzy						= mod:NewSpecialWarningSpell(378029, "Healer", nil, nil, 2, 2)
--local specWarnMarkedforButchery					= mod:NewSpecialWarningDefensive(378229, nil, nil, nil, 1, 2)

local timerDecayedSensesCD						= mod:NewCDTimer(59.4, 381379, nil, nil, nil, 3)
local timerGashFrenzyCD							= mod:NewCDTimer(59.4, 378029, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.BLEED_ICON)
local timerMarkedforButcheryCD					= mod:NewCDTimer(60.2, 378229, nil, nil, nil, 3, nil, DBM_COMMON_L.HEALER_ICON)
--Tricktotem
mod:AddTimerLine(DBM:EJ_GetSectionInfo(24734))
local warnHextrick								= mod:NewTargetNoFilterAnnounce(381466, 3)
local warnBloodlust								= mod:NewSpellAnnounce(377965, 3)

local specWarnHextrickTotem						= mod:NewSpecialWarningSwitch(381470, "-Healer", nil, nil, 1, 2)
local specWarnGreaterHealingRapids				= mod:NewSpecialWarningInterrupt(377950, "HasInterrupt", nil, nil, 1, 2)
--local specWarnGTFO							= mod:NewSpecialWarningGTFO(340324, nil, nil, nil, 1, 8)

local timerHexrickTotemCD						= mod:NewCDTimer(59.4, 381470, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerGreaterHealingRapidsCD				= mod:NewCDCountTimer(15.7, 377950, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--mod:AddRangeFrameOption("8")
--mod:AddInfoFrameOption(361651, true)
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

mod.vb.healingRapidsCount = 0

local function scanBosses(self, delay)
	for i = 1, 3 do
		local unitID = "boss"..i
		if UnitExists(unitID) then
			local cid = self:GetUnitCreatureId(unitID)
			local bossGUID = UnitGUID(unitID)
			if cid == 186122 then--Rira Hackclaw
				timerBladestormCD:Start(19.7-delay, bossGUID)
				timerSavageChargeCD:Start(48.3-delay, bossGUID)
			elseif cid == 186124 then--Gashtooth
				timerGashFrenzyCD:Start(2.7-delay, bossGUID)
				timerDecayedSensesCD:Start(45.8-delay, bossGUID)
				if self:IsMythic() then
					timerMarkedforButcheryCD:Start(12.4-delay, bossGUID)
				end
			else--Tricktotem
				timerGreaterHealingRapidsCD:Start(11-delay, 1, bossGUID)
				timerHexrickTotemCD:Start(44.8-delay, bossGUID)
			end
		end
	end
end

function mod:OnCombatStart(delay)
	self.vb.healingRapidsCount = 0
	self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss guids
end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 381694 then
		timerDecayedSensesCD:Start(nil, args.sourceGUID)
	elseif spellId == 378029 then
		specWarnGashFrenzy:Show()
		specWarnGashFrenzy:Play("healfull")
		timerGashFrenzyCD:Start(nil, args.sourceGUID)
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
			timerGreaterHealingRapidsCD:Start(21.8, self.vb.healingRapidsCount+1, args.sourceGUID)
		end
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnGreaterHealingRapids:Show(args.sourceName)
			specWarnGreaterHealingRapids:Play("kickcast")
		end
	elseif spellId == 378208 then
		warnMarkedforButchery:Show()
		timerMarkedforButcheryCD:Start(nil, args.sourceGUID)--Move to success to start as appropriate
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
	elseif args:IsSpellID(381387, 381379) and self:CheckDispelFilter("magic") then
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
----mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--
--function mod:SPELL_AURA_REMOVED(args)
--	local spellId = args.spellId
--	if spellId == 361966 then
--
--	end
--end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 186122 then--Rira Hackclaw
		timerSavageChargeCD:Stop(args.destGUID)
		timerBladestormCD:Stop(args.destGUID)
	elseif cid == 186124 then--Gashtooth
		timerDecayedSensesCD:Stop()
		timerGashFrenzyCD:Stop()
		timerMarkedforButcheryCD:Stop(args.destGUID)
	elseif cid == 186125 then--Tricktotem
		timerHexrickTotemCD:Stop(args.destGUID)
		timerGreaterHealingRapidsCD:Stop(args.destGUID)--This one is mainly for plater, which expects a GUID to be passed
		timerGreaterHealingRapidsCD:Stop()--This will actually stop the timers regardless of count
	end
end

--[[

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and not playerDebuff and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
