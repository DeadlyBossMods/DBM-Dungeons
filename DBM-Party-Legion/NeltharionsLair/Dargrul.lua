local mod	= DBM:NewMod(1687, "DBM-Party-Legion", 5, 767)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(91007)
mod:SetEncounterID(1793)
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 200732 200551 200637 200700 200404",
	"SPELL_AURA_APPLIED 200154",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

--[[
(ability.id = 200732 or ability.id = 200551 or ability.id = 200637 or ability.id = 200700 or ability.id = 200404) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnCrystalSpikes				= mod:NewSpellAnnounce(200551, 2)
local warnBurningHatred				= mod:NewTargetAnnounce(200154, 2)

local specWarnMoltenCrash			= mod:NewSpecialWarningDefensive(200732, nil, nil, nil, 3, 2)
local specWarnLandSlide				= mod:NewSpecialWarningSpell(200700, "Tank", nil, nil, 1, 2)
local specWarnMagmaSculptor			= mod:NewSpecialWarningSwitchCount(200637, "Dps", nil, nil, 1, 2)
local specWarnMagmaWave				= mod:NewSpecialWarningMoveTo(200404, nil, nil, nil, 2, 2)
local specWarnBurningHatred			= mod:NewSpecialWarningYou(200154, nil, nil, nil, 1, 2)

local timerMoltenCrashCD			= mod:NewCDCountTimer(16.5, 200732, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON, nil, 2, 3)--16.5-23
local timerLandSlideCD				= mod:NewCDTimer(16.5, 200700, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--16.5-27
local timerCrystalSpikesCD			= mod:NewCDTimer(21.4, 200551, nil, nil, nil, 3)
local timerMagmaSculptorCD			= mod:NewCDCountTimer(71, 200637, nil, nil, nil, 1)--Everyone?
local timerMagmaWaveCD				= mod:NewCDCountTimer(60, 200404, nil, nil, nil, 2, nil, DBM_COMMON_L.DEADLY_ICON, nil, 1, 4)

local shelterName = DBM:GetSpellName(200551)

mod.vb.waveCount = 0
mod.vb.crashCount = 0
mod.vb.addCount = 0

function mod:OnCombatStart(delay)
	self.vb.waveCount = 0
	self.vb.crashCount = 0
	self.vb.addCount = 0
	timerCrystalSpikesCD:Start(5.8-delay)
	timerMagmaSculptorCD:Start(7.3-delay, 1)
	timerLandSlideCD:Start(15.5-delay)
	timerMoltenCrashCD:Start(18.7-delay, 1)
	timerMagmaWaveCD:Start(60.7-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 200732 then
		self.vb.crashCount = self.vb.crashCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnMoltenCrash:Show()
			specWarnMoltenCrash:Play("defensive")
		end
		timerMoltenCrashCD:Start(nil, self.vb.crashCount+1)
	elseif spellId == 200551 then
		warnCrystalSpikes:Show()
		timerCrystalSpikesCD:Start()
	elseif spellId == 200637 then
		self.vb.addCount = self.vb.addCount + 1
		specWarnMagmaSculptor:Show(self.vb.addCount)
		specWarnMagmaSculptor:Play("killbigmob")
		timerMagmaSculptorCD:Start(nil, self.vb.addCount+1)
	elseif spellId == 200700 then
		specWarnLandSlide:Show()
		specWarnLandSlide:Play("shockwave")
		timerLandSlideCD:Start()
	elseif spellId == 200404 and self:AntiSpam(8, 1) then
		self.vb.waveCount = self.vb.waveCount + 1
		specWarnMagmaWave:Show(shelterName)
		specWarnMagmaWave:Play("findshelter")
		timerMagmaWaveCD:Start(nil, self.vb.waveCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 200154 then
		if args:IsPlayer() then
			specWarnBurningHatred:Show()
			specWarnBurningHatred:Play("targetyou")
		else
			warnBurningHatred:Show(args.destName)
		end
	end
end

--1 second faster than combat log. 1 second slower than Unit event callout but that's no longer reliable.
function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg:find("spell:200404") and self:AntiSpam(8, 1) then
		self.vb.waveCount = self.vb.waveCount + 1
		specWarnMagmaWave:Show(shelterName)
		specWarnMagmaWave:Play("findshelter")
		timerMagmaWaveCD:Start(nil, self.vb.waveCount+1)
	end
end
