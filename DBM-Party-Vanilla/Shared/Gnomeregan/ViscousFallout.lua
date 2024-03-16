local mod	= DBM:NewMod(420, "DBM-Party-Vanilla", DBM:IsPostCata() and 4 or 7, 231)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7079)
mod:SetEncounterID(mod:IsClassic() and 2769 or 378)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 21687"
)

local warningToxicVolley			= mod:NewSpellAnnounce(21687, 2, nil, "Healer|RemovePoison")

local timerToxicVolleyCD			= mod:NewAITimer(180, 21687, nil, nil, nil, 3, nil, DBM_COMMON_L.POISON_ICON)

function mod:OnCombatStart(delay)
	timerToxicVolleyCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(21687) then
		warningToxicVolley:Show()
		timerToxicVolleyCD:Start()
	end
end
