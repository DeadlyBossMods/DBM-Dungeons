local mod	= DBM:NewMod(285, "DBM-Party-Cataclysm", 12, 184)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(54445)
mod:SetEncounterID(1883)
mod:SetModelID(38802)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 101927 101812",
	"SPELL_DAMAGE 101980"
)

local warnFrostBlades			= mod:NewSpellAnnounce(101339, 3)

local specWarnFlarecore			= mod:NewSpecialWarningSpell(101927, nil, nil, nil, 2, 2)

--local timerFlarecore			= mod:NewCDTimer(13.4, 101927, nil, nil, nil, 5)
local timerFlarecoreDetonate	= mod:NewTimer(10, "TimerFlarecoreDetonate", 101927, nil, nil, 2)
local timerFrostBlades			= mod:NewCDTimer(24.3, 101339)

function mod:OnCombatStart(delay)
--	timerFlarecore:Start(10.5)
	timerFrostBlades:Start(19)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 101927 then
		specWarnFlarecore:Show()
		specWarnFlarecore:Play("specialsoon")
--		timerFlarecore:Start()
		timerFlarecoreDetonate:Start()
	elseif args.spellId == 101812 then	-- Frost Blades is cast immediately after Blink (Frost Blades = 3 events, Blink = 1 event)
		warnFrostBlades:Show()
		timerFrostBlades:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, _, _, _, _, spellId)
	if spellId == 101980 then
		timerFlarecoreDetonate:Cancel()
	end
end
