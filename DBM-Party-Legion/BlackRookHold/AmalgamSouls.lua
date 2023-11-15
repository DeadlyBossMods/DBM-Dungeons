local mod	= DBM:NewMod(1518, "DBM-Party-Legion", 1, 740)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(98542)
mod:SetEncounterID(1832)
mod:SetHotfixNoticeRev(20231027000000)
mod:SetMinSyncRevision(20231027000000)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 195254 194966 194956 196078 196587",
	"SPELL_CAST_SUCCESS 196587",
	"SPELL_AURA_APPLIED 194966 196930",
	"SPELL_AURA_APPLIED_DOSE 196930"
)

--[[
(ability.id = 195254 or ability.id = 194966 or ability.id = 194956 or ability.id = 196078 or ability.id = 196587) and type = "begincast"
 or ability.id = 196587 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--NOTE, trash uses 194966 just like boss, the expression will pick up both
local warnSwirlingScythe			= mod:NewTargetNoFilterAnnounce(195254, 2)
local warnSoulEchoes				= mod:NewTargetAnnounce(194966, 2)
local warnCallSouls					= mod:NewSpellAnnounce(196078, 2)--Change to important warning if it becomes more relevant.
local warnSoulgorge					= mod:NewStackAnnounce(196930, 4)

local specWarnReapSoul				= mod:NewSpecialWarningDodge(194956, "Tank", nil, nil, 3, 2)
local specWarnSoulEchos				= mod:NewSpecialWarningRun(194966, nil, nil, nil, 1, 2)
local specWarnSwirlingScythe		= mod:NewSpecialWarningDodge(195254, nil, nil, nil, 1, 2)
local yellSwirlingScythe			= mod:NewYell(195254)
local specWarnSwirlingScytheNear	= mod:NewSpecialWarningClose(195254, nil, nil, nil, 1, 2)
local specWarnSoulBurst				= mod:NewSpecialWarningCount(196587, nil, nil, nil, 2, 2)

local timerSwirlingScytheCD			= mod:NewCDTimer(20.5, 195254, nil, nil, nil, 3)--20-27
local timerSoulEchoesCD				= mod:NewNextTimer(27.5, 194966, nil, nil, nil, 3)
local timerReapSoulCD				= mod:NewNextTimer(13, 194956, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.DEADLY_ICON)

--mod:AddRangeFrameOption(5, 194966)

mod.vb.scytheCount = 0
mod.vb.echoesCount = 0
mod.vb.reapCount = 0
mod.vb.burstCounnt = 0

function mod:ScytheTarget(targetname, uId)
	if not targetname then
		warnSwirlingScythe:Show(DBM_COMMON_L.UNKNOWN)
		return
	end
	if targetname == UnitName("player") then
		specWarnSwirlingScythe:Show()
		specWarnSwirlingScythe:Play("runaway")
		yellSwirlingScythe:Yell()
	elseif self:CheckNearby(6, targetname) then
		specWarnSwirlingScytheNear:Show(targetname)
		specWarnSwirlingScytheNear:Play("runaway")
	else
		warnSwirlingScythe:Show(targetname)
	end
end

function mod:SoulTarget(targetname, uId)
	if not targetname then
		return
	end
	if self:AntiSpam(3, targetname) then
		if targetname == UnitName("player") then
			specWarnSoulEchos:Show()
			specWarnSoulEchos:Play("runaway")
			specWarnSoulEchos:ScheduleVoice(1, "keepmove")
		else
			warnSoulEchoes:Show(targetname)
		end
	end
end

function mod:OnCombatStart(delay)
	self.vb.scytheCount = 0
	self.vb.echoesCount = 0
	self.vb.reapCount = 0
	self.vb.burstCount = 0
	self:SetStage(1)
	timerSwirlingScytheCD:Start(8-delay, 1)
	timerSoulEchoesCD:Start(15.5-delay, 1)
	timerReapSoulCD:Start(20-delay, 1)
end

function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 195254 then
		self.vb.scytheCount = self.vb.scytheCount + 1
		timerSwirlingScytheCD:Start(nil, self.vb.scytheCount+1)
		self:BossTargetScanner(args.sourceGUID, "ScytheTarget", 0.05, 12, true)--Can target tank if no one else is left, but if this causes probelm add tank filter back
	elseif spellId == 194966 then
		self.vb.echoesCount = self.vb.echoesCount + 1
		timerSoulEchoesCD:Start(nil, self.vb.echoesCount+1)
		self:BossTargetScanner(args.sourceGUID, "SoulTarget", 0.1, 20, true, nil, nil, nil, true)--Always filter tank, because if scan fails debuff will be used.
	elseif spellId == 194956 then
		self.vb.reapCount = self.vb.reapCount + 1
		specWarnReapSoul:Show(self.vb.reapCount)
		specWarnReapSoul:Play("shockwave")
		timerReapSoulCD:Start(nil, self.vb.reapCount+1)
	elseif spellId == 196078 then
		self:SetStage(2)
		warnCallSouls:Show()
		timerReapSoulCD:Stop()
		timerSwirlingScytheCD:Stop()
		timerSoulEchoesCD:Stop()
	elseif spellId == 196587 then
		self.vb.burstCount = self.vb.burstCount + 1
		specWarnSoulBurst:Show(self.vb.burstCount)
		specWarnSoulBurst:Play("aesoon")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 196587 then
		self:SetStage(1)
		--Reset Count?
		--self.vb.scytheCount = 0
		--self.vb.echoesCount = 0
		--self.vb.reapCount = 0
		timerSwirlingScytheCD:Start(9.2, self.vb.scytheCount+1)
		timerSoulEchoesCD:Start(16.5, self.vb.echoesCount+1)
		timerReapSoulCD:Start(21.3, self.vb.reapCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 194966 and self:AntiSpam(3, args.destName) then--Backup Soul echos warning that's 2 seconds slower than target scan
		if args:IsPlayer() then
			specWarnSoulEchos:Show()
			specWarnSoulEchos:Play("runaway")
			specWarnSoulEchos:ScheduleVoice(1, "keepmove")
		else
			warnSoulEchoes:Show(args.destName)
		end
	elseif spellId == 196930 then
		warnSoulgorge:Show(args.destName, args.amount or 1)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
