local mod	= DBM:NewMod(2573, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(207940)
mod:SetEncounterID(2848)
mod:SetHotfixNoticeRev(20240608000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2649)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 444546 423539 451605 423536 444609 444608 428169",
	"SPELL_CAST_SUCCESS 423588",
	"SPELL_AURA_APPLIED 423588",
	"SPELL_AURA_REMOVED 423588",
	"SPELL_PERIODIC_DAMAGE 425556",
	"SPELL_PERIODIC_MISSED 425556",
	"RAID_BOSS_WHISPER"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 444546 or ability.id = 423539 or ability.id = 451605 or ability.id = 423536 or ability.id = 444609 or ability.id = 444608) and type = "begincast"
 or ability.id = 423588 and (type = "cast" or type = "applybuff" or type = "removebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, does boss have a really long RP that's included in ENCOUNTER_START
local warnBarrierofLight					= mod:NewCountAnnounce(423588, 3)
local warnPurifyingLight					= mod:NewCountAnnounce(444546, 2)--Precast
local warnPurifyingLightTargets				= mod:NewTargetNoFilterAnnounce(444546, 2)--target like 6 seconds later

local specWarnEmbracetheLight				= mod:NewSpecialWarningInterruptCount(423664, "HasInterrupt", nil, nil, 1, 2)
local specWarnPurifyingLight				= mod:NewSpecialWarningYou(444546, nil, nil, nil, 1, 2)
local yellPurifyingLight					= mod:NewYell(444546)
local specWarnInnerFire						= mod:NewSpecialWarningCount(423539, nil, nil, nil, 2, 2)
local specWarnHolyFlame						= mod:NewSpecialWarningDodgeCount(451606, nil, nil, nil, 2, 2)--451605 has no tooltip, debuff ID used for option key
local specWarnHolySmite						= mod:NewSpecialWarningInterruptCount(423536, false, nil, nil, 1, 2)--Very short cooldown
local specWarnBlindingLight					= mod:NewSpecialWarningLookAway(428169, nil, nil, nil, 2, 2, 4)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(425556, nil, nil, nil, 1, 8)

local timerPurifyingLightCD					= mod:NewVarCountTimer("v28.7-35.2", 444546, nil, nil, nil, 3)
local timerInnerFireCD						= mod:NewVarCountTimer("v21.8-25.5", 423539, nil, nil, nil, 2)
local timerHolyFlameCD						= mod:NewVarCountTimer("v12.1-21.8", 451606, nil, nil, nil, 3, nil, DBM_COMMON_L.MAGIC_ICON)
local timerBlindingLightCD					= mod:NewVarCountTimer("v24.3-36.4", 428169, nil, nil, nil, 2, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerBlindingLight					= mod:NewCastTimer(4, 428169, nil, nil, nil, 7, nil, nil, nil, 1, 3)

mod:AddInfoFrameOption(423588)

mod.vb.barrierCount = 0
mod.vb.purifyingCount = 0
mod.vb.innerCount = 0
mod.vb.holyFlameCount = 0
mod.vb.holySmiteCount = 0
mod.vb.blindingCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.barrierCount = 0
	self.vb.purifyingCount = 0
	self.vb.innerCount = 0
	self.vb.holyFlameCount = 0
	self.vb.holySmiteCount = 0
	self.vb.blindingCount = 0
	timerHolyFlameCD:Start(7-delay, 1)--7-8.1 (but can also sometimes not get cast at all for 45 seconds
	timerPurifyingLightCD:Start(10.5-delay, 1)--10.5
	timerInnerFireCD:Start("v15.5-19.4", 1)--15.5-19
	if self:IsMythic() then
		timerBlindingLightCD:Start(13.6-delay, 1)
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 444546 then
		self.vb.purifyingCount = self.vb.purifyingCount + 1
		warnPurifyingLight:Show(self.vb.purifyingCount)
		timerPurifyingLightCD:Start(nil, self.vb.purifyingCount+1)
	elseif spellId == 423539 or spellId == 444608 then
		self.vb.innerCount = self.vb.innerCount + 1
		specWarnInnerFire:Show(self.vb.innerCount)
		specWarnInnerFire:Play("aesoon")
		timerInnerFireCD:Start(nil, self.vb.innerCount+1)
	elseif spellId == 451605 then
		--8.1, 13.3, 9.7, 13.4, 9.7, 53.4, 9.7, 13.3, 9.7",
		self.vb.holyFlameCount = self.vb.holyFlameCount + 1
		specWarnHolyFlame:Show(self.vb.holyFlameCount)
		specWarnHolyFlame:Play("watchstep")
		--More data needed to make sure pattern doesn't break due to spell lockouts on kicking Holy smite, or different timings on Inner Light interrupt
--		if self.vb.holyFlameCount % 2 == 0 then
			timerHolyFlameCD:Start(9.7, self.vb.holyFlameCount+1)
--		else
--			timerHolyFlameCD:Start(13.3, self.vb.holyFlameCount+1)
--		end
	elseif spellId == 423536 then
		self.vb.holySmiteCount = self.vb.holySmiteCount + 1
		if self:CheckInterruptFilter(args.sourceGUID, nil, true) then
			specWarnHolySmite:Show(args.sourceName, self.vb.holySmiteCount)
			specWarnHolySmite:Play("kickcast")
		end
	elseif spellId == 444609 then--Stoke the flame (cast after interrupting Inner Light
--		self.vb.holyFlameCount = 0
		self:SetStage(2)
		timerHolyFlameCD:Start("v12.1-14.5", self.vb.holyFlameCount+1)
		--Inner and purify can swap positions
		--Whichever is 15.8-18.2 the other is 20.6
		timerInnerFireCD:Start("v15.8-20.6", self.vb.innerCount+1)
		timerPurifyingLightCD:Start("v15.8-20.6", self.vb.purifyingCount+1)
		if self:IsMythic() then
			timerBlindingLightCD:Start("v21.9-24.2", self.vb.blindingCount+1)
		end
	elseif spellId == 428169 then
		self.vb.blindingCount = self.vb.blindingCount + 1
		specWarnBlindingLight:Show(args.sourceName)
		specWarnBlindingLight:Play("turnaway")
		timerBlindingLightCD:Start(nil, self.vb.blindingCount+1)
		timerBlindingLight:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 423588 then
		self.vb.barrierCount = self.vb.barrierCount + 1
		warnBarrierofLight:Show(self.vb.barrierCount)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 423588 then
		timerPurifyingLightCD:Stop()
		timerInnerFireCD:Stop()
		timerHolyFlameCD:Stop()
		timerBlindingLightCD:Stop()
		timerBlindingLight:Stop()
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 423588 then
		specWarnEmbracetheLight:Show(args.destName, self.vb.barrierCount)
		specWarnEmbracetheLight:Play("kickcast")
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 425556 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("425556") then
		specWarnPurifyingLight:Show()
		specWarnPurifyingLight:Play("laserrun")
		yellPurifyingLight:Yell()
	end
end

function mod:OnTranscriptorSync(msg, targetName)
	if msg:find("425556") and targetName then
		targetName = Ambiguate(targetName, "none")
		if self:AntiSpam(4, targetName) then
			if UnitName("player") == targetName then return end--Player already got warned
			warnPurifyingLightTargets:Show(targetName)
		end
	end
end

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
