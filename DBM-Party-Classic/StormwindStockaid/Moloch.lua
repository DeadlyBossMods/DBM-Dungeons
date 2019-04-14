local mod	= DBM:NewMod(466, "DBM-Party-Classic", 10, 238)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(46383)
mod:SetEncounterID(1146)

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