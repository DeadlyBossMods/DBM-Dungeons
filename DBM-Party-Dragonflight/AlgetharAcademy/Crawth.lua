local mod	= DBM:NewMod(2495, "DBM-Party-Dragonflight", 5, 1201)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(191736)
mod:SetEncounterID(2564)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 376448 376467 377034 377004 376997",
	"SPELL_CAST_SUCCESS 377182"
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, fix playball. 90% certain that's not the trigger, but until I have logs I cannot do better.
--TODO, verify target scan
local warnPlayBall								= mod:NewSpellAnnounce(377182, 2, nil, nil, nil, nil, nil, 2)

local specWarnFirestorm							= mod:NewSpecialWarningDodge(376448, nil, nil, nil, 2, 2)
local specWarnGaleForce							= mod:NewSpecialWarningSpell(376467, nil, nil, nil, 2, 2)
local specWarnOverpoweringGust					= mod:NewSpecialWarningDodge(377034, nil, nil, nil, 2, 2)
local yellOverpoweringGust						= mod:NewYell(377034)
local specWarnDeafeningScreech					= mod:NewSpecialWarningDodge(377004, nil, nil, nil, 2, 2)
local specWarnSavagePeck						= mod:NewSpecialWarningDefensive(376997, nil, nil, nil, 1, 2)
--local specWarnGTFO							= mod:NewSpecialWarningGTFO(340324, nil, nil, nil, 1, 8)

local timerPlayBallCD							= mod:NewAITimer(35, 377182, nil, nil, nil, 6)
local timerOverpoweringGustCD					= mod:NewAITimer(35, 377034, nil, nil, nil, 3)
local timerDeafeningScreechCD					= mod:NewAITimer(35, 377004, nil, nil, nil, 3)
local timerSavagePeckCD							= mod:NewAITimer(35, 376997, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--local berserkTimer							= mod:NewBerserkTimer(600)

--mod:AddRangeFrameOption(4, 377004)
--mod:AddInfoFrameOption(361651, true)
--mod:AddSetIconOption("SetIconOnStaggeringBarrage", 361018, true, false, {1, 2, 3})

function mod:GustTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellOverpoweringGust:Yell()
	end
end

function mod:OnCombatStart(delay)
	timerPlayBallCD:Start(1-delay)
	timerOverpoweringGustCD:Start(1-delay)
	timerDeafeningScreechCD:Start(1-delay)
	timerSavagePeckCD:Start(1-delay)
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
	if spellId == 376448 then
		specWarnFirestorm:Show()
		specWarnFirestorm:Play("watchstep")
	elseif spellId == 376467 then
		specWarnGaleForce:Show()
		specWarnGaleForce:Play("carefly")--Temp, it's not a knockback it's a pushback
	elseif spellId == 377034 then
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "GustTarget", 0.1, 8, true)
		specWarnOverpoweringGust:Show()
		specWarnOverpoweringGust:Play("shockwave")
		timerOverpoweringGustCD:Start()
	elseif spellId == 377004 then
		specWarnDeafeningScreech:Show()
		specWarnDeafeningScreech:Play("watchstep")
		timerDeafeningScreechCD:Start()
	elseif spellId == 376997 then
		timerSavagePeckCD:Start()
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSavagePeck:Show()
			specWarnSavagePeck:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 377182 then
		warnPlayBall:Show()
		warnPlayBall:Play("phasechange")
		timerPlayBallCD:Start()
	elseif spellId == 377004 then
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 361966 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 361966 then

	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 340324 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
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
