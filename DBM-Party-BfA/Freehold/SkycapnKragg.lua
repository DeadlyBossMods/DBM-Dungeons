local mod	= DBM:NewMod(2102, "DBM-Party-BfA", 2, 1001)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(126832)
mod:SetEncounterID(2093)
mod:SetHotfixNoticeRev(20230506000000)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 255952 256106 272046",
	"SPELL_CAST_SUCCESS 256005 256060",
	"SPELL_AURA_APPLIED 256016 181089",
	"SPELL_PERIODIC_DAMAGE 256016",
	"SPELL_PERIODIC_MISSED 256016",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, target scan charge?
--TODO, imrprove PowderShot warning, I honestly don't remember what it did, tooltip says cone/shockwave?
--TODO, non mythic plus also use new timers?
--[[
(ability.id = 255952 or ability.id = 256106 or ability.id = 272046) and type = "begincast"
 or (ability.id = 256056 or ability.id = 256060 or ability.id = 256005) and type = "cast"
 or ability.id = 181089
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnPhase2					= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)
local warnVilebombardment			= mod:NewSpellAnnounce(256005, 2, nil, false)--Every 6 seconds so off by default
local warnPowderShot				= mod:NewSpellAnnounce(256106, 2)

local specWarnCharge				= mod:NewSpecialWarningDodge(255952, nil, nil, nil, 2, 2)
local specWarnDiveBomb				= mod:NewSpecialWarningDodge(272046, nil, nil, nil, 2, 2)
--local specWarnPowderShot			= mod:NewSpecialWarningSpell(256106, nil, nil, nil, 2, 2)--Dodge?
local specWarnBrew					= mod:NewSpecialWarningInterrupt(256060, "HasInterrupt", nil, nil, 1, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(256016, nil, nil, nil, 1, 8)

local timerChargeCD					= mod:NewCDTimer(8.4, 255952, nil, nil, nil, 3)--8.4-11
local timerDiveBombCD				= mod:NewCDTimer(13.1, 272046, nil, nil, nil, 3)
local timerPowderShotCD				= mod:NewCDTimer(9.5, 256106, nil, nil, nil, 3)
local timerVilebombardmentCD		= mod:NewCDTimer(5.9, 256005, nil, nil, nil, 3)
local timerBrewCD					= mod:NewCDTimer(20.6, 256060, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

function mod:OnCombatStart(delay)
	self:SetStage(1)
	timerChargeCD:Start(4.3-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 255952 then
		specWarnCharge:Show()
		specWarnCharge:Play("chargemove")
		timerChargeCD:Start()
	elseif spellId == 256106 then
		warnPowderShot:Show()
		--specWarnPowderShot:Show()
		--specWarnPowderShot:Play("shockwave")--Review, I barely remember fight it died so fast
		timerPowderShotCD:Start(self:IsMythicPlus() and 10.9 or 9.5)
	elseif spellId == 272046 then
		specWarnDiveBomb:Show()
		specWarnDiveBomb:Play("watchstep")
		timerDiveBombCD:Start(self:IsMythicPlus() and 16.9 or 13.1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 256005 then
		warnVilebombardment:Show()
		timerVilebombardmentCD:Start(self:IsMythicPlus() and 17 or 5.9)
	elseif spellId == 256060 then
		specWarnBrew:Show(args.sourceName)
		specWarnBrew:Play("kickcast")
		timerBrewCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 256016 and args:IsPlayer() and self:AntiSpam(2, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	elseif spellId == 181089 and self:GetStage(1) then--Spawn Parrot
		self:SetStage(2)
		timerChargeCD:Stop()
		warnPhase2:Show()
		warnPhase2:Play("ptwo")
		timerVilebombardmentCD:Start(2.2)
		timerPowderShotCD:Start(5.6)
--		timerBrewCD:Start(9.7)--No initial timer because he just doesn't activate ability utnil below x health, once activated THEN it has a CD
		if not self:IsNormal() then
			timerDiveBombCD:Start(12.8)
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 256016 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 256056 and self:GetStage(1) then--Spawn Parrot
		self:SetStage(2)
		timerChargeCD:Stop()
		warnPhase2:Show()
		warnPhase2:Play("ptwo")
		timerVilebombardmentCD:Start(2.2)
		timerPowderShotCD:Start(5.6)
--		timerBrewCD:Start(9.7)--No initial timer because he just doesn't activate ability utnil below x health, once activated THEN it has a CD
		if not self:IsNormal() then
			timerDiveBombCD:Start(12.8)
		end
	end
end
