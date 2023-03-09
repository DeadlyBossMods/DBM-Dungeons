local mod	= DBM:NewMod(1486, "DBM-Party-Legion", 4, 721)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(95833)
mod:SetEncounterID(1806)
mod:SetHotfixNoticeRev(20230308000000)

mod:RegisterCombat("combat")
mod:SetWipeTime(120)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 192018 192307 200901",
	"SPELL_CAST_SUCCESS 192044",
	"SPELL_AURA_APPLIED 192048 192133 192132",
	"SPELL_AURA_REMOVED 192048"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--Notes: expel light could be supported with AGGRESSIVE timer correction around spell queuing and ability turning on and off, it's just not worth effort
--LW does some hacky things with it but not even their hack checks out with all logs. They're missing the shield of light spell queue which sets min time to 6sec
--Again though, too much effort, blizzard should just fix the bad design instead
--["192044-Expel Light"] = "pull:79.7, 26.6, 30.3, 24.3, 30.3",
--Maybe add a searing light interrupt helper if it matters enough on mythic+
--[[
(ability.id = 192158 or ability.id = 192307 or ability.id = 192018 or ability.id = 200901 or ability.id = 192288) and type = "begincast"
 or (ability.id = 192132 or ability.id = 192133) and (type = "applydebuff" or type = "removedebuff")
 or ability.id = 192044 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnExpelLight				= mod:NewTargetAnnounce(192048, 3)
local warnPhase2					= mod:NewPhaseAnnounce(2, 2, nil, nil, nil, nil, nil, 2)

local specWarnShieldOfLight			= mod:NewSpecialWarningDefensive(192018, "Tank", nil, nil, 3, 2)--Journal lies, this is NOT dodgable
local specWarnSanctify				= mod:NewSpecialWarningDodge(192307, nil, nil, nil, 2, 5)
local specWarnEyeofStorm			= mod:NewSpecialWarningMoveTo(200901, nil, nil, nil, 2, 2)
local specWarnExpelLight			= mod:NewSpecialWarningMoveAway(192048, nil, nil, nil, 2, 2)
local yellExpelLight				= mod:NewYell(192048)

local timerShieldOfLightCD			= mod:NewCDTimer(26.6, 192018, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON, nil, mod:IsTank() and 2, 4)--26.6-34
local timerSpecialCD				= mod:NewCDSpecialTimer(30, nil, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON, nil, 1, 4)--Shared timer by eye of storm and Sanctify
local timerExpelLightCD				= mod:NewCDTimer(23, 192048, nil, nil, nil, 3)--May be lower but almost always delayed by spell queue ICDs

mod:AddRangeFrameOption(8, 192048)

local eyeShortName = DBM:GetSpellInfo(91320)--Inner Eye

local function updateAllTimers(self, ICD)
	DBM:Debug("updateAllTimers running", 3)
	if timerShieldOfLightCD:GetRemaining() < ICD then
		local elapsed, total = timerShieldOfLightCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerShieldOfLightCD extended by: "..extend, 2)
		timerShieldOfLightCD:Update(elapsed, total+extend)
	end
	if timerExpelLightCD:GetRemaining() < ICD then
		local elapsed, total = timerExpelLightCD:GetTime()
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerExpelLightCD extended by: "..extend, 2)
		timerExpelLightCD:Update(elapsed, total+extend)
	end
	--Not confirmed special is affected by ICDs of shield and expel so disabled for now
	--if timerSpecialCD:GetRemaining() < ICD then
	--	local elapsed, total = timerSpecialCD:GetTime()
	--	local extend = ICD - (total-elapsed)
	--	DBM:Debug("timerSpecialCD extended by: "..extend, 2)
	--	timerSpecialCD:Update(elapsed, total+extend)
	--end
end

function mod:OnCombatStart(delay)
--	self:SetStage(1)
	timerSpecialCD:Start(8.5)
	timerShieldOfLightCD:Start(24)
	timerExpelLightCD:Start(32.5)
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 192307 then--P2 boss
		specWarnSanctify:Show()
		specWarnSanctify:Play("watchorb")
		timerSpecialCD:Start()
		updateAllTimers(self, 15.5)
	elseif spellId == 192018 then
		specWarnShieldOfLight:Show()
		specWarnShieldOfLight:Play("defensive")
		timerShieldOfLightCD:Start()
		updateAllTimers(self, 6)
	elseif spellId == 200901 and args:GetSrcCreatureID() == 95833 then
		specWarnEyeofStorm:Show(eyeShortName)
		specWarnEyeofStorm:Play("findshelter")
		timerSpecialCD:Start()
		updateAllTimers(self, 15.5)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 192044 then
		timerExpelLightCD:Start()
		updateAllTimers(self, 3.6)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 192048 then
		if args:IsPlayer() then
			specWarnExpelLight:Show()
			specWarnExpelLight:Play("runout")
			yellExpelLight:Yell()
			if self.Options.RangeFrame then
				DBM.RangeCheck:Hide()
			end
		else
			warnExpelLight:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 192048 and args:IsPlayer() and self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

--[[
--Might be needed again for classic legion if that happens otherwise this is retired as of blizz moving encounter start from two adds to phase 2
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 192130 then--Actual boss engaging after 2 adds dying
--		self:SetStage(2)
--		warnPhase2:Show()
--		warnPhase2:Play("ptwo")
--		timerSpecialCD:Start(8.5)
--		timerShieldOfLightCD:Start(24)
	end
end
--]]
