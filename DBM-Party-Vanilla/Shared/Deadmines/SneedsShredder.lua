local mod	= DBM:NewMod("SneedsShredder", "DBM-Party-Vanilla", DBM:IsRetail() and 18 or 5)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "timewalker"
else
	mod.statTypes = "normal"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(642, 643)--Shredder, Sneed
mod:SetEncounterID(2968)--Retail Encounter ID
mod:SetZone(36)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 7399 6713 5141",
	"SPELL_AURA_APPLIED 7399 6713"
)

local warningFear			= mod:NewTargetNoFilterAnnounce(7399, 2)
local warningDisarm			= mod:NewTargetNoFilterAnnounce(6713, 2)
local warningEjectSneed		= mod:NewSpellAnnounce(5141, 2)

local timerFearCD			= mod:NewAITimer(180, 7399, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerDisarmCD			= mod:NewAITimer(180, 6713, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

function mod:OnCombatStart(delay)
	timerFearCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpell(7399) and args:IsSrcTypeHostile() then
		timerFearCD:Start()
	elseif args:IsSpell(6713) and args:IsSrcTypeHostile() then
		timerDisarmCD:Start()
	elseif args:IsSpell(5141) then
		warningEjectSneed:Show()
		timerFearCD:Stop()
		timerDisarmCD:Start(1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(7399) and args:IsDestTypePlayer() then
		warningFear:Show(args.destName)
	elseif args:IsSpell(6713) and args:IsDestTypePlayer() then
		warningDisarm:Show(args.destName)
	end
end
