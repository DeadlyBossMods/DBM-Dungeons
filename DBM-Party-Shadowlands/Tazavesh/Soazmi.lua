local mod	= DBM:NewMod(2451, "DBM-Party-Shadowlands", 9, 1194)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(175806)
mod:SetEncounterID(2437)
mod:SetHotfixNoticeRev(20220405000000)
mod:SetZone(2441)

mod:RegisterCombat("combat")

mod:RegisterSafeEvents(
	"CHAT_MSG_MONSTER_SAY"
)

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(347481, true, 2)--Shurl
mod:AddCustomAlertSoundOption(347150, "HasInterrupt", 1)--Triple Technique
mod:AddCustomAlertSoundOption(357188, "HasInterrupt", 1)--Double Technique
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(347481, true, 2, 0)--Shurl
mod:AddCustomTimerOptions(1248209, true, 5, 0)--Phase Slash
mod:AddCustomTimerOptions(347150, true, 4, 0)--Triple Technique
mod:AddCustomTimerOptions(357188, true, 4, 0)--Double Technique

function mod:OnLimitedCombatStart()
	self:DisableSpecialWarningSounds()
	self:EnableAlertOptions(347481, 582, "specialsoon", 2)
	self:EnableAlertOptions(347150, 584, "kickcast", 2)
	self:EnableAlertOptions(357188, 585, "kickcast", 2)
	self:EnableTimelineOptions(347481, 582)
	self:EnableTimelineOptions(1248209, 583)
	self:EnableTimelineOptions(347150, 584)
	self:EnableTimelineOptions(357188, 585)
end

local timerRP	= mod:NewRPTimer(24)
--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 347392 347249 347414 347623 347610 357188 347150 1245634 355830 1245752 1245669",
	"SPELL_AURA_APPLIED 357189 347152 1245677 1245751",
	"SPELL_AURA_REMOVED 357189 347152 1245677 1245751",
	"SPELL_AURA_REMOVED_DOSE 357189 347152 1245677 1245751"
)
--]]

--[[
(ability.id = 347392 or ability.id = 347249 or ability.id = 347414 or ability.id = 347623 or ability.id = 347610 or ability.id = 357188 or ability.id = 347150) and type = "begincast"
 or ability.id = 357189 or ability.id = 347152
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--TODO, needs massive fixup once I can compare M+ to M0 version on WCL
--[[
local warnDivide					= mod:NewCountAnnounce(347249, 3)
local warnQuickblade				= mod:NewSpellAnnounce(347623, 3)

local specWarnShurl					= mod:NewSpecialWarningMoveTo(347481, nil, nil, nil, 4, 2)
local specWarnDoubleTechnique		= mod:NewSpecialWarningInterruptCount(357188, "HasInterrupt", nil, nil, 1, 3)
local specWarnTripleTechnique		= mod:NewSpecialWarningInterruptCount(347150, "HasInterrupt", nil, nil, 1, 3)

--Both timers are 15 but boss spell queuing is a nightmare. quickblade delays shurl and shurl delays quickblade and they can come in any order
--Double and triple technique also delay both even more
local timerShurlCD					= mod:NewCDTimer(15, 347481, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerQuickbladeCD				= mod:NewCDTimer(14.2, 347623, nil, nil, nil, 3)

local relocator = DBM:GetSpellName(347426)
mod.vb.techRemaining = 0
mod.vb.divideCount = 0

function mod:OnCombatStart(delay)
	self.vb.techRemaining = 0
	self.vb.divideCount = 0
	timerQuickbladeCD:Start(8.1-delay)
	timerShurlCD:Start(19-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 347249 or spellId == 347414 or spellId == 1245634 then
		self.vb.divideCount = self.vb.divideCount + 1
		warnDivide:Show(self.vb.divideCount)
		timerQuickbladeCD:Stop()
		timerShurlCD:Stop()
	elseif spellId == 347623 or spellId == 355830 then
		warnQuickblade:Show()
		timerQuickbladeCD:Start()
	elseif spellId == 347610 then
		specWarnShurl:Show(relocator)
		specWarnShurl:Play("justrun")
		timerShurlCD:Start()
	elseif spellId == 357188 or spellId == 1245669 then
		if self.vb.techRemaining == 2 then
			specWarnDoubleTechnique:Show(args.sourceName, 1)
			specWarnDoubleTechnique:Play("kick1r")
		elseif self.vb.techRemaining == 1 then
			specWarnDoubleTechnique:Show(args.sourceName, 2)
			specWarnDoubleTechnique:Play("kick2r")
		end
	elseif spellId == 347150 or spellId == 1245752 then
		if self.vb.techRemaining == 3 then
			specWarnTripleTechnique:Show(args.sourceName, 1)
			specWarnTripleTechnique:Play("kick1r")
		elseif self.vb.techRemaining == 2 then
			specWarnTripleTechnique:Show(args.sourceName, 2)
			specWarnTripleTechnique:Play("kick2r")
		elseif self.vb.techRemaining == 1 then
			specWarnTripleTechnique:Show(args.sourceName, 3)
			specWarnTripleTechnique:Play("kick3r")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 357189 then
		self.vb.techRemaining = 2
	elseif spellId == 347152 then
		self.vb.techRemaining = 3
	elseif spellId == 1245677 then
		self.vb.techRemaining = 1
	elseif spellId == 1245751 then
		self.vb.techRemaining = 2
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 357189 or spellId == 347152 or spellId == 1245677 or spellId == 1245751 then
		local amount = args.amount or 0--amount reported for all (SPELL_AURA_APPLIED_DOSE) but 0 (SPELL_AURA_REMOVED)
		self.vb.techRemaining = amount
	end
end
mod.SPELL_AURA_REMOVED_DOSE = mod.SPELL_AURA_REMOVED
--]]

function mod:CHAT_MSG_MONSTER_SAY(msg)
	if self:issecretvalue(msg) then return end
	if (msg == L.RPTrigger or msg:find(L.RPTrigger)) and self:LatencyCheck() then
		self:SendSync("SolamiRP")
	end
end

function mod:OnSync(msg, targetname)
	if msg == "SolamiRP" and self:AntiSpam(10, 1) then
		timerRP:Start()
	end
end
