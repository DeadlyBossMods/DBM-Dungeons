local mod	= DBM:NewMod("HellscreamsPhantom", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3031)
mod:SetCreatureID(227028)
mod:SetZone(2784)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_DAMAGE 460249",
	"SPELL_MISSED 460249"
)

local specWarnGTFO = mod:NewSpecialWarningGTFO(460249, nil, nil, nil, 1, 8)


local playerGuid = UnitGUID("player")
function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 460249 and destGUID == playerGuid and self:AntiSpam(4, 1) then -- Spam less often than others, you get hit by this a lot
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE
