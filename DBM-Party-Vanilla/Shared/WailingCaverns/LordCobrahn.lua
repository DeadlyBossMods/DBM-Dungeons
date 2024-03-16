local mod	= DBM:NewMod(475, "DBM-Party-Vanilla", DBM:IsPostCata() and 14 or 19, 240)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3669)
mod:SetEncounterID(586)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 8040 23381",
	"SPELL_CAST_SUCCESS 7965 17330",
	"SPELL_AURA_APPLIED 8040 17330"
)

local warningDruidSlumber			= mod:NewTargetNoFilterAnnounce(8040, 2)
local warningHealingTouch			= mod:NewCastAnnounce(23381, 2)
local warningPoison					= mod:NewTargetNoFilterAnnounce(17330, 2, nil, "RemovePoison")

local specWarnDruidsSlumber			= mod:NewSpecialWarningInterrupt(8040, "HasInterrupt", nil, nil, 1, 2)

local timerDruidsSlumberCD			= mod:NewAITimer(180, 8040, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON..DBM_COMMON_L.MAGIC_ICON)
local timerHealingTouchCD			= mod:NewAITimer(180, 23381, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerPoisonCD					= mod:NewAITimer(180, 23381, nil, "RemovePoison", nil, 5, nil, DBM_COMMON_L.POISON_ICON)

function mod:OnCombatStart(delay)
	timerDruidsSlumberCD:Start(1-delay)
	timerHealingTouchCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(8040) and args:IsSrcTypeHostile() then
		timerDruidsSlumberCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnDruidsSlumber:Show(args.sourceName)
			specWarnDruidsSlumber:Play("kickcast")
		end
	elseif args:IsSpell(23381) and args:IsSrcTypeHostile() then
		warningHealingTouch:Show()
		timerHealingTouchCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(7965) then
		timerDruidsSlumberCD:Stop()
		timerHealingTouchCD:Stop()
		timerPoisonCD:Start(1)
	elseif args:IsSpell(17330) and args:IsSrcTypeHostile() then
		timerPoisonCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(8040) and args:IsDestTypePlayer() then
		warningDruidSlumber:Show(args.destName)
	elseif args:IsSpell(17330) and args:IsDestTypePlayer() and self:CheckDispelFilter("poison") then
		warningPoison:Show(args.destName)
	end
end
