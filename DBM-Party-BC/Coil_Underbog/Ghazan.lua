local mod	= DBM:NewMod(577, "DBM-Party-BC", 5, 262)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(18105)
mod:SetEncounterID(1945)

if not mod:IsRetail() then
	mod:SetModelID(17528)
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 15716"
)

local warnEnrage	= mod:NewSpellAnnounce(15716, 4)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 15716 then
		warnEnrage:Show()
	end
end
