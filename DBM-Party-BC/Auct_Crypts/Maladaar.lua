local mod	= DBM:NewMod(524, "DBM-Party-BC", 7, 247)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(18373)
mod:SetEncounterID(1889)

if not mod:IsRetail() then
	mod:SetModelID(17715)
	mod:SetModelScale(0.85)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 32424",
	"SPELL_AURA_APPLIED 32346"
)

local warningSoul		= mod:NewTargetAnnounce(32346, 2)
local warningAvatar		= mod:NewSpellAnnounce(32424, 3)

function mod:SPELL_CAST_START(args)
	if args.spellId == 32424 then
		warningAvatar:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32346 then
		warningSoul:Show(args.destName)
	end
end
