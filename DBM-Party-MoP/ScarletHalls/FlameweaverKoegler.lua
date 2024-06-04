local mod	= DBM:NewMod(656, "DBM-Party-MoP", 8, 311)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(59150)
mod:SetEncounterID(1420)
mod:SetZone(1001)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 113690 113691 113364",
	"SPELL_CAST_SUCCESS 113626",
	"SPELL_AURA_APPLIED 113682 113641",
	"SPELL_AURA_REMOVED 113641"
)

local warnQuickenedMind			= mod:NewSpellAnnounce(113682, 3)--This is Magic dispelable, you can't interrupt anything if you don't dispel this.
local warnBookBurner			= mod:NewSpellAnnounce(113364, 3)

local specWarnFireballVolley	= mod:NewSpecialWarningInterrupt(113691, "HasInterrupt", nil, nil, 1, 2)
local specWarnPyroblast			= mod:NewSpecialWarningInterrupt(113690, false, nil, nil, 1, 2)
local specWarnQuickenedMind		= mod:NewSpecialWarningDispel(113682, "MagicDispeller", nil, nil, 1, 2)
--local specWarnDragonsBreathDispel		= mod:NewSpecialWarningDispel(113641, "MagicDispeller", nil, nil, 1, 2)
local specWarnDragonsBreath		= mod:NewSpecialWarningDodge(113641, nil, nil, nil, 2, 8)

local timerPyroblastCD			= mod:NewCDTimer(6, 113690, nil, "HasInterrupt", nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
--local timerQuickenedMindCD	= mod:NewCDTimer(30, 113682)--Needs more data. I see both 30 sec and 1 min cds, so I just need larger sample size.
--local timerFireballVolleyCD		= mod:NewCDTimer(30, 113691)--Seems very random, maybe affected by school lockout so kicking pyroblast prevents this?
local timerBookBurnerCD			= mod:NewCDTimer(15.5, 113364, nil, nil, nil, 5)
local timerDragonsBreath		= mod:NewBuffActiveTimer(10, 113641, nil, nil, nil, 6)
local timerDragonsBreathCD		= mod:NewNextTimer(50, 113641, nil, nil, nil, 2)

function mod:OnCombatStart(delay)
	timerPyroblastCD:Start(2.1-delay)
--	timerQuickenedMindCD:Start(9-delay)
--	timerFireballVolleyCD:Start(15.5-delay)
	timerBookBurnerCD:Start(20.5-delay)
	timerDragonsBreathCD:Start(30-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 113690 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnPyroblast:Show(args.sourceName)
			specWarnPyroblast:Play("kickcast")
		end
		timerPyroblastCD:Start()
	elseif args.spellId == 113691 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnFireballVolley:Show(args.sourceName)
			specWarnFireballVolley:Play("kickcast")
		end
--		timerFireballVolleyCD:Start()
	elseif args.spellId == 113364 then
		warnBookBurner:Show()
		timerBookBurnerCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 113626 then--Teleport, cast before dragons breath. Provides an earlier warning by almost 1 sec.
		timerPyroblastCD:Cancel()--Will just cast it instantly when dragon breath ends, Cd is irrelevant at this point.
		specWarnDragonsBreath:Show()
		specWarnDragonsBreath:Play("behindboss")
		timerDragonsBreathCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 113682 and not args:IsDestTypePlayer() then
		specWarnQuickenedMind:Show(args.destName)
		specWarnQuickenedMind:Play("dispelboss")
--		timerQuickenedMindCD:Start()
	elseif args.spellId == 113641 then--Actual dragons breath buff, don't want to give a dispel warning too early
--		specWarnDragonsBreath:Show(args.destName)
		timerDragonsBreath:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 113641 then
		timerDragonsBreath:Cancel()
	end
end
