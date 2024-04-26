local mod	= DBM:NewMod(2492, "DBM-Party-Dragonflight", 6, 1203)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186644)
mod:SetEncounterID(2582)
mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20221127000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 374364 374567 386660 374789",
	"SPELL_CAST_SUCCESS 374720",
	"SPELL_AURA_APPLIED 374567",
	"SPELL_AURA_REMOVED 374567"
)

--TODO, verify number of players affected by explosive eruption
--TODO, who does Errupting Fissure target? verify target scan
--[[
(ability.id = 374364 or ability.id = 374567 or ability.id = 386660 or ability.id = 374789) and type = "begincast"
 or ability.id =  374720 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnLeylineSprouts						= mod:NewCountAnnounce(374364, 3)
local warnExplosiveEruption						= mod:NewTargetNoFilterAnnounce(374567, 4)

local specWarnExplosiveEruption					= mod:NewSpecialWarningYouPos(374567, nil, nil, nil, 1, 2)
local yellExplosiveEruption						= mod:NewShortPosYell(374567)
local yellExplosiveEruptionFades				= mod:NewIconFadesYell(374567)
local specWarnConsumingStomp					= mod:NewSpecialWarningCount(374720, nil, nil, nil, 2, 2)
local specWarnEruptingFissure					= mod:NewSpecialWarningDodgeCount(386660, nil, nil, nil, 2, 2)
local yellEruptingFissure						= mod:NewYell(386660)
local specWarnInfusedStrike						= mod:NewSpecialWarningDefensive(374789, nil, nil, nil, 1, 2)

local timerLeylineSproutsCD						= mod:NewCDCountTimer(48.1, 374364, nil, nil, nil, 3)
local timerExplosiveEruptionCD					= mod:NewCDCountTimer(48.5, 374567, nil, nil, nil, 3)
local timerConsumingStompCD						= mod:NewCDCountTimer(48.5, 374720, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON)
local timerEruptingFissureCD					= mod:NewCDCountTimer(48.5, 386660, nil, nil, nil, 3)
local timerInfusedStrikeCD						= mod:NewCDCountTimer(48.5, 374789, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddSetIconOption("SetIconOnExplosiveEruption", 374567, true, false, {1, 2, 3})

mod.vb.DebuffIcon = 1
mod.vb.leylineCount = 0
mod.vb.explosiveCount = 0
mod.vb.stompCount = 0
mod.vb.fissureCount = 0
mod.vb.strikeCount = 0

function mod:EruptionTarget(targetname)
	if not targetname then return end
	if targetname == UnitName("player") then
		yellEruptingFissure:Yell()
	end
end

function mod:OnCombatStart(delay)
	self.vb.DebuffIcon = 1
	self.vb.leylineCount = 0
	self.vb.explosiveCount = 0
	self.vb.stompCount = 0
	self.vb.fissureCount = 0
	self.vb.strikeCount = 0
	timerLeylineSproutsCD:Start(3.2-delay, 1)
	timerInfusedStrikeCD:Start(10.1-delay, 1)
	timerEruptingFissureCD:Start(20.2-delay, 1)
	timerExplosiveEruptionCD:Start(30.1-delay, 1)
	timerConsumingStompCD:Start(45.3-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 374364 then
		self.vb.leylineCount = self.vb.leylineCount + 1
		warnLeylineSprouts:Show(self.vb.leylineCount)
		timerLeylineSproutsCD:Start(nil, self.vb.leylineCount+1)
	elseif spellId == 374567 then
		self.vb.DebuffIcon = 1
		self.vb.explosiveCount = self.vb.explosiveCount + 1
		timerExplosiveEruptionCD:Start(nil, self.vb.explosiveCount+1)
	elseif spellId == 386660 then
		self.vb.fissureCount = self.vb.fissureCount + 1
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "EruptionTarget", 0.1, 8, true)
		specWarnEruptingFissure:Show(self.vb.fissureCount)
		specWarnEruptingFissure:Play("shockwave")
		timerEruptingFissureCD:Start(nil, self.vb.fissureCount+1)
	elseif spellId == 374789 then
		self.vb.strikeCount = self.vb.strikeCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnInfusedStrike:Show()
			specWarnInfusedStrike:Play("defensive")
		end
		timerInfusedStrikeCD:Start(nil, self.vb.strikeCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 374720 then
		self.vb.stompCount  = self.vb.stompCount  + 1
		specWarnConsumingStomp:Show(self.vb.stompCount )
		specWarnConsumingStomp:Play("aesoon")
		timerConsumingStompCD:Start(nil, self.vb.stompCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 374567 then
		local icon = self.vb.DebuffIcon
		if self.Options.SetIconOnExplosiveEruption then
			self:SetIcon(args.destName, icon)
		end
		if args:IsPlayer() then
			specWarnExplosiveEruption:Show(self:IconNumToTexture(icon))
			specWarnExplosiveEruption:Play("mm"..icon)
			yellExplosiveEruption:Yell(icon, icon)
			yellExplosiveEruptionFades:Countdown(spellId, nil, icon)
		else
			warnExplosiveEruption:CombinedShow(0.5, args.destName)
		end
		self.vb.DebuffIcon = self.vb.DebuffIcon + 1
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 374567 then
		if self.Options.SetIconOnExplosiveEruption then
			self:SetIcon(args.destName, 0)
		end
	end
end
