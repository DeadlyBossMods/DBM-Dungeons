local mod	= DBM:NewMod(666, "DBM-Party-MoP", 7, 246)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(58722)--58722 is Body, 58791 is soul. Body is engaged first
mod:SetEncounterID(1429)
mod:SetReCombatTime(180, 15)
mod:SetZone(1007)

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.Kill)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 111585 111649 115350",
	"SPELL_CAST_START 111570 111775 114262",
	"SPELL_CAST_SUCCESS 111585",
	"SPELL_DAMAGE 111628",
	"SPELL_MISSED 111628"
)

--TODO, perfect phase transitions and how they effect ability timers. Find out what happens if you kill BODY first in phase 3, does it get rezzed again?
local warnShadowShiv		= mod:NewSpellAnnounce(111775, 2)
local warnUnleashedAnguish	= mod:NewSpellAnnounce(111649, 2)
local warnFixateAnger		= mod:NewTargetAnnounce(115350, 4)
local warnReanimateCorpse	= mod:NewSpellAnnounce(114262, 3)

local specWarnDeathsGrasp	= mod:NewSpecialWarningSpell(111570, nil, nil, nil, 2, 2)
local specWarnDarkBlaze		= mod:NewSpecialWarningGTFO(111585, nil, nil, nil, 1, 8)
local specWarnFixateAnger	= mod:NewSpecialWarningRun(115350, nil, nil, 2, 4, 2)

local timerShadowShivCD		= mod:NewCDTimer(12.5, 111775, nil, nil, nil, 3)--every 12.5-15.5 sec
local timerDeathsGraspCD	= mod:NewCDTimer(34, 111570, nil, nil, nil, 2)
local timerFixateAngerCD	= mod:NewCDTimer(12, 115350, nil, nil, nil, 3)
local timerFixateAnger		= mod:NewTargetTimer(10, 115350, nil, nil, nil, 5)
local timerDarkBlaze		= mod:NewBuffActiveTimer(8, 111585)

function mod:OnCombatStart(delay)
	timerShadowShivCD:Start(12-delay)
	timerDeathsGraspCD:Start(30-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 111585 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnDarkBlaze:Show()
		specWarnDarkBlaze:Play("watchfeet")
	elseif args.spellId == 111649 and self:AntiSpam(3, 2) then--Soul released and body becomes inactive, phase 2.
		timerShadowShivCD:Cancel()
		timerDeathsGraspCD:Cancel()
		warnUnleashedAnguish:Show()
		timerFixateAngerCD:Start()
	elseif args.spellId == 115350 then
		timerFixateAnger:Start(args.destName)
		timerFixateAngerCD:Start()
		if args:IsPlayer() then
			specWarnFixateAnger:Show()
			specWarnFixateAnger:Play("justrun")
		else
			warnFixateAnger:Show(args.destName)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 111570 then
		specWarnDeathsGrasp:Show()
		specWarnDeathsGrasp:Play("specialsoon")
		timerDeathsGraspCD:Start()
		timerShadowShivCD:Start()--Resets CD when she casts Grasp
	elseif args.spellId == 111775 then
		warnShadowShiv:Show()
		timerShadowShivCD:Start()
	elseif args.spellId == 114262 then--Phase 3, body rezzed and you have soul and body up together.
		warnReanimateCorpse:Show()
		timerDeathsGraspCD:Start(9)
		timerShadowShivCD:Start(20.5)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 111585 then
		timerDarkBlaze:Start()
	end
end

-- he dies before health 1, so can't use overkill hack.
function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName, _, _, overkill)
	if spellId == 111628 and destGUID == UnitGUID("player") and self:AntiSpam(3, 3) then
		specWarnDarkBlaze:Show(spellName)
		specWarnDarkBlaze:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
