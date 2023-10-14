local mod = DBM:NewMod(546, "DBM-Party-BC", 10, 253)
local L = mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")

mod:SetCreatureID(18732)
mod:SetEncounterID(1911)
mod:RegisterCombat("combat")

if not mod:IsRetail() then
	mod:SetModelID(18535)
	mod:SetModelScale(0.7)
end

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 33563"
)

local warnTeleport         = mod:NewSpellAnnounce(33563)

local timerTeleport        = mod:NewNextTimer(37, 33563, nil, nil, nil, 6)

function mod:OnCombatStart(delay)
    timerTeleport:Start(40-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 33563 then
		warnTeleport:Show()
		timerTeleport:Start()
	end
end
