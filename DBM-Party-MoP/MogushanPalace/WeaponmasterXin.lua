local mod	= DBM:NewMod(698, "DBM-Party-MoP", 5, 321)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(61398)
mod:SetEncounterID(1441)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 119684",
	"SPELL_CAST_SUCCESS 122959",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)


local warnGroundSlam		= mod:NewCastAnnounce(119684, 3)
local warnStaff				= mod:NewSpellAnnounce("ej5973", 2)
local warnRoar				= mod:NewSpellAnnounce(122959, 3, nil, "Healer|Tank")
local warnWhirlwindingAxe	= mod:NewSpellAnnounce(119374, 4)
local warnStreamBlades		= mod:NewSpellAnnounce("ej5972", 4)
local warnCrossbowTrap		= mod:NewSpellAnnounce("ej5974", 4)

local specWarnSlam			= mod:NewSpecialWarningMove(119684, "Healer")

local timerSlamCD			= mod:NewCDTimer(18.2, 119684, nil, nil, nil, 3)
local timerStaffCD			= mod:NewCDTimer(20.6, "ej5973", nil, nil, nil, 3)--20.6~25 sec.
local timerWhirlwindingAxe	= mod:NewNextTimer(15, 119374, nil, nil, nil, 3)
--local timerRoarCD			= mod:NewCDTimer(48, 122959)--Need to confirm, i crashed during log and only got 2 casts, so only one CD, not enough confirmation for me.

function mod:OnCombatStart(delay)
	timerStaffCD:Start(8-delay)
	timerSlamCD:Start(9.5-delay)
	timerWhirlwindingAxe:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 119684 then
		warnGroundSlam:Show()
		specWarnSlam:Show()
		timerSlamCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 122959 then
		warnRoar:Show()
--		timerRoarCD:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 120109 then
		warnStaff:Show()
		timerStaffCD:Start()
	elseif spellId == 120083 then
		warnWhirlwindingAxe:Show()
	elseif spellId == 120094 then
		warnStreamBlades:Show()
	elseif spellId == 120139 then
		warnCrossbowTrap:Show()
	end
end
