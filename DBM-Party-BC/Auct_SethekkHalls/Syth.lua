local mod = DBM:NewMod(541, "DBM-Party-BC", 9, 252)
local L = mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(18472)
mod:SetEncounterID(1903)

if not mod:IsRetail() then
	mod:SetModelID(20599)
	mod:SetModelScale(0.9)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_SUMMON 33537 33538 33539 33540"
)

local warnSummon   = mod:NewAnnounce("warnSummon", 3)--(-5235)

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(33537, 33538, 33539, 33540) and self:AntiSpam() then
		warnSummon:Show()
	end
end
