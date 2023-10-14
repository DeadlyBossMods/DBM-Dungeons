local mod	= DBM:NewMod(572, "DBM-Party-BC", 4, 260)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17942)
mod:SetEncounterID(1940)

if not mod:IsRetail() then
	mod:SetModelID(18224)
	mod:SetModelOffset(-2, 0.4, -1)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 39340"
)

local WarnPoisonBoltVolley		= mod:NewSpellAnnounce(39340)

local timerPoisonBoltVolleyCD	= mod:NewCDTimer(22.6, 39340, nil, nil, nil, 2)--22.6-67

function mod:OnCombatStart(delay)
	timerPoisonBoltVolleyCD:Start(17-delay)--iffy
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 39340 then
		WarnPoisonBoltVolley:Show()
		timerPoisonBoltVolleyCD:Start()
	end
end
