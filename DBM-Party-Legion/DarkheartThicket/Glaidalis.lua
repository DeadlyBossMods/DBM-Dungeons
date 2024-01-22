local mod	= DBM:NewMod(1654, "DBM-Party-Legion", 2, 762)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(96512)
mod:SetEncounterID(1836)
mod:SetUsedIcons(8, 7)
mod:SetHotfixNoticeRev(20231029000000)
mod:SetMinSyncRevision(20231029000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 198379",
	"SPELL_CAST_SUCCESS 198401 212464 196354",
	"SPELL_SUMMON 198432",
	"SPELL_AURA_APPLIED 198477",
	"SPELL_AURA_REMOVED 198477",
	"SPELL_PERIODIC_DAMAGE 198408",
	"SPELL_PERIODIC_MISSED 198408"
)

--[[
ability.id = 198379 and type = "begincast"
 or (ability.id = 198401 or ability.id = 212464 or ability.id = 196354) and type = "cast"
 or ability.id = 198432
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--NOTE: Leap will be broken until 10.2 but that's fine. in TW or while leveling dungeon is easy
--TODO, min timers could still possibly need tweaking/lowering. Same with min ICD of each ability
local warnLeap					= mod:NewCountAnnounce(196354, 2)
local warnNightFall				= mod:NewSpellAnnounce(212464, 2)

local specWarnNightfall			= mod:NewSpecialWarningMove(212464, nil, nil, nil, 1, 2)
--local specWarnLeap			= mod:NewSpecialWarningDodge(196354, nil, nil, nil, 1)
local yellLeap					= mod:NewYell(196354)
local specWarnRampage			= mod:NewSpecialWarningDefensive(198379, nil, nil, nil, 1, 2)
local specWarnFixate			= mod:NewSpecialWarningYou(198477, nil, nil, nil, 1, 2)

local timerLeapCD				= mod:NewCDCountTimer(11.9, 196354, nil, nil, nil, 3)--11.9-17 depending on travel time and spell queuing (timer could be even shorter, small sample)
local timerRampageCD			= mod:NewCDCountTimer(26.7, 198379, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--26.7-32.7
local timerNightfallCD			= mod:NewCDCountTimer(20.6, 212464, nil, nil, nil, 3)--20.6--30.4

mod:AddSetIconOption("SetIconOnAdd", -13302, true, 5, {8, 7})
mod:AddNamePlateOption("NPAuraOnFixate", 198477)

mod:GroupSpells(198401, -13302)--Group add with it's parent spell

mod.vb.addIcon = 8
mod.vb.leapCount = 0
mod.vb.rampageCount = 0
mod.vb.nightCount = 0

--Grievous Leap triggers 5.1-5.8 ICD
--Primal rampage triggers 5.7 ICD
--Nightfall triggers 2.6 ICD
local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerLeapCD:GetRemaining(self.vb.leapCount+1) < ICD then
		local elapsed, total = timerLeapCD:GetTime(self.vb.leapCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerLeapCD extended by: "..extend, 2)
		timerLeapCD:Update(elapsed, total+extend, self.vb.leapCount+1)
	end
	if timerRampageCD:GetRemaining(self.vb.rampageCount+1) < ICD then
		local elapsed, total = timerRampageCD:GetTime(self.vb.rampageCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerRampageCD extended by: "..extend, 2)
		timerRampageCD:Update(elapsed, total+extend, self.vb.rampageCount+1)
	end
	if timerNightfallCD:GetRemaining(self.vb.nightCount+1) < ICD then
		local elapsed, total = timerNightfallCD:GetTime(self.vb.nightCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerNightfallCD extended by: "..extend, 2)
		timerNightfallCD:Update(elapsed, total+extend, self.vb.nightCount+1)
	end
end

--Not realy dodgable, more or less just a visual of leap target
function mod:LeapTarget(targetname, uId)
	if targetname == UnitName("player") then
		yellLeap:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.leapCount = 0
	self.vb.rampageCount = 0
	self.vb.nightCount = 0
	timerLeapCD:Start(5-delay, 1)
	timerRampageCD:Start(12.2-delay, 1)
	timerNightfallCD:Start(19.4-delay, 1)--19.4-25.5
	if self.Options.NPAuraOnFixate then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd(wipe, secondRun)
	if self.Options.NPAuraOnFixate then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
	if not wipe and not secondRun then
		DBM:GetModByName("DHTTrash"):ResetSecondBossRP()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 198379 then
		self.vb.rampageCount = self.vb.rampageCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnRampage:Show(self.vb.rampageCount)
			specWarnRampage:Play("defensive")
		end
		timerRampageCD:Start(nil, self.vb.rampageCount+1)
		updateAllTimers(self, 5.7)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if (spellId == 198401 or spellId == 212464) and self:AntiSpam(2, 1) then
		self.vb.nightCount = self.vb.nightCount + 1
		self.vb.addIcon = 8
		warnNightFall:Show(self.vb.nightCount)
		timerNightfallCD:Start(nil, self.vb.nightCount+1)
		updateAllTimers(self, 2.6)
	elseif spellId == 196354 then
		self.vb.leapCount = self.vb.leapCount + 1
		warnLeap:Show(self.vb.leapCount)
		--"<398.10 22:27:23> [UNIT_SPELLCAST_SUCCEEDED] Archdruid Glaidalis(76.9%-100.0%){Target:Lucyz} -Grievous Leap- [[boss1:Cast-3-5770-1466-11160-196354-0007A1BF2D:196354]]", -- [4835]
		--"<398.12 22:27:23> [UNIT_TARGET] boss1#Archdruid Glaidalis#Target: Fxa#TargetOfTarget: Archdruid Glaidalis", -- [4842]
		--"<398.11 22:27:23> [CLEU] SPELL_DAMAGE#Creature-0-5770-1466-11160-96512-000021BD9C#Archdruid Glaidalis#Player-5765-0007A043#Lucyz-Raszageth#196354#Grievous Leap", -- [4843]
		if DBM.Options.DebugMode then
			self:BossTargetScanner(args.sourceGUID, "LeapTarget", 0.05, 6, true, nil, nil, nil, true)
		end
		timerLeapCD:Start(nil, self.vb.leapCount+1)
		updateAllTimers(self, 5.1)
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 198432 then
		if self.Options.SetIconOnAdd then
			self:ScanForMobs(args.destGUID, 2, self.vb.addIcon, 1, nil, 12, "SetIconOnAdd")
		end
		self.vb.addIcon = self.vb.addIcon - 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 198477 and args:IsPlayer() then
		if self:AntiSpam(3, 2) then
			specWarnFixate:Show()
			specWarnFixate:Play("targetyou")
		end
		if self.Options.NPAuraOnFixate then
			DBM.Nameplate:Show(true, args.sourceGUID, spellId, nil, 20)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 198477 and args:IsPlayer() then
		if self.Options.NPAuraOnFixate then
			DBM.Nameplate:Hide(true, args.sourceGUID, spellId)
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 198408 and destGUID == UnitGUID("player") and self:AntiSpam(2, 3) then
		specWarnNightfall:Show()
		specWarnNightfall:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
