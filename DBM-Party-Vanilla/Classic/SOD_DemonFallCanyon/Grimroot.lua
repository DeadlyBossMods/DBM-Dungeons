local mod	= DBM:NewMod("Grimroot", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3023)
--mod:SetCreatureID(4275)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS,
--	"SPELL_AURA_APPLIED"
)

--function mod:OnCombatStart(delay)

--end


--[[
function mod:SPELL_CAST_START(args)
	if args:IsSpell(5174) then

	end
end
--]]
