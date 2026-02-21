local mod	= DBM:NewMod(2387, "DBM-Party-Shadowlands", 4, 1185)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(164185)
mod:SetEncounterID(2380)
mod:SetHotfixNoticeRev(20250808000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2287)

mod:RegisterCombat("combat")

--Custom Sounds on cast/cooldown expiring
mod:AddCustomAlertSoundOption(326389, true, 2)--Blood Torrent
mod:AddCustomAlertSoundOption(319733, true, 1)--Stone Call
mod:AddCustomAlertSoundOption(319941, true, 2)--Stone Shattering Leap
--Custom timer colors, countdowns, and disables
mod:AddCustomTimerOptions(326389, true, 2, 0)
mod:AddCustomTimerOptions(319733, true, 1, 0)
mod:AddCustomTimerOptions(328206, true, 3, 0)--Curse of Stone
mod:AddCustomTimerOptions(319941, true, 3, 0)

function mod:OnLimitedCombatStart()
	self:EnableAlertOptions(326389, 488, "aesoon", 2)
	self:EnableAlertOptions(319733, 489, "mobsoon", 2)
	self:EnableAlertOptions(319941, 496, "specialsoon", 2)

	self:EnableTimelineOptions(326389, 488)
	self:EnableTimelineOptions(319733, 489)
	self:EnableTimelineOptions(328206, 490)
	self:EnableTimelineOptions(319941, 496)
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 319733 319941",
	"SPELL_CAST_SUCCESS 328206 326389",
	"SPELL_AURA_APPLIED 319603 319724",
	"SPELL_AURA_REMOVED 319724"
)
--]]

--TODO, verify Leap target scanning, if doesn't work, maybe hidden aura scan or RAID_WHISPER event
--TODO, https://shadowlands.wowhead.com/spell=319611/turned-to-stone needed?
--TODO, switch to more efficient and faster UNIT_TARGET scanner if timing works out
--TODO, more timer refinements to do better prediction of spell queuing from timer interactions
--[[
(ability.id = 319941 or ability.id = 319733) and type = "begincast"
 or (ability.id = 328206 or ability.id = 326389) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --]]
 --[[
local warnStoneShatteringLeap		= mod:NewTargetNoFilterAnnounce(319941, 3)
local warnStonesCall				= mod:NewCountAnnounce(319733, 2)

local specWarnCurseofStoneDispel	= mod:NewSpecialWarningDispel(328206, "RemoveCurse", nil, nil, 1, 2)
local specWarnCurseofStone			= mod:NewSpecialWarningYou(328206, nil, nil, nil, 1, 2)
local specWarnBloodTorrent			= mod:NewSpecialWarningCount(326389, nil, nil, nil, 2, 2)
local specWarnStoneShatteringLeap	= mod:NewSpecialWarningYou(319941, nil, 47482, nil, 1, 2)
local yellStoneShatteringLeap		= mod:NewYell(319941, 47482)
local yellStoneShatteringLeapFades	= mod:NewShortFadesYell(319941, 47482)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerStoneCallCD				= mod:NewVarCountTimer("v42.5-53", 319733, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerStoneShatteringLeapCD	= mod:NewVarCountTimer("v28.3-32.7", 319941, 47482, nil, nil, 3)--shortText "Leap"
local timerCurseofStoneCD			= mod:NewVarCountTimer("v28.3-33.5", 328206, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerBloodTorrentCD			= mod:NewVarCountTimer("v16.9-29.1", 326389, nil, nil, nil, 2)--16.9 unless delayed by one of other casts

mod:AddNamePlateOption("NPAuraOnStoneForm", 319724)

mod.vb.stoneCallCount = 0
mod.vb.shatteringLeapCount = 0
mod.vb.curseCount = 0
mod.vb.torrentCount = 0

function mod:LeapTarget(targetname, _, _, scanningTime)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnStoneShatteringLeap:Show()
		specWarnStoneShatteringLeap:Play("targetyou")
		yellStoneShatteringLeap:Yell()
		yellStoneShatteringLeapFades:Countdown(5-scanningTime)
	else
		warnStoneShatteringLeap:Show(targetname)
	end
end

function mod:OnCombatStart(delay)
	self.vb.stoneCallCount = 0
	self.vb.shatteringLeapCount = 0
	self.vb.curseCount = 0
	self.vb.torrentCount = 0
	timerBloodTorrentCD:Start(6-delay, 1)--SUCCESS
	timerStoneCallCD:Start(9.2-delay, 1)--START
	timerCurseofStoneCD:Start(21.6-delay, 1)--SUCCESS
	timerStoneShatteringLeapCD:Start(23.1-delay, 1)--START
	if self.Options.NPAuraOnStoneForm then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	if self.Options.NPAuraOnStoneForm then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 319733 then
		self.vb.stoneCallCount = self.vb.stoneCallCount + 1
		warnStonesCall:Show(self.vb.stoneCallCount)
		timerStoneCallCD:Start(nil, self.vb.stoneCallCount+1)
	elseif spellId == 319941 then
		self.vb.shatteringLeapCount = self.vb.shatteringLeapCount + 1
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "LeapTarget", 0.1, 8, true, nil, nil, nil, true)
		timerStoneShatteringLeapCD:Start(nil, self.vb.shatteringLeapCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 328206 then
		self.vb.curseCount = self.vb.curseCount + 1
		timerCurseofStoneCD:Start(nil, self.vb.curseCount+1)
	elseif spellId == 326389 then
		self.vb.torrentCount = self.vb.torrentCount + 1
		specWarnBloodTorrent:Show(self.vb.torrentCount)
		specWarnBloodTorrent:Play("aesoon")
		timerBloodTorrentCD:Start(nil, self.vb.torrentCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 319603 then
		if self.Options.SpecWarn319603dispel and self:CheckDispelFilter("curse") then
			specWarnCurseofStoneDispel:CombinedShow(0.3, args.destName)
			specWarnCurseofStoneDispel:ScheduleVoice(0.3, "helpdispel")
		elseif args:IsPlayer() then
			specWarnCurseofStone:Show()
			specWarnCurseofStone:Play("targetyou")
		end
	elseif spellId == 319724 then
		if self.Options.NPAuraOnStoneForm then
			DBM.Nameplate:Show(true, args.sourceGUID, spellId, nil, 30)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 319724 then
		if self.Options.NPAuraOnStoneForm then
			DBM.Nameplate:Hide(true, args.sourceGUID, spellId)
		end
	end
end
--]]
