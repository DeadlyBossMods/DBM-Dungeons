local mod	= DBM:NewMod(443, "DBM-Party-Vanilla", DBM:IsPostCata() and 10 or 16, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10558)
mod:SetEncounterID(473)
mod:SetZone(329)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 16798",
	"SPELL_AURA_APPLIED 16798"
)

local warningEnchantingLullaby		= mod:NewTargetNoFilterAnnounce(16798, 2)

local specWarnEnchantingLullaby		= mod:NewSpecialWarningInterrupt(16798, "HasInterrupt", nil, nil, 1, 2)

local timerEnchantingLullabyCD		= mod:NewAITimer(180, 16798, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON..DBM_COMMON_L.MAGIC_ICON)


function mod:OnCombatStart(delay)
	timerEnchantingLullabyCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(16798) then
		timerEnchantingLullabyCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnEnchantingLullaby:Show(args.sourceName)
			specWarnEnchantingLullaby:Play("kickcast")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(16798) then
		warningEnchantingLullaby:Show(args.destName)
	end
end
