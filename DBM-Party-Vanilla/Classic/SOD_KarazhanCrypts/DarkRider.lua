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

mod:SetUsedIcons(1, 2, 3, 4, 5, 8) -- No icon setting option for 8 because everyone can and will set them (and it's just active for like 5 seconds)

-- Grab Torch
-- Two spell IDs, 1220904 and 1220905, casts on torch bearer first then on no target. Only has UCS.
-- Trigger seems aligned with phase changes, so no warning.

-- Torment's Illusion
-- Mirror image only you can see, you have to kill it.
-- Only detectable via unit scanning and when it hits you (but it doesn't start attacking you by itself! you have to trigger it with some cleave/AoE for this detection method)

-- Phase
-- 7 extra mobs spawn that buff themselves with Ethereal Charge (1220939), you have to attack one of them
-- The right one seems to remove that buff from itself when it becomes attackable, let's see if we can detect that and aggressively set an icon

local enrageTimer	= mod:NewBerserkTimer(300)

local warnPhase2Soon = mod:NewPrePhaseAnnounce(2)

local specWarnIllusion	= mod:NewSpecialWarningTargetChange(1220912, nil, nil, nil, 1, 2)

mod:AddSetIconOption("SetIconOnIllusion", 1220912, true, 0, {1, 2, 3, 4, 5})
mod:AddBoolOption("EnableMinorNameplates", true, "misc")

local warnedPhase1, warnedPhase2, warnedPhase3
local phaseTarget, myIcon

function mod:OnCombatStart()
	warnedPhase1, warnedPhase2, warnedPhase3 = false, false, false
	phaseTarget = nil
	enrageTimer:Start()
	self:ScanMirrorLoop()
	-- Since only you can see your mirror you need to set the icon yourself, but it still can't conflict with other player's icons, so need a deterministic way to pick an icon for everyone
	local guids = {UnitGUID("player"), UnitGUID("party1"), UnitGUID("party2"), UnitGUID("party3"), UnitGUID("party4")}
	table.sort(guids, function(e1, e2) return e1 < e2 end)
	for i, v in ipairs(guids) do
		if v == UnitGUID("player") then
			myIcon = i
			break
		end
	end
end

-- By default illusions don't even get nameplates, so we try to force enable CVars here

-- Custom event handler because we need to restore it when leaving the zone
local f = CreateFrame("Frame")
f:RegisterEvent("LOADING_SCREEN_DISABLED")
f:RegisterEvent("PLAYER_LOGOUT")
local handler = function(_, event)
	if event == "LOADING_SCREEN_DISABLED" then
		mod:CheckInstance()
	elseif event == "PLAYER_LOGOUT" then
		mod:LeaveKarazhan()
	end
end
f:SetScript("OnEvent", handler)
DBM:RegisterCallback("DBMTest_Event", function(_, ...) handler(f, ...) end)

local lastZone = nil
function mod:CheckInstance()
	local zone = select(8, GetInstanceInfo())
	if lastZone == 2875 and zone ~= 2875 then
		self:LeaveKarazhan()
	elseif zone == 2875 and lastZone ~= 2875 then
		self:EnterKarazhan()
	end
	lastZone = zone
end
mod.OnInitialize = mod.CheckInstance

-- It's unfortunately a bit unclear which option we need and annoying to test with daily lockouts
-- I got nameplates working when literally everything including friendly totems etc was enabled, but that really sucks.
-- None of these hurt to enable in Karazhan, so for now just force-enabling them
local cvars = {
	"nameplateShowEnemies",
	"nameplateShowEnemyMinus", -- "Minor Enemies" in the UI
	-- All of these are the "Enemy Minions" option
	"nameplateShowEnemyPets",
	"nameplateShowEnemyTotems",
	"nameplateShowEnemyGuardians",
	"nameplateShowEnemyMinions",
}
local didEnableNameplates = false
local savedCVars = {}

local shownNameplateInfo = false
function mod:EnterKarazhan()
	DBM:Debug("Entering Karazhan")
	if InCombatLockdown() then
		DBM:Debug("Combat lockdown, retrying in 10 sec")
		self:ScheduleMethod(10, "EnterKarazhan")
		return
	end
	if not didEnableNameplates and self.Options.EnableMinorNameplates then
		didEnableNameplates = true
		local diff = false
		for _, cvar in ipairs(cvars) do
			local oldVal = GetCVar(cvar)
			if oldVal == "0" or oldVal == 0 then
				diff = true
				savedCVars[cvar] = oldVal
				SetCVar(cvar, 1)
			end
		end
		if diff and not shownNameplateInfo then
			shownNameplateInfo = true -- Once per session
			self:AddMsg(L.EnabledNameplates)
		end
	end
end

function mod:LeaveKarazhan()
	DBM:Debug("Leaving Karazhan")
	if InCombatLockdown() then
		DBM:Debug("Combat lockdown, retrying in 10 sec")
		self:ScheduleMethod(10, "LeaveKarazhan")
		return
	end
	if didEnableNameplates then
		didEnableNameplates = false
		for cvar, val in pairs(savedCVars) do
			SetCVar(cvar, val)
		end
		table.wipe(savedCVars)
	end
end


function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpell(1220939) then
		phaseTarget = args.destGUID
		DBM:Debug("Found real horse GUID: " .. tostring(args.destGUID))
		self:ScanLoop(150)
	end
end

function mod:ScanMirrorTarget(uId)
	if self:GetCIDFromGUID(UnitGUID(uId)) ~= 238443 then
		return false
	end
	if myIcon then
		local curIcon = GetRaidTargetIndex(uId)
		if not curIcon or curIcon == 0 then
			DBM:Debug("Found Torment's Illusion at " .. uId .. " setting icon")
			if not DBM.Options.DontSetIcons and self.Options.SetIconOnIllusion then
				SetRaidTarget(uId, myIcon) -- Only you can set the icon
			end
		end
	end
	-- You can see an Illusion, but you aren't targeting it, that's very bad. This is a bit spammy on purpose, similar to standing in fire or something
	if not UnitIsUnit(uId, "target") then
		DBM:Debug("Found mirror image at " .. tostring(uId) .. ", not your current target", 3, false, true)
		if self:AntiSpam(3, "AttackGhost") then
			specWarnIllusion:Show(L.MirrorImage)
			specWarnIllusion:Play("targetchange")
		end
	end
	return true
end

function mod:ScanPhaseTarget(uId)
	if not phaseTarget or not UnitGUID(uId) then
		return
	end
	if UnitGUID(uId) == phaseTarget then
		DBM:Debug("Found real horse uid: " .. tostring(uId))
		if GetRaidTargetIndex(uId) ~= 8 and not DBM.Options.DontSetIcons then
			SetRaidTarget(uId, 8) -- Everyone can (and should in this case) set icons
		end
		phaseTarget = nil
		self:UnscheduleMethod("ScanLoop")
	end
end

local horseScanIds = {"target", "mouseover", "party1target", "party2target", "party3target", "party4target"}

function mod:ScanLoop(maxCount)
	maxCount = maxCount - 1
	if maxCount <= 0 then
		return
	end
	-- Can't use normal target npc scanning because we want to trigger regardless of icon setter status
	for _, uId in ipairs(horseScanIds) do
		self:ScanPhaseTarget(uId)
	end
	self:ScheduleMethod(0.1, "ScanLoop", maxCount)
end

function mod:ScanMirrorLoop()
	self:ScheduleMethod(0.1, "ScanMirrorLoop")
	-- Only you can see it, no point in scanning other player's targets
	if self:ScanMirrorTarget("target") then
		return
	end
	if self:ScanMirrorTarget("mouseover") then
		return
	end
	-- This counts as minor unit or minion, so many nameplate options won't even show a nameplate for this by default!
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		if frame.namePlateUnitToken then
			if self:ScanMirrorTarget(frame.namePlateUnitToken) then
				return
			end
		end
	end
end

-- We need these events and the loop above to detect the real one if you don't switch targets
function mod:UPDATE_MOUSEOVER_UNIT()
	self:ScanPhaseTarget("mouseover")
	self:ScanMirrorTarget("mouseover")
end

function mod:PLAYER_TARGET_CHANGED()
	self:ScanPhaseTarget("target")
	self:ScanMirrorTarget("target")
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

-- This logic is a bit wrong for healers, because they can end up getting attacked by other player's illusion due to heal threat, but that implies someone else isn't doing their job
-- Anyhow, this is still useful in many cases (triggering the illusion by a cleave/aoe, then not noticing it), so keeping it but with a relatively large antispam time
-- The unit scanning above should be the most reliable way to detect it, either by nameplate or people spamming tab targeting
function mod:SWING_DAMAGE(srcGuid, _, _, _, destGuid)
	if destGuid == UnitGUID("player") and self:GetCIDFromGUID(srcGuid) == 238443 and UnitGUID("target") ~= srcGuid and self:AntiSpam(15, "AttackGhost") then
		specWarnIllusion:Show(L.MirrorImage)
		specWarnIllusion:Play("targetchange")
	end
end

mod.SWING_MISSED = mod.SWING_DAMAGE
