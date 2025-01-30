if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("DarkRider", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3145)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"UNIT_HEALTH",
	"SWING_DAMAGE"
)

-- Grab Torch
-- Two spell IDs, 1220904 and 1220905, casts on torch bearer first then on no target. Only has UCS.
-- Trigger seems aligned with phase changes, so no warning.

-- I didn't understand the Torment's Illusion mechanic, it's some kind of mirror image that only you can see that you need to kill.
-- But it spawning doesn't really show up in the log, and nothing really happens if you just ignore it?
-- The only way to detect it seems to be getting hit by it?

-- There is likely a way to get a combat start timer, but the triggering yell seems inconsistent between first pull and later pulls.
-- And the fight doesn't really start, it's just him spawning. Might revisit.

local warnPhase2Soon = mod:NewPrePhaseAnnounce(2)

local specWarnIllusion	= mod:NewSpecialWarningTargetChange(1220912, nil, nil, nil, 1, 2)

local warnedPhase1, warnedPhase2, warnedPhase3

function mod:OnCombatStart()
	warnedPhase1, warnedPhase2, warnedPhase3 = false, false, false
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
		warnedPhase2 = true
		warnPhase2Soon:Show()
	end
end

function mod:SWING_DAMAGE(srcGuid, _, _, _, destGuid)
	if srcGuid == UnitGUID("player") and self:GetCIDFromGUID(destGuid) == 238443 and self:AntiSpam(15, "AttackGhost") then
		specWarnIllusion:Show(L.Ghost)
		specWarnIllusion:Play("targetchange")
	end
end
