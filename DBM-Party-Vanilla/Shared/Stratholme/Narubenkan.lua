local mod	= DBM:NewMod(452, "DBM-Party-Vanilla", DBM:IsPostCata() and 10 or 16, 236)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10437)
mod:SetEncounterID(480)
mod:SetZone(329)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 17235",
	"SPELL_CAST_SUCCESS 6016",
	"SPELL_AURA_APPLIED 6016"
)

--TODO, add https://www.wowhead.com/spell=4962/encasing-webs if annoying enough
local warningRaiseUndeadScarab		= mod:NewSpellAnnounce(17235, 2)
local warningPierceArmor			= mod:NewTargetNoFilterAnnounce(6016, 2, nil, "Tank|Healer")

local timerRaiseUndeadScarabCD		= mod:NewAITimer(180, 17235, nil, nil, nil, 1)
local timerPierceArmorCD			= mod:NewAITimer(180, 6016, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerRaiseUndeadScarabCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(17235) then
		warningRaiseUndeadScarab:Show()
		timerRaiseUndeadScarabCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(6016) then
		timerPierceArmorCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(6016) then
		warningPierceArmor:Show(args.destName)
	end
end
