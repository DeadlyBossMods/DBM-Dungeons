local mod	= DBM:NewMod(657, "DBM-Party-MoP", 3, 312)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56541)
mod:SetEncounterID(1304)
mod:SetHotfixNoticeRev(20240517000000)
mod:SetMinSyncRevision(20240517000000)
mod:SetReCombatTime(60)

-- pre-bosswave. Novice -> Black Sash (Fragrant Lotus, Flying Snow). this runs automaticially.
-- maybe we need Black Sash wave warns.
-- but boss (Master Snowdrift) not combat starts automaticilly.
mod:RegisterCombat("combat")
mod:DisableFriendlyDetection()--Goes friendly on defeat, and make still be ticking damage, recombat time alone didn't fix issue

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 118961",
	"SPELL_AURA_REMOVED 118961",
	"SPELL_CAST_START 106853 106434",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, updated phase 3 detection, old detection invalid now
--Chi blast warns very spammy. and not useful.
local warnTornadoKick		= mod:NewSpellAnnounce(106434, 3)
local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnChaseDown			= mod:NewTargetAnnounce(118961, 3)--Targeting spell for Tornado Slam (106352)
-- phase3 ability not found yet.
local warnPhase3			= mod:NewPhaseAnnounce(3)

local specWarnFists			= mod:NewSpecialWarningDodge(106853, "Tank", nil, nil, 1, 2)
local specWarnChaseDown		= mod:NewSpecialWarningYou(118961, nil, nil, nil, 4, 2)

local timerFistsOfFuryCD	= mod:NewCDTimer(23, 106853, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Not enough data to really verify this
local timerTornadoKickCD	= mod:NewCDTimer(32, 106434, nil, nil, nil, 2)--Or this
--local timerChaseDownCD	= mod:NewCDTimer(22, 118961)--Unknown
local timerChaseDown		= mod:NewTargetTimer(11, 118961, nil, nil, nil, 5)

function mod:OnCombatStart(delay)
	self:SetStage(1)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 118961 then
		timerChaseDown:Start(args.destName)
--		timerChaseDownCD:Start()
		if args:IsPlayer() then
			specWarnChaseDown:Show()
			specWarnChaseDown:Play("justrun")
		else
			warnChaseDown:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 118961 then
		timerChaseDown:Cancel(args.destName)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 106853 then
		specWarnFists:Show()
		specWarnFists:Play("shockwave")
		timerFistsOfFuryCD:Start()
	elseif args.spellId == 106434 then
		warnTornadoKick:Show()
		timerTornadoKickCD:Start()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 110324 then
		if self:GetStage(1) then
			self:GetStage(2)
			warnPhase2:Show()
		end
		timerFistsOfFuryCD:Cancel()
		timerTornadoKickCD:Cancel()
	elseif spellId == 123096 then -- only first defeat?
		DBM:EndCombat(self)
	end
end
