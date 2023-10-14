local mod = DBM:NewMod(559, "DBM-Party-BC", 14, 257)
local L = mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(17975)
mod:SetEncounterID(1926)

if not mod:IsRetail() then
	mod:SetModelID(19045)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 34557",
	"SPELL_AURA_APPLIED 34752"
)

local specWarnFreezingTouch	= mod:NewSpecialWarningDispel(34752, "MagicDispeller", nil, nil, 1, 2)
local specWarnAdds			= mod:NewSpecialWarningAdds(34557, "-Healer", nil, nil, 1, 2)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 34557 then --Summon Frayer Protector
		specWarnAdds:Show()
		specWarnAdds:Play("killmob")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 34752 then
		specWarnFreezingTouch:Show(args.destName)
		specWarnFreezingTouch:Play("dispelboss")
	end
end
