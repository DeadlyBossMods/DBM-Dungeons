local mod	= DBM:NewMod(536, "DBM-Party-BC", 8, 250)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(22930)
mod:SetEncounterID(250)

if not mod:IsRetail() then
	mod:SetModelID(14173)
	mod:SetModelScale(0.8)
	mod:SetModelOffset(0, 1, 2)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 36405"
)

local warnStomp	= mod:NewSpellAnnounce(36405, 2)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 36405 then
		warnStomp:Show()
	end
end
