local mod	= DBM:NewMod(534, "DBM-Party-BC", 8, 250)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(18341)
mod:SetEncounterID(1900)

if not mod:IsRetail() then
	mod:SetModelID(19338)
	mod:SetModelScale(0.6)
	mod:SetModelOffset(0, 0, 0.8)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 32358 38759"
)

local specWarnShell			= mod:NewSpecialWarningReflect(32358, "SpellCaster", nil, 2, 1, 2)--Casters should stop attacking, melee, doesn't do enough damage to them for them to stop

local timerShell			= mod:NewBuffActiveTimer(7, 32358, nil, nil, nil, 5)

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(32358, 38759) then
		specWarnShell:Show(args.sourceName)
		specWarnShell:Play("stopattack")
		timerShell:Start()
	end
end
