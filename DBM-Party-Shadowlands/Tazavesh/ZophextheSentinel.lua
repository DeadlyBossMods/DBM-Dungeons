local mod	= DBM:NewMod(2437, "DBM-Party-Shadowlands", 9, 1194)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(175616)
mod:SetEncounterID(2425)
mod:SetHotfixNoticeRev(20250916000000)
mod:SetZone(2441)

mod:RegisterCombat("combat")

--TODO, add 345990/566 if it's needed for a bar color
--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(1236348, true, 2)--Charged Slash
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(1236348, true, 3, 0)
mod:AddCustomTimerOptions(348350, true, 3, 0)--Interrogation
mod:AddCustomTimerOptions(346006, true, 3, 0)--Impound Contraband
mod:AddCustomTimerOptions(346204, true, 5, 0)--Armed Security
--Midnight private aura replacements
--Recheck https://www.wowhead.com/beta/spell=347949/interrogation when this dungeon returns
mod:AddPrivateAuraSoundOption(348366, true, 348366, 1)--GTFO
mod:AddPrivateAuraSoundOption(345990, true, 348350, 1)--Containment Cell
mod:AddPrivateAuraSoundOption(345770, true, 346006, 1)--Impound Contraband

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	self:EnableAlertOptions(1236348, 562, "frontal", 15)

	self:EnableTimelineOptions(1236348, 562)
	self:EnableTimelineOptions(348350, 563)
	self:EnableTimelineOptions(346006, 564)
	self:EnableTimelineOptions(346204, 565)

	self:EnablePrivateAuraSound(348366, "watchfeet", 8)
	self:EnablePrivateAuraSound(345990, "debuffyou", 17)
	self:EnablePrivateAuraSound(345770, "targetyou", 2)--TODO, custom audio should be added by the time this dungeon returns
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 346204 1236348",
	"SPELL_CAST_SUCCESS 346006 348350",
	"SPELL_AURA_APPLIED 347949 348128 345770 345990",
	"SPELL_AURA_REMOVED 345770 345990",
	"SPELL_PERIODIC_DAMAGE 348366",
	"SPELL_PERIODIC_MISSED 348366"
)
--]]

--Improve/add timers for armed/disarmed phases because it'll probably alternate a buffactive timer instead of CD
--TODO, what do with https://ptr.wowhead.com/spell=347964/rotary-body-armor ?
--[[
(ability.id = 348350 or ability.id = 346204 or ability.id = 1236348) and type = "begincast"
 or ability.id = 346006 and type = "cast"
 or ability.id = 345990 and (type = "applydebuff" or type = "removedebuff")
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--[[
local warnArmedSecurity				= mod:NewSpellAnnounce(346204, 2)
local warnFullyArmed				= mod:NewSpellAnnounce(348128, 3, nil, "Tank|Healer")
local warnContainmentCell			= mod:NewTargetNoFilterAnnounce(345990)--When cell forms
local warnInpoundContraband			= mod:NewTargetNoFilterAnnounce(345770, 2)--Not filtered, because if it's on a tank or healer its kinda important
local warnInpoundContrabandEnded	= mod:NewEndAnnounce(345770, 1)

local specWarnInterrogation			= mod:NewSpecialWarningRun(348350, nil, nil, nil, 4, 2)
local yellInterrogation				= mod:NewYell(348350)
local specWarnInterrogationOther	= mod:NewSpecialWarningSwitchCustom(348350, "Dps", nil, nil, 1, 2)
local specWarnContainmentCell		= mod:NewSpecialWarningYou(345990, false, nil, nil, 1, 2)--Optional, but probably don't need, you already know it's you from targetting debuff
local specWarnInpoundContraband		= mod:NewSpecialWarningYou(345770, nil, nil, nil, 1, 2)
local specWarnChargedSlash			= mod:NewSpecialWarningDodge(1236348, nil, nil, nil, 2, 15)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(348366, nil, nil, nil, 1, 8)

local timerInterrogationCD			= mod:NewCDTimer(40.1, 348350, nil, nil, nil, 3)
local timerArmedSecurityCD			= mod:NewVarTimer("v34.4-53", 346204, nil, nil, nil, 6)
local timerImpoundContrabandCD		= mod:NewVarTimer("v26.7-35.8", 345770, nil, nil, nil, 3)--Can't be cast if containment is still active
local timerChargedSlashCD			= mod:NewVarTimer("v17-24.4", 1236348, nil, nil, nil, 3)
--local timerStichNeedleCD			= mod:NewAITimer(15.8, 320200, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)--Basically spammed

function mod:OnCombatStart(delay)
	timerArmedSecurityCD:Start(7.2-delay)
	timerChargedSlashCD:Start(12.1-delay)
	timerImpoundContrabandCD:Start(18.1-delay)
	timerInterrogationCD:Start(39.8-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 346204 then
		warnArmedSecurity:Show()
		timerArmedSecurityCD:Start()
	elseif spellId == 1236348 then
		specWarnChargedSlash:Show()
		specWarnChargedSlash:Play("frontal")
		timerChargedSlashCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 346006 then
		timerImpoundContrabandCD:Start()
	elseif spellId == 348350 then
		timerInterrogationCD:Start(38.6)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 347949 and args:IsDestTypePlayer() then
		if args:IsPlayer() then
			specWarnInterrogation:Show()
			specWarnInterrogation:Play("targetyou")
			yellInterrogation:Yell()
		else
			specWarnInterrogationOther:Show(args.destName)
			specWarnInterrogationOther:Play("targetchange")
		end
	elseif spellId == 348128 then
		warnFullyArmed:Show()
	elseif spellId == 345770 then
		warnInpoundContraband:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnInpoundContraband:Show()
			specWarnInpoundContraband:Play("targetyou")
		end
	elseif spellId == 345990 then
		timerInterrogationCD:Stop()
		timerImpoundContrabandCD:Stop()
		timerArmedSecurityCD:Stop()
		timerChargedSlashCD:Stop()
		--Timers resume on removal
		if args:IsPlayer() then
			specWarnContainmentCell:Show()
			specWarnContainmentCell:Play("targetyou")
		else
			warnContainmentCell:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 345770 then
		if args:IsPlayer() then
			warnInpoundContrabandEnded:Show()
		end
	elseif spellId == 345990 then--Containment Cell
		timerArmedSecurityCD:Start(7)
		timerChargedSlashCD:Start(12.7)
		timerImpoundContrabandCD:Start(21)
		timerInterrogationCD:Start(32.5)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 348366 and destGUID == UnitGUID("player") and self:AntiSpam(2, 1) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
