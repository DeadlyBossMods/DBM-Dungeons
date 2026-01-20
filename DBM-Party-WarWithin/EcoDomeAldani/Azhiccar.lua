local mod	= DBM:NewMod(2675, "DBM-Party-WarWithin", 10, 1303)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(234893)
mod:SetEncounterID(3107)
mod:SetHotfixNoticeRev(20250728000000)
--mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2830)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

--Midnight private aura replacements
mod:AddPrivateAuraSoundOption(1217446, true, 1217446, 1)--GTFO

function mod:OnLimitedCombatStart()
	self:EnablePrivateAuraSound(1217446, "watchfeet", 8)
end

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1217232 1217327 1227745",
	"SPELL_CAST_SUCCESS 1217232",
	"SPELL_AURA_APPLIED 1217247",
	"SPELL_AURA_APPLIED_DOSE 1217247",
	"SPELL_PERIODIC_DAMAGE 1217446",
	"SPELL_PERIODIC_MISSED 1217446",
	"RAID_BOSS_WHISPER"
)
--]]

--[[

 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--[[
local warnToxicRegurgitation			= mod:NewTargetNoFilterAnnounce(1227745, 3)
local warnFeastStack					= mod:NewStackAnnounce(1217247, 4)

local specWarnDevour					= mod:NewSpecialWarningCount(1217232, nil, nil, nil, 2, 12)
local specWarnInvadingShriek			= mod:NewSpecialWarningSwitchCount(1217327, "Dps", nil, nil, 1, 2)
local specWarnToxicRegurgitation		= mod:NewSpecialWarningMoveAwayCount(1227745, nil, nil, nil, 1, 2)
local yellToxicRegurgitation			= mod:NewShortYell(1227745)
local yellToxicRegurgitationFades		= mod:NewShortFadesYell(1227745)
local specWarnGTFO						= mod:NewSpecialWarningGTFO(1217446, nil, nil, nil, 1, 8)

local timerDevourCD						= mod:NewCDCountTimer(86.1, 1217232, nil, nil, nil, 2)
local timerDevourCast					= mod:NewCastTimer(18, 1217232, nil, nil, nil, 5)
local timerInvadingShriekCD				= mod:NewCDCountTimer(30.1, 1217327, nil, nil, nil, 1)
local timerToxicRegurgitationCD			= mod:NewCDCountTimer(30.1, 1227745, nil, nil, nil, 3)

mod.vb.devourCount = 0
mod.vb.invadingShriekCount = 0
mod.vb.toxicRegurgitationCount = 0

function mod:OnCombatStart(delay)
	self.vb.devourCount = 0
	self.vb.invadingShriekCount = 0
	self.vb.toxicRegurgitationCount = 0
	timerInvadingShriekCD:Start(5.1-delay, 1)
	timerToxicRegurgitationCD:Start(15.4-delay, 1)
	timerDevourCD:Start(60-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 1217232 then
		self.vb.devourCount = self.vb.devourCount + 1
		specWarnDevour:Show(self.vb.devourCount)
		specWarnDevour:Play("pullin")
		timerDevourCD:Start(nil, self.vb.devourCount+1)
	elseif spellId == 1217327 then
		self.vb.invadingShriekCount = self.vb.invadingShriekCount + 1
		specWarnInvadingShriek:Show(self.vb.invadingShriekCount)
		specWarnInvadingShriek:Play("killmob")
		if self.vb.invadingShriekCount % 2 == 0 then
			timerInvadingShriekCD:Start(47.3, self.vb.invadingShriekCount+1)
		else
			timerInvadingShriekCD:Start(37.2, self.vb.invadingShriekCount+1)
		end
	elseif spellId == 1227745 then
		self.vb.toxicRegurgitationCount = self.vb.toxicRegurgitationCount + 1
		if self.vb.toxicRegurgitationCount % 2 == 0 then
			timerToxicRegurgitationCD:Start(67.9, self.vb.toxicRegurgitationCount+1)
		else
			timerToxicRegurgitationCD:Start(18.2, self.vb.toxicRegurgitationCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 1217232 then
		timerDevourCast:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 1217247 then
		warnFeastStack:Show(args.destName, args.amount or 1)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 1217446 and destGUID == UnitGUID("player") and self:AntiSpam(3, 1) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("spell:1227748") then
		specWarnToxicRegurgitation:Show(self.vb.toxicRegurgitationCount)
		specWarnToxicRegurgitation:Play("runout")
		yellToxicRegurgitation:Yell()
		yellToxicRegurgitationFades:Countdown(6)--6 On Mythic 0, maybe lower on M+? (tooltip says 8 btw, typical blizzard)
	end
end

function mod:OnTranscriptorSync(msg, targetName)
	if msg:find("1227748") and targetName and self:AntiSpam(5, targetName) then
		targetName = Ambiguate(targetName, "none")
		warnToxicRegurgitation:CombinedShow(0.5, targetName)
	end
end
--]]
