local mod	= DBM:NewMod(181, "DBM-Party-Cataclysm", 11, 76)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "heroic,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(52059)
mod:SetEncounterID(1180)
mod:SetZone(859)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 96435 96423 96592 97380",
	"SPELL_AURA_REMOVED 96423",
	"SPELL_INTERRUPT",
	"SPELL_CAST_SUCCESS 96457"
)

local warnLash			= mod:NewTargetNoFilterAnnounce(96423, 3, nil, "Healer", 2)
local warnWaveAgony		= mod:NewSpellAnnounce(96457, 3)
local warnRavage		= mod:NewTargetNoFilterAnnounce(96592, 3)
local warnPhase2		= mod:NewPhaseAnnounce(2)

local specWarnTears		= mod:NewSpecialWarningInterrupt(96435, "HasInterrupt", nil, 2, 1, 2)

local timerTears		= mod:NewCastTimer(6, 96435, nil, nil, nil, 2)
local timerLash			= mod:NewTargetTimer(10, 96423, nil, "Healer", 2, 5, nil, DBM_COMMON_L.HEALER_ICON..DBM_COMMON_L.MAGIC_ICON)
local timerWaveAgony	= mod:NewCDTimer(32, 96457, nil, nil, nil, 3)
local timerRavage		= mod:NewTargetTimer(10, 96592, nil, false, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)

function mod:OnCombatStart(delay)
	self:SetStage(1)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 96435 then	-- Tears of Blood, CD 27-37 secs
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTears:Show(args.sourceName)
			specWarnTears:Play("kickcast")
		end
		timerTears:Start()
	elseif args.spellId == 96423 then
		warnLash:Show(args.destName)
		timerLash:Start(args.destName)
	elseif args.spellId == 96592 then
		warnRavage:Show(args.destName)
		timerRavage:Start(args.destName)
	elseif args.spellId == 97380 and self:GetStage(2, 1) then
		self:SetStage(2)
		warnPhase2:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 96423 then
		timerLash:Cancel(args.destName)
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and args.extraSpellId == 96435 then
		timerTears:Cancel()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 96457 then
		warnWaveAgony:Show()
		timerWaveAgony:Start()
	end
end
