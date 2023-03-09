local mod	= DBM:NewMod(116, "DBM-Party-Cataclysm", 8, 68)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(43875)
mod:SetEncounterID(1042)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 86911",
	"SPELL_CAST_START 87618"
)

--If cataclysm classic is pre nerf, static cling has shorter cast and needs faster alert
--local warnStaticCling			= mod:NewSpellAnnounce(87618, 3)

local specWarnStaticCling		= mod:NewSpecialWarningJump(87618, nil, nil, nil, 1, 2)
local specWarnGroundingField	= mod:NewSpecialWarningMoveTo(86911, nil, DBM_CORE_L.AUTO_SPEC_WARN_OPTIONS.run:format(86911), nil, nil, 3)

local timerStaticClingCD		= mod:NewCDTimer(15.8, 87618, nil, nil, nil, 2)
local timerGroundingField		= mod:NewCastTimer(10, 86911, nil, nil, nil, 2)
local timerGroundingFieldCD		= mod:NewCDTimer(46.1, 86911, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)

function mod:OnCombatStart(delay)
	timerStaticClingCD:Start(10.7-delay)
	timerGroundingFieldCD:Start(16.9-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 86911 and self:AntiSpam(5, 1) then
		specWarnGroundingField:Show(args.spellName)
		timerGroundingField:Start()
		timerStaticClingCD:Start(12)
		timerGroundingFieldCD:Start()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 87618 then
--		warnStaticCling:Show(args.spellName)
		specWarnStaticCling:Schedule(0.3)--delay message since jumping at start of cast is no longer correct in 4.0.6+
		specWarnStaticCling:ScheduleVoice(0.3, "jumpnow")
		if timerGroundingFieldCD:GetRemaining() < 15.8 then
			timerStaticClingCD:Start()
		end
	end
end
