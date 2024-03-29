local mod	= DBM:NewMod(535, "DBM-Party-BC", 8, 250)
local L		= mod:GetLocalizedStrings()

if mod:IsRetail() then
	mod.statTypes = "normal,heroic,timewalker"
end

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(18343)
mod:SetEncounterID(1901)

if not mod:IsRetail() then
	mod:SetModelID(19332)
	mod:SetModelScale(0.5)
	mod:DisableEEKillDetection() -- EE instantly fires
	mod:SetMinSyncRevision(20210604000000)--2021, 06, 04
end

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 33919",
	"SPELL_AURA_APPLIED 32361",
	"SPELL_AURA_REMOVED 32361"
)

--TODO: Timers
local WarnPrison		= mod:NewTargetAnnounce(32361, 3)

local specWarnQuake		= mod:NewSpecialWarningSpell(33919, nil, nil, nil, 2, 2)

local timerPrisonCD		= mod:NewCDTimer(17.8, 32361, nil, nil, nil, 3)
local timerPrison		= mod:NewTargetTimer(5, 32361, nil, nil, nil, 5)

function mod:OnCombatStart(delay)
	timerPrisonCD:Start()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 33919 then
		specWarnQuake:Show()
		specWarnQuake:Play("stunsoon")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 32361 then
		WarnPrison:Show(args.destName)
		timerPrison:Start(args.destName)
		timerPrisonCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 32361 then
		timerPrison:Stop(args.destName)
	end
end
