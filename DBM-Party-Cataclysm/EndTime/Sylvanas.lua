local mod	= DBM:NewMod(323, "DBM-Party-Cataclysm", 12, 184)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(54123)
mod:SetEncounterID(1882)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 101412",
	"SPELL_CAST_SUCCESS 100686 101348"
)

local warnCalling		= mod:NewSpellAnnounce(100686, 4)
local warnSacrifice		= mod:NewSpellAnnounce(101348, 2, nil, false)

local specWarnShriek	= mod:NewSpecialWarningDispel(101412, "RemoveMagic", nil, 2, 1, 2)

local timerCalling		= mod:NewNextTimer(40, 100686, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)	-- guessed she can do it more than once
local timerSacrifice	= mod:NewNextTimer(30, 101348, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	timerCalling:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 101412 and self:CheckDispelFilter("magic") then
		specWarnShriek:Show(args.destName)
		specWarnShriek:Play("helpdispel")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 100686 then
		warnCalling:Show()
		timerSacrifice:Start()
	elseif args.spellId == 101348 then
		warnSacrifice:Show()
		timerCalling:Start()
	end
end
