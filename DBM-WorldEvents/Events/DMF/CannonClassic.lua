local mod	= DBM:NewMod("CannonClassic", "DBM-WorldEvents", 3)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"SPELL_AURA_APPLIED 24742",
	"SPELL_AURA_REMOVED 24742"
)
mod.noStatistics = true

local timerMagicWings = mod:NewBuffFadesTimer(0, 24742, nil, nil, nil, 5, nil, nil, nil, 1, 5)
local specWarnCancelNow = mod:NewSpecialWarningSpell(24742)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpell(24742) and args:IsPlayer() then
		local timer = C_Map.GetBestMapForUnit("player") == 1456 and 14.8 -- Thunder Bluff
			or C_Map.GetBestMapForUnit("player") == 1429 and 4.83 -- Elwynn Forest
		if timer then
			timerMagicWings:Start(timer)
			specWarnCancelNow:Schedule(timer)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpell(24742) and args:IsPlayer() then
		timerMagicWings:Cancel()
		specWarnCancelNow:Cancel()
	end
end
