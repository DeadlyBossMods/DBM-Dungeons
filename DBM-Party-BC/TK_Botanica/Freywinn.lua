local mod = DBM:NewMod(559, "DBM-Party-BC", 14, 257)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 645 $"):sub(12, -3))

mod:SetCreatureID(17975)
mod:SetEncounterID(1926)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 34557"
)

local specWarnTranq		= mod:NewSpecialWarningSwitch("ej5458", "-Healer")

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 34557 then      --Summon Frayer Protector
		specWarnTranq:Show()
		specWarnTranq:Play("killmob")
	end
end