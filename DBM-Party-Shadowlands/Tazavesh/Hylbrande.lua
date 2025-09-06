local mod	= DBM:NewMod(2448, "DBM-Party-Shadowlands", 9, 1194)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(175663)
mod:SetEncounterID(2426)
mod:SetUsedIcons(1, 2)
mod:SetHotfixNoticeRev(20220404000000)
mod:SetZone(2441)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 347094 346957 346766 358131 353312",
	"SPELL_CAST_SUCCESS 346116 181113",
	"SPELL_AURA_APPLIED 358131 346427",
	"SPELL_AURA_REMOVED 347958 346766 346427",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_DIED"
	"RAID_BOSS_WHISPER",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, Are swings dogeable by tank?
--[[
(ability.id = 347094 or ability.id = 346957 or ability.id = 346766 or ability.id = 358131 or ability.id = 353312) and type = "begincast"
 or (ability.id = 346116 or ability.id = 181113) and type = "cast"
 or ability.id = 346766
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnPurgedbyFire				= mod:NewTargetNoFilterAnnounce(346959, 2)
local warnKeepersprotection			= mod:NewEndAnnounce(347958, 1)
local warnLightningNova				= mod:NewTargetNoFilterAnnounce(358131, 3)
local warnVaultPurifierSoon			= mod:NewSoonAnnounce(-23004, 2, "136116", false)
local warnVaultPurifier				= mod:NewSpellAnnounce(-23004, 2, "136116")
local warnPurifyingBurst			= mod:NewCountAnnounce(353312, 2)
local warnTitanicInsight			= mod:NewTargetNoFilterAnnounce(346427, 2)

local specWarnPurgedByFire			= mod:NewSpecialWarningYou(346959, nil, nil, nil, 1, 2)
local yellPurgedByFire				= mod:NewYell(346959)
local specWarnShearingSwings		= mod:NewSpecialWarningDefensive(346116, nil, nil, nil, 1, 2)
local specWarnTitanicCrash			= mod:NewSpecialWarningDodge(347094, nil, nil, nil, 2, 2)
local specWarnSanitizingCycle		= mod:NewSpecialWarningCount(346766, nil, nil, nil, 2, 2)
local specWarnLigtningNova			= mod:NewSpecialWarningInterrupt(358131, "HasInterrupt", nil, nil, 1, 2)--Hard Mode
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(320366, nil, nil, nil, 1, 8)

local timerShearingSwingsCD			= mod:NewCDCountTimer(10.5, 346116, nil, nil, nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerTitanicCrashCD			= mod:NewCDCountTimer(23.1, 347094, nil, nil, nil, 3)
local timerPurgedbyFireCD			= mod:NewCDCountTimer(15.7, 346959, nil, nil, nil, 3)
local timerSanitizingCycleCD		= mod:NewCDCountTimer(99, 346766, nil, nil, nil, 6)
local timerVaultPurifierCD			= mod:NewCDCountTimer(29.1, -23004, nil, nil, nil, 1, "136116", DBM_COMMON_L.DAMAGE_ICON)
local timerPurifyingBurstCD			= mod:NewCDCountTimer(20.2, 353312, nil, nil, nil, 2)
local timerTitanicInsight			= mod:NewTargetTimer(15, 346427, nil, nil, nil, 5)

mod:AddSetIconOption("SetIconOnAdds", -23004, true, 5, {1, 2})

mod.vb.swingsCount = 0
mod.vb.titanicCrashCount = 0
mod.vb.purgedCount = 0
mod.vb.cycleCount = 0
mod.vb.vaultPurifierCount = 0
mod.vb.burstCount = 0
mod.vb.addIcon = 1

function mod:OnCombatStart(delay)
	self.vb.swingsCount = 0
	self.vb.titanicCrashCount = 0
	self.vb.purgedCount = 0
	self.vb.cycleCount = 0
	self.vb.vaultPurifierCount = 0
	self.vb.burstCount = 0
	--TODO, hard mode check shit for purifying Burst (is it cast more often? or just more targets?)
	timerPurifyingBurstCD:Start(5.2-delay, 1)
	timerShearingSwingsCD:Start(8.5-delay, 1)
	timerPurgedbyFireCD:Start(10.8-delay, 1)
	timerTitanicCrashCD:Start(15.8-delay, 1)
	timerVaultPurifierCD:Start(22.3-delay, 1)
	timerSanitizingCycleCD:Start(37.8-delay, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 347094 then
		self.vb.titanicCrashCount = self.vb.titanicCrashCount + 1
		specWarnTitanicCrash:Show()
		specWarnTitanicCrash:Play("shockwave")
		if timerSanitizingCycleCD:GetRemaining(self.vb.cycleCount+1) >= 23.1 then
			timerTitanicCrashCD:Start(nil, self.vb.titanicCrashCount+1)
		end
	elseif spellId == 346957 then
--		warnPurgedbyFire:Show()
		self.vb.purgedCount = self.vb.purgedCount + 1
		if timerSanitizingCycleCD:GetRemaining(self.vb.cycleCount+1) >= 17 then
			timerPurgedbyFireCD:Start(nil, self.vb.purgedCount+1)
		end
	elseif spellId == 346766 and self:AntiSpam(3, 1) then
		self.vb.cycleCount = self.vb.cycleCount + 1
		specWarnSanitizingCycle:Show(self.vb.cycleCount)
		specWarnSanitizingCycle:Play("specialsoon")
		timerShearingSwingsCD:Stop()
		timerTitanicCrashCD:Stop()
		timerPurgedbyFireCD:Stop()
		timerSanitizingCycleCD:Stop()
		timerVaultPurifierCD:Stop()
		timerPurifyingBurstCD:Stop()
	elseif spellId == 358131 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnLigtningNova:Show(args.sourceName)
			specWarnLigtningNova:Play("kickcast")
		end
	elseif spellId == 353312 then
		self.vb.burstCount = self.vb.burstCount + 1
		warnPurifyingBurst:Show(self.vb.burstCount)
		if timerSanitizingCycleCD:GetRemaining(self.vb.cycleCount+1) >= 20.2 then
			timerPurifyingBurstCD:Start(nil, self.vb.burstCount+1)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 346116 then
		self.vb.swingsCount = self.vb.swingsCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnShearingSwings:Show()
			specWarnShearingSwings:Play("defensive")
		end
		if timerSanitizingCycleCD:GetRemaining(self.vb.cycleCount+1) >= 10.9 then
			timerShearingSwingsCD:Start(nil, self.vb.swingsCount+1)
		end
	elseif spellId == 181113 then
		if self:AntiSpam(3, 2) then
			self.vb.vaultPurifierCount = self.vb.vaultPurifierCount + 1
			warnVaultPurifier:Show()
			if timerSanitizingCycleCD:GetRemaining(self.vb.cycleCount+1) >= 29.1 then
				timerVaultPurifierCD:Start(nil, self.vb.vaultPurifierCount+1)
			end
		end
		if self.Options.SetIconOnAdds then
			self:ScanForMobs(args.sourceGUID, 2, self.vb.addIcon, 1, nil, 12, "SetIconOnAdds")
		end
		self.vb.addIcon = self.vb.addIcon + 1
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 358131 then
		warnLightningNova:Show(args.destName)
	elseif spellId == 346427 then
		warnTitanicInsight:Show(args.destName)
		timerTitanicInsight:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 347958 then
		warnKeepersprotection:Show()
	elseif spellId == 346427 then
		timerTitanicInsight:Stop(args.destName)
	elseif spellId == 346766 and self:AntiSpam(3, 3) then
		self.vb.cycleCount = self.vb.cycleCount + 1
		--TODO, hard mode check shit for purifying Burst
		timerPurifyingBurstCD:Start(13.2, self.vb.burstCount+1)
		timerShearingSwingsCD:Start(15.6, self.vb.swingsCount+1)--Might be 17.7 now
		timerPurgedbyFireCD:Start(19, self.vb.purgedCount+1)
		timerTitanicCrashCD:Start(22.9, self.vb.titanicCrashCount+1)
		timerVaultPurifierCD:Start(21.8, self.vb.vaultPurifierCount+1)
		timerSanitizingCycleCD:Start(68.1, self.vb.cycleCount+1)--Needs reconfirmation
	end
end

--"<20.66 04:58:21> [CLEU] SPELL_CAST_START#Creature-0-4255-2441-7585-175667-000065FF9A#Защитная турель титанов##nil#346957#Очищение огнем#nil#nil", -- [239]
--"<20.66 04:58:21> [UNIT_SPELLCAST_SUCCEEDED] Хильбранд(Хаосхантер) -Очищение огнем- [[boss1:Cast-3-4255-2441-7585-346964-0007E6003E:346964]]", -- [240]
--"<20.85 04:58:21> [CHAT_MSG_RAID_BOSS_WHISPER] %s получает новую цель.#Защитная турель титанов###Хаосхантер##0#0##0#46#nil#0#false#false#false#false", -- [241]
--"<20.85 04:58:21> [RAID_BOSS_WHISPER] %s получает новую цель.#Защитная турель титанов#3#true", -- [242]
function mod:RAID_BOSS_WHISPER()
	specWarnPurgedByFire:Show()
	specWarnPurgedByFire:Play("targetyou")
	yellPurgedByFire:Yell()
end

function mod:OnTranscriptorSync(_, targetName)
	if targetName then
		targetName = Ambiguate(targetName, "none")
		warnPurgedbyFire:Show(targetName)
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 320366 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 176551 then--vault-purifier

	elseif cid == 180640 then--stormbound-breaker

	end
end
--]]

--"<18.17 01:11:30> [UNIT_SPELLCAST_SUCCEEDED] Hylbrande(??) -[DNT] Summon Vault Defender- [[boss1:Cast-3-4234-2441-16984-346971-002B48CA12:346971]]", -- [147]
--"<22.32 01:11:34> [CLEU] SPELL_CAST_SUCCESS#Creature-0-4234-2441-16984-176551-000048CA12#Vault Purifier##nil#181113#Encounter Spawn#nil#nil", -- [188]
function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 346971 then--Summon Vault Defender
		self.vb.addIcon = 1
		warnVaultPurifierSoon:Show()
	end
end

