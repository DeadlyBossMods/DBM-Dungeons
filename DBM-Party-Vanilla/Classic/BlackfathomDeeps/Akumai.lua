local mod	= DBM:NewMod("Akumai", "DBM-Party-Vanilla", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(4829)
mod:SetEncounterID(2767)
mod:SetZone(48)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 3815",
	"SPELL_CAST_SUCCESS 3490"
)

local warningPoisonCloud		= mod:NewSpellAnnounce(3815, 4)
local warningFrenziedRage		= mod:NewSpellAnnounce(3490, 4)

local timerPoisonCloudCD		= mod:NewAITimer(180, 3815, nil, nil, nil, 3)
local timerFrenziedRageCD		= mod:NewAITimer(180, 3490, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerPoisonCloudCD:Start(1-delay)
	timerFrenziedRageCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(3815) then
		warningPoisonCloud:Show()
		timerPoisonCloudCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(3490) then
		warningFrenziedRage:Show()
		timerFrenziedRageCD:Start()
	end
end
