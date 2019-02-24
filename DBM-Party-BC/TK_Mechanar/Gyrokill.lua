local mod	= DBM:NewMod("Gyrokill", "DBM-Party-BC", 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 645 $"):sub(12, -3))
mod:SetCreatureID(19218)
mod:SetEncounterID(1933)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 39193 35322",
	"SPELL_AURA_REMOVED 39193 35322"
)

local warnShadowpower       = mod:NewTargetAnnounce(35322, 3)

local specWarnShadowpower   = mod:NewSpecialWarningDispel(35322, "MagicDispeller", nil, nil, 1, 2)

local timerShadowpower      = mod:NewBuffActiveTimer(15, 35322, nil, "Tank|MagicDispeller", 2, 5, nil, DBM_CORE_TANK_ICON)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(39193, 35322) and not args:IsDestTypePlayer() then     --Shadow Power
		timerShadowpower:Start(args.destName)
		if self.Options.SpecWarn35322dispel then
			specWarnShadowpower:Show(args.destName)
			specWarnShadowpower:Play("dispelboss")
		else
			warnShadowpower:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(39193, 35322) and not args:IsDestTypePlayer() then     --Shadow Power
		timerShadowpower:Stop(args.destName)
	end
end