local mod	= DBM:NewMod(597, "DBM-Party-WotLK", 6, 275)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(28586)
mod:SetEncounterID(1987)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 52027 52028"
)

local warningWhirlwind		= mod:NewSpellAnnounce(52027, 3)

local specWarnWhirlwind		= mod:NewSpecialWarningRun(52027, "Melee", nil, nil, 4, 2)

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(52027, 52028) then
		if self.Options.SpecWarn52024run then
			specWarnWhirlwind:Show()
			specWarnWhirlwind:Play("runout")
		else
			warningWhirlwind:Show()
		end
	end
end
