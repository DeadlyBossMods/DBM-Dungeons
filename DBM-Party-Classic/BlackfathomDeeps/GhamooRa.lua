local mod	= DBM:NewMod(368, "DBM-Party-Classic", 1, 227)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 526 $"):sub(12, -3))
mod:SetCreatureID(74446)
mod:SetEncounterID(1667)

mod:RegisterCombat("combat")

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED"
)

local warningSoul	= mod:NewTargetAnnounce(32346, 2)
local warningAvatar	= mod:NewSpellAnnounce(32424, 3)

function mod:SPELL_CAST_START(args)
	if args.spellId == 32424 then
		warningAvatar:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32346 then
		warningSoul:Show(args.destName)
	end
end--]]