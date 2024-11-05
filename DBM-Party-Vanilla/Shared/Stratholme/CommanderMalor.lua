local mod	= DBM:NewMod(749, "DBM-Party-Vanilla", DBM:IsPostCata() and 10 or 16, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(11032)
mod:SetEncounterID(476)
mod:SetZone(329)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 15245",
	"SPELL_CAST_SUCCESS 12734"
)

local warningGroundSmash				= mod:NewSpellAnnounce(12734, 2)

local specWarnShadowBoltVolley			= mod:NewSpecialWarningInterrupt(15245, "HasInterrupt", nil, nil, 1, 2)

local timerShadowBoltVolleyCD			= mod:NewAITimer(180, 15245, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerGroundSmashCD				= mod:NewAITimer(180, 12734, nil, nil, nil, 2)

function mod:OnCombatStart(delay)
	timerShadowBoltVolleyCD:Start(1-delay)
	timerGroundSmashCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(15245) then
		timerShadowBoltVolleyCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnShadowBoltVolley:Show(args.sourceName)
			specWarnShadowBoltVolley:Play("kickcast")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(12734) then
		warningGroundSmash:Show()
		timerGroundSmashCD:Start()
	end
end
