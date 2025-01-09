local mod	= DBM:NewMod(2116, "DBM-Party-BfA", 7, 1012)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(129232)
mod:SetEncounterID(2108)
mod:SetZone(1594)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 260189 262515 260190 260829",
	"SPELL_AURA_REMOVED 260189 262515",
	"SPELL_AURA_REMOVED_DOSE 260189",
	"SPELL_CAST_START 260280 271456",
	"SPELL_CAST_SUCCESS 260813 271456 276212"
)

--TODO: Maybe general range 6 for Micro Missiles from BOOMBA?
local warnDrill						= mod:NewStackAnnounce(260189, 2)
local warnHomingMissile				= mod:NewTargetAnnounce(260811, 3)
--local warnDrillSmashCast			= mod:NewCastAnnounce(271456, 2)
local warnDrillSmash				= mod:NewTargetNoFilterAnnounce(271456, 2)
local warnSummonBooma				= mod:NewSpellAnnounce(276212, 2)

--Stage One: Big Guns
local specWarnGatlingGun			= mod:NewSpecialWarningDodgeCount(260280, nil, nil, nil, 3, 8)
local specWarnHomingMissile			= mod:NewSpecialWarningMoveAway(260811, nil, nil, nil, 1, 2)
local yellHomingMissile				= mod:NewYell(260811)
--Stage Two: Drill
local specWarnDrillSmash			= mod:NewSpecialWarningMoveTo(271456, nil, nil, nil, 1, 2)
local yellDrillSmash				= mod:NewYell(271456)
local specWarnHeartseeker			= mod:NewSpecialWarningYou(262515, nil, nil, nil, 1, 2)
local specWarnHeartseekerOther		= mod:NewSpecialWarningTarget(262515, "Tank", nil, nil, 1, 2)
local yellHeartseeker				= mod:NewYell(262515)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(238028, nil, nil, nil, 1, 8)

--Stage One: Big Guns
local timerGatlingGunCD				= mod:NewCDCountTimer(20.1, 260280, nil, nil, nil, 3)
local timerHomingMissileCD			= mod:NewCDCountTimer(21, 260811, nil, nil, nil, 3)
--Stage Two: Drill
local timerDrillSmashCD				= mod:NewCDCountTimer(8.4, 271456, nil, nil, nil, 3)--8.4--9.9

local rocket = DBM:GetSpellName(166493)
mod.vb.gatCount = 0
mod.vb.homingCount = 0
mod.vb.drillCount = 0

function mod:DrillTarget(targetname)
	if not targetname then return end
	if self:AntiSpam(4, targetname) then--Antispam to lock out redundant later warning from firing if this one succeeds
		if targetname == UnitName("player") then
			specWarnDrillSmash:Show(rocket)
			specWarnDrillSmash:Play("targetyou")
			yellDrillSmash:Yell()
		else
			warnDrillSmash:Show(targetname)
		end
	end
end

function mod:OnCombatStart(delay)
	self.vb.gatCount = 0
	self.vb.homingCount = 0
	self.vb.drillCount = 0
	timerHomingMissileCD:Start(4.9-delay, 1)
	timerGatlingGunCD:Start(14.9-delay, 1)
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 260189 then--Configuration: Drill
		timerGatlingGunCD:Stop()
		timerHomingMissileCD:Stop()
		timerDrillSmashCD:Start(17.3, self.vb.drillCount+1)
	elseif spellId == 260190 then--Configuration: Combat
		timerDrillSmashCD:Stop()
		timerHomingMissileCD:Start(7, self.vb.homingCount+1)
		timerGatlingGunCD:Start(17, self.vb.gatCount+1)
	elseif spellId == 262515 then
		if args:IsPlayer() then
			specWarnHeartseeker:Show()
			specWarnHeartseeker:Play("targetyou")
			yellHeartseeker:Yell()
		else
			specWarnHeartseekerOther:Show(args.destName)
			specWarnHeartseekerOther:Play("gathershare")
		end
	elseif spellId == 260829 then
		if args:IsPlayer() then
			specWarnHomingMissile:Show()
			specWarnHomingMissile:Play("runout")
			yellHomingMissile:Yell()
		else
			warnHomingMissile:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	local spellId = args.spellId
	if spellId == 260189 then
		local amount = args.amount or 0
		warnDrill:Cancel()
		warnDrill:Schedule(0.5, args.destName, amount)
	end
end
mod.SPELL_AURA_REMOVED = mod.SPELL_AURA_REMOVED_DOSE

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 260280 then
		self.vb.gatCount = self.vb.gatCount + 1
		specWarnGatlingGun:Show(self.vb.gatCount)
		specWarnGatlingGun:Play("behindboss")
		specWarnGatlingGun:ScheduleVoice(1.5, "keepmove")
		timerGatlingGunCD:Start(nil, self.vb.gatCount+1)
	elseif spellId == 271456 then
		self.vb.drillCount = self.vb.drillCount + 1
		self:ScheduleMethod(0.5, "BossTargetScanner", args.sourceGUID, "DrillTarget", 0.1, 12, true)
		timerDrillSmashCD:Start(nil, self.vb.drillCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 260813 then
		self.vb.homingCount = self.vb.homingCount + 1
		timerHomingMissileCD:Start(nil, self.vb.homingCount+1)
	elseif spellId == 271456 and self:AntiSpam(6, args.destName) then--Backup, should only trigger if targetscan failed
		warnDrillSmash:Show(args.destName)
	elseif spellId == 276212 then
		warnSummonBooma:Show()
	end
end
