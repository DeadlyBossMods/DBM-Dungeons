local mod	= DBM:NewMod(1238, "DBM-Party-WoD", 4, 558)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,mythic,challenge,timewalker"
mod.upgradedMPlus = true

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(83612)
mod:SetEncounterID(1754)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 168398",
	"SPELL_CAST_START 168929 168227 169129",
	"UNIT_SPELLCAST_INTERRUPTED boss1 boss2 boss3",
	"UNIT_DIED"
)

--[[
(ability.id = 168227 or ability.id = 168929 or ability.id = 169129) and type = "begincast"
 or ability.id = 168398 and type = "applydebuff"
 or type = "interrupt"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, verify gron smash numbers and see if it is time based or damage based.
local warnRapidFire			= mod:NewTargetNoFilterAnnounce(168398, 3)
local warnBackdraft			= mod:NewCastAnnounce(169129, 4)
local warnCannonBarrageEnd	= mod:NewEndAnnounce(168929, 1)

local specWarnRapidFire		= mod:NewSpecialWarningMoveAway(168398, nil, nil, nil, 1, 2)
local yellRapidFire			= mod:NewYell(168398)
local specWarnGronSmash		= mod:NewSpecialWarningSpell(168227, nil, nil, nil, 2, 2)
local specWarnCannonBarrage	= mod:NewSpecialWarningSpell(168929, nil, nil, nil, 3, 2)--Use the one time cast trigger instead of drycode when relogging

local timerRapidFireCD		= mod:NewCDTimer(11.5, 168398, nil, nil, nil, 3)
local timerRapidFire		= mod:NewTargetTimer(5, 168398, nil, "-Tank", nil, 5)
local timerGronSmashCD		= mod:NewCDTimer(54.1, 168227, nil, nil, nil, 2)--Timer is too variable, 49-70, but the avereage is 54-60, so if users want to keep complaining about their timer, they can have an iffy timer
local timerBackdraftCD		= mod:NewCDTimer(13.3, 169129, nil, nil, nil, 3)
mod.vb.flameCast = false

function mod:OnCombatStart(delay)
	self.vb.flameCast = false
	timerGronSmashCD:Start(30-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 168398 then
		timerRapidFire:Start(args.destName)
		timerRapidFireCD:Start()
		if args:IsPlayer() then
			specWarnRapidFire:Show()
			specWarnRapidFire:Play("runout")
			yellRapidFire:Yell()
		else
			warnRapidFire:Show(args.destName)
		end
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 168227 then
		timerRapidFireCD:Stop()
		specWarnGronSmash:Show()
		specWarnGronSmash:Play("carefly")
		if self:IsHard() then
			timerBackdraftCD:Start(13.3)
		end
		timerGronSmashCD:Start()
		self.vb.flameCast = false
	elseif spellId == 168929 then
		specWarnCannonBarrage:Show()
		specWarnCannonBarrage:Play("findshelter")
	elseif spellId == 169129 and not self.vb.flameCast then
		self.vb.flameCast = true
		warnBackdraft:Show()
		--timerBackdraftCD:Start()
	end
end

--Not completely reliable. if you reach him between barrages, before he casts a new one, you won't interrupt any cast and get no event for it.
function mod:UNIT_SPELLCAST_INTERRUPTED(uId, _, spellId)
	if spellId == 168929 then
		warnCannonBarrageEnd:Show()
		timerBackdraftCD:Stop()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 83613 then
		timerRapidFireCD:Cancel()
		timerRapidFire:Cancel()
	end
end
