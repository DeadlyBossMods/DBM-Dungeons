local mod	= DBM:NewMod(571, "DBM-Party-BC", 4, 260)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(17991)
mod:SetEncounterID(1941)

if not mod:IsRetail() then
	mod:SetModelID(17729)
	mod:SetModelOffset(-3, 0, -0.8)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 31956 38801 34970"
)

local WarnFrenzy	= mod:NewSpellAnnounce(34970)

local specWarnWound	= mod:NewSpecialWarningTarget(38801, "Healer", nil, nil, 1, 7)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(31956, 38801) then
		specWarnWound:Show(args.destName)
		specWarnWound:Play("healfull")
	elseif args.spellId == 34970 then
		WarnFrenzy:Show(args.destName)
	end
end
