if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("Azgaloth", "DBM-Party-Vanilla", 21)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3080)
mod:SetCreatureID(232632)
mod:SetZone(2784)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 470280 470457"
)

-- Umbral Slash (470280)
-- Seems to be the only relevant ability, a shockwave that splits damage.
-- No clue what the cooldown or timer on that is

-- Bounding Shadow (470457)
-- Summons some ghostly skull things that fly towards you and presumably do damage? Didn't seem very relevant.

-- Rain of Fire (469990)
-- Seems bugged because it only does 9 fire damage?
-- I guess we want a GTFO warning if that gets fixed.


local warnShadow    = mod:NewCastAnnounce(470457, 3)
local specWarnSlash = mod:NewSpecialWarningSoak(470280, nil, nil, nil, 2, 2)
local timerSlash    = mod:NewCastTimer(470280)


function mod:SPELL_CAST_START(args)
	if args:IsSpell(470280) then
		specWarnSlash:Show()
		specWarnSlash:Play("frontal")
		timerSlash:Start()
	elseif args:IsSpellID(470457) then
		warnShadow:Show()
	end
end
