local mod	= DBM:NewMod(540, "DBM-Party-BC", 11, 251)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(18096)
mod:SetEncounterID(1906)
mod:SetZone(251)

if not mod:IsRetail() then
	mod:SetModelID(19135)
	mod:SetModelScale(0.15)
	mod:SetModelOffset(0, 0, 8)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 33834 31914"
)

local warnSandBreath		= mod:NewSpellAnnounce(31914, 2)

local timerManaDisruption	= mod:NewBuffActiveTimer(15, 33834, nil, nil, nil, 1)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 33834 then
		timerManaDisruption:Show()
	elseif args.spellId == 31914 then
		warnSandBreath:Show()
	end
end
