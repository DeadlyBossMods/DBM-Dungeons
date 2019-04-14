local mod	= DBM:NewMod(1145, "DBM-Party-Classic", 1, 227)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(74505)
mod:SetEncounterID(1675)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 149913"
)

local specWarnFillet			= mod:NewSpecialWarningRun(149955, "Melee", nil, nil, 4, 2)

local timerFilletCD				= mod:NewAITimer(180, 149955, nil, nil, nil, 2)

function mod:OnCombatStart(delay)
	timerFilletCD:Start(1-delay)
end


function mod:SPELL_CAST_START(args)
	if args.spellId == 149913 then
		if not DBM:UnitDebuff("player", 149910) then
			specWarnFillet:Show()
			specWarnFillet:Play("justrun")
		end
		timerFilletCD:Start()
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32346 then
		warningSoul:Show(args.destName)
	end
end--]]