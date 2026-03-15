local mod	= DBM:NewMod(478, "DBM-Party-Vanilla", DBM:IsPostCata() and 14 or 19, 240)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3674)
mod:SetEncounterID(589)
mod:SetZone(43)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 6254"
)

--TODO, fix range to one classic actually supports
local timerChainedBoltCD			= mod:NewAITimer(180, 6254, nil, nil, nil, 3)


function mod:OnCombatStart(delay)
	timerChainedBoltCD:Start(1-delay)
end


function mod:SPELL_CAST_START(args)
	if args:IsSpell(6254) and args:IsSrcTypeHostile() then
		timerChainedBoltCD:Start()
	end
end
