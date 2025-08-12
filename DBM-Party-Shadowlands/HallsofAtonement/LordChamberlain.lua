local mod	= DBM:NewMod(2413, "DBM-Party-Shadowlands", 4, 1185)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(164218)
mod:SetEncounterID(2381)
mod:SetHotfixNoticeRev(20250808000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2287)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 323393 323236 328791 327885 1236973 329104",
	"SPELL_CAST_SUCCESS 323437 329113 323142",
	"SPELL_AURA_APPLIED 323437"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 323393 or ability.id = 328791 or ability.id = 323236 or ability.id = 327885 or ability.id = 1236973 or ability.id = 329104) and type = "begincast"
 or (ability.id = 329113 or ability.id = 323437) and type = "cast"
 or ability.id = 323143 and type = "applybuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, sigma only cast once entire fight?
local warnTelekineticToss			= mod:NewCountAnnounce(323142, 2)
local warnStigmaofPride				= mod:NewTargetNoFilterAnnounce(323437, 4)

local specWarnUnleashedSuffering	= mod:NewSpecialWarningDodgeCount(323236, nil, nil, nil, 2, 2)
local specWarnTelekineticOnslaught	= mod:NewSpecialWarningDodge(329113, nil, nil, nil, 2, 2)
local specWarnEruptingTorment		= mod:NewSpecialWarningRunCount(1236973, nil, nil, nil, 4, 2)--327885
local specWarnRitualofWoe			= mod:NewSpecialWarningSoakCount(328791, nil, nil, nil, 1, 7)
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerTelekineticTossCD		= mod:NewVarCountTimer("v9.7-12.2", 323142, nil, nil, nil, 3)
local timerUnleashedSufferingCD		= mod:NewVarCountTimer("v21.8-24.3", 323236, nil, nil, nil, 3)
local timerStigmaofPrideCD			= mod:NewCDTimer(27.8, 323437, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerEruptingTormentCD		= mod:NewVarCountTimer("v23-24.3", 1236973, nil, nil, nil, 3)
--Other phasae
local timerRitualofWoeCD			= mod:NewVarCountTimer(8.2, 328791, nil, nil, nil, 2)

mod.vb.tossCount = 0
mod.vb.sufferingCount = 0
mod.vb.tormentCount = 0
mod.vb.woeCount = 0

function mod:OnCombatStart(delay)
	self.vb.tossCount = 0
	self.vb.sufferingCount = 0
	self.vb.tormentCount = 0
	self.vb.woeCount = 0
	timerStigmaofPrideCD:Start(6.5-delay)--SUCCESS
	timerTelekineticTossCD:Start(9.6-delay, 1)
	timerUnleashedSufferingCD:Start(15.7-delay, 1)--But sometimes never cast and boss goes into more tosses instead
	timerEruptingTormentCD:Start(25.4-delay, 1)
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 323393 or spellId == 328791 then--328791 is challenge (all statues), 323393 is non challenge (1 statue)
		self.vb.woeCount = self.vb.woeCount + 1
		specWarnRitualofWoe:Show(self.vb.woeCount)
		specWarnRitualofWoe:Play("helpsoak")
	elseif spellId == 323236 then--event fires multiple times
		self.vb.sufferingCount = self.vb.sufferingCount + 1
		specWarnUnleashedSuffering:Show(self.vb.sufferingCount)
		specWarnUnleashedSuffering:Play("shockwave")
		--timerUnleashedSufferingCD:Start()--TODO, need longer pulls that don't reset timer with Ritual of Woe
	elseif spellId == 327885 or spellId == 1236973 then
		self.vb.tormentCount = self.vb.tormentCount + 1
		specWarnEruptingTorment:Show(self.vb.tormentCount)
		specWarnEruptingTorment:Play("justrun")
	elseif spellId == 329104 then--Door of Shadows (cast before Telekinetic Onslaught but slightly less accurate)
		timerTelekineticTossCD:Stop()
		timerStigmaofPrideCD:Stop()
		timerUnleashedSufferingCD:Stop()
		timerRitualofWoeCD:Start("v9.7-11", self.vb.woeCount+1)
--		timerStigmaofPrideCD:Start(17.6)--Never recast?
		timerEruptingTormentCD:Start("v23-24.3", self.vb.tormentCount+1)
		timerTelekineticTossCD:Start("v29.1-30.4", self.vb.tossCount+1)
		timerUnleashedSufferingCD:Start("v35.1-36.4", self.vb.sufferingCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 323437 then
--		timerStigmaofPrideCD:Start()
	elseif spellId == 329113 then
		specWarnTelekineticOnslaught:Show()
		specWarnTelekineticOnslaught:Play("watchstep")
	elseif spellId == 323142 then
		self.vb.tossCount = self.vb.tossCount + 1
		warnTelekineticToss:Show(self.vb.tossCount)
		timerTelekineticTossCD:Start(nil, self.vb.tossCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 323437 then
		warnStigmaofPride:CombinedShow(0.3, args.destName)
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
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
