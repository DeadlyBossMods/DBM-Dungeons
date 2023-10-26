local mod	= DBM:NewMod(2126, "DBM-Party-BfA", 10, 1001)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(260551)
mod:SetEncounterID(2114)
mod:SetHotfixNoticeRev(20231025000000)
mod:SetMinSyncRevision(20231025000000)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 267907",
	"SPELL_CAST_START 260508",
	"SPELL_CAST_SUCCESS 260551 260508",
	"SPELL_SUMMON 267907"
	"RAID_BOSS_WHISPER"
)

--[[
ability.id = 260508 and type = "begincast"
 or ability.id = 260551 and type = "cast"
 or ability.id = 260541
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 --]]
--TODO, maybe readd stack counting instead of relying on blizzards emote for moving boss into fire
local warnBurningBush				= mod:NewSpellAnnounce(260541, 4)

local specWarnCrush					= mod:NewSpecialWarningDefensive(260508, "Tank", nil, nil, 1, 2)
local specWarnThorns				= mod:NewSpecialWarningSwitchCount(267907, "Dps", nil, nil, 1, 2)
local yellThorns					= mod:NewYell(267907)
local specWarnSoulHarvest			= mod:NewSpecialWarningMoveTo(260512, "Tank", nil, nil, 3, 2)
local specWarnGTFO					= mod:NewSpecialWarningGTFO(260569, nil, nil, nil, 1, 8)

--Timers subject to delays if boss gets stunned by fire
local timerCrushCD					= mod:NewCDCountTimer(15, 260508, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--15 after last cast FINISHES
local timerThornsCD					= mod:NewCDCountTimer(21.8, 267907, nil, nil, nil, 3, nil, DBM_COMMON_L.DAMAGE_ICON)

mod:AddSetIconOption("SetIconOnThorns", 267907, true, 5, {8})

mod.vb.crushCount = 0
mod.vb.thornsCount = 0

local wildfire = DBM:GetSpellInfo(260569)

function mod:OnCombatStart(delay)
	self.vb.crushCount = 0
	self.vb.thornsCount = 0
	timerCrushCD:Start(5.7-delay, 1)
	timerThornsCD:Start(8.1-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 260508 then
		specWarnCrush:Show()
		specWarnCrush:Play("defensive")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 260551 then
		self.vb.thornsCount = self.vb.thornsCount + 1
		timerThornsCD:Start(nil, self.vb.thornsCount+1)
	elseif spellId == 260508 then--Can stutter cast, so we only want to increment count and start timer on a successful one
		self.vb.crushCount = self.vb.crushCount + 1
		timerCrushCD:Start(15, self.vb.crushCount+1)
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 267907 then
		if self.Options.SetIconOnThorns then
			self:ScanForMobs(args.destGUID, 2, 8, 1, nil, 12, "SetIconOnThorns")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 267907 then
		if args:IsPlayer() then
			yellThorns:Yell()
		else
			specWarnThorns:Show(self.vb.thornsCount)
			specWarnThorns:Play("targetchange")
		end
	elseif spellId == 260541 then
		warnBurningBush:Show()
	elseif spellId == 260569 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end

function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("260512") then
		specWarnSoulHarvest:Show(wildfire)
		specWarnSoulHarvest:Play("moveboss")
	end
end
