if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("DarkRider", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3145)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_REMOVED 1220939",
	"UNIT_HEALTH",
	"SWING_DAMAGE",
	"SWING_MISSED",
	"UPDATE_MOUSEOVER_UNIT",
	"PLAYER_TARGET_CHANGED"
)

mod:SetUsedIcons(8)

-- Grab Torch
-- Two spell IDs, 1220904 and 1220905, casts on torch bearer first then on no target. Only has UCS.
-- Trigger seems aligned with phase changes, so no warning.

-- Torment's Illusion
-- Mirror image only you can see, you have to kill it.
-- Doesn't seem detectable except for when it starts hitting you.

-- Phase
-- 7 extra mobs spawn that buff themselves with Ethereal Charge (1220939), you have to attack one of them
-- The right one seems to remove that buff from itself when it becomes attackable, let's see if we can detect that and aggressively set an icon

local warnPhase2Soon = mod:NewPrePhaseAnnounce(2)

local specWarnIllusion	= mod:NewSpecialWarningTargetChange(1220912, nil, nil, nil, 1, 2)

local warnedPhase1, warnedPhase2, warnedPhase3
mod.vb.phaseTarget = nil

function mod:OnCombatStart()
	warnedPhase1, warnedPhase2, warnedPhase3 = false, false, false
	self.vb.phaseTarget = nil
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpell(1220939) then
		self.vb.phaseTarget = args.destGUID
		DBM:Debug("Found real horse GUID: " .. tostring(args.destGUID))
		self:ScanLoop(150)
	end
end

function mod:ScanPhaseTarget(uId)
	if not self.vb.phaseTarget or not UnitGUID(uId) then
		return
	end
	if UnitGUID(uId) == self.vb.phaseTarget then
		DBM:Debug("Found real horse uid: " .. tostring(uId))
		if GetRaidTargetIndex(uId) ~= 8 then
			SetRaidTarget(uId, 8) -- Everyone can (and should in this case) set icons
		end
		self.vb.phaseTarget = nil
		self:UnscheduleMethod("ScanLoop")
	end
end

local scanIds = {"party1target", "party2target", "party3target", "party4target"}

function mod:ScanLoop(maxCount)
	maxCount = maxCount - 1
	if maxCount <= 0 then
		return
	end
	-- Can't use normal target npc scanning because we want to trigger regardless of icon setter status
	for _, uId in ipairs(scanIds) do
		self:ScanPhaseTarget(uId)
	end
	self:ScheduleMethod(0.1, "ScanLoop", maxCount)
end

-- We need these events and the loop above to detect the real one if you don't switch targets
function mod:UPDATE_MOUSEOVER_UNIT()
	self:ScanPhaseTarget("mouseover")
end

function mod:PLAYER_TARGET_CHANGED()
	self:ScanPhaseTarget("target")
end

function mod:UNIT_HEALTH(uId)
	if self:GetUnitCreatureId(uId) ~= 238055 then
		return
	end
	local hp = UnitHealth(uId) / UnitHealthMax(uId)
	if not warnedPhase1 and hp >= 0.76 and hp <= 0.80 then
		warnedPhase1 = true
		warnPhase2Soon:Show()
	end
	if not warnedPhase2 and hp >= 0.51 and hp <= 0.55 then
		warnedPhase2 = true
		warnPhase2Soon:Show()
	end
	if not warnedPhase3 and hp >= 0.26 and hp <= 0.30 then
		warnedPhase3 = true
		warnPhase2Soon:Show()
	end
end

function mod:SWING_DAMAGE(srcGuid, _, _, _, destGuid)
	if destGuid == UnitGUID("player") and self:GetCIDFromGUID(srcGuid) == 238443 and self:AntiSpam(15, "AttackGhost") then
		specWarnIllusion:Show(L.MirrorImage)
		specWarnIllusion:Play("targetchange")
	end
end

mod.SWING_MISSED = mod.SWING_DAMAGE
