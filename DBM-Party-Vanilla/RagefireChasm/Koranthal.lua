local mod	= DBM:NewMod(695, "DBM-Party-Classic", 7, 226)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61412)
mod:SetEncounterID(1444)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 119300"
)

local specWarnTwistedElements			= mod:NewSpecialWarningInterrupt(119300, "HasInterrupt", nil, nil, 1, 2)

function mod:SPELL_CAST_START(args)
	if args.spellId == 119300 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnTwistedElements:Show(args.sourceName)
		specWarnTwistedElements:Play("kickcast")
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32346 then
		warningSoul:Show(args.destName)
	end
end--]]