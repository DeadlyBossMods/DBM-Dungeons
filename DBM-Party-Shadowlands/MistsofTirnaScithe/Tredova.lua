local mod	= DBM:NewMod(2405, "DBM-Party-Shadowlands", 3, 1184)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(164517)
mod:SetEncounterID(2393)
mod:SetHotfixNoticeRev(20240808000000)
mod:SetUsedIcons(1, 2, 3, 4, 5)--Probably doesn't use all 5, unsure number of mind link targets at max inteligence/energy

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 322550 322614 337235 337249 337255 463602",
	"SPELL_CAST_SUCCESS 322614 322654",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED 322527 331172 322648 322563",
	"SPELL_AURA_REMOVED 322450 322527 331172 322648",
	"SPELL_PERIODIC_DAMAGE 326309",
	"SPELL_PERIODIC_MISSED 326309"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--Timers can't be fixed until numerous transcriptor logs, without boss energy can't start mark prey timer up mid fight or update CD on other abilities cast more often at higher energy
--[[
(ability.id = 463602 or ability.id = 322550) and type = "begincast"
 or (ability.id = 322614 or ability.id = 322654 or ability.id = 322563) and type = "cast"
 or (ability.id = 322527 or ability.id = 322450) and (type = "applybuff" or type = "removebuff" or type = "applydebuff" or type = "removedebuff")
 or (ability.id = 337235 or ability.id = 337249 or ability.id = 337255) and type = "begincast"
 or blockedAbility.id = 322450
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnMarkedPrey				= mod:NewTargetNoFilterAnnounce(322563, 3)
--local warnInfestor					= mod:NewAnnounce("warnInfestor", 4, 337235, nil, nil, nil, 337235)

local specWarnConsumption			= mod:NewSpecialWarningDodge(322450, nil, nil, nil, 2, 2)
local specWarnConsumptionKick		= mod:NewSpecialWarningInterrupt(322450, "HasInterrupt", nil, 2, 1, 2)
local specWarnAcceleratedIncubation	= mod:NewSpecialWarningSwitchCount(322550, "Dps", nil, nil, 1, 2)
local specWarnMindLink				= mod:NewSpecialWarningMoveAway(322648, nil, nil, nil, 1, 11)
local yellMindLink					= mod:NewYell(322648)
local specWarnMarkedPrey			= mod:NewSpecialWarningYou(322563, nil, nil, nil, 1, 2)
local specWarnAcidExpulsion			= mod:NewSpecialWarningDodgeCount(322654, nil, nil, nil, 2, 2)
local specWarnCoalescingPoison		= mod:NewSpecialWarningRunCount(463602, nil, nil, nil, 4, 12, 4)
--local specWarnParasiticInfesterKick	= mod:NewSpecialWarning("specWarnParasiticInfesterKick", nil, nil, nil, 1, 2, 4, 337235, 337235)
--ocal yellParasiticInfester			= mod:NewYell(337235, L.Infester, true, "yellParasiticInfester")
local specWarnGTFO					= mod:NewSpecialWarningGTFO(326309, nil, nil, nil, 1, 8)

--All timers are now 35 and all reset to pull timers on shield interrupt
local timerAcceleratedIncubationCD	= mod:NewCDCountTimer(35, 322550, nil, nil, nil, 1)
local timerMindLinkCD				= mod:NewCDCountTimer(35, 322648, nil, nil, nil, 3)
local timerAcidExpulsionCD			= mod:NewCDCountTimer(35, 322654, nil, nil, nil, 3)
local timerCoalescingPoisonCD		= mod:NewCDCountTimer(35, 463602, nil, nil, nil, 1)
local timerMarkedPreyCD				= mod:NewCDCountTimer(35, 322563, nil, nil, nil, 3)
--local timerParasiticInfesterCD		= mod:NewTimer(23, "timerParasiticInfesterCD", 337235, nil, nil, 4, DBM_COMMON_L.MYTHIC_ICON..DBM_COMMON_L.INTERRUPT_ICON, true)--23-26.3 (mostly 25-26)

mod:AddInfoFrameOption(322527, true)
mod:AddSetIconOption("SetIconOnMindLink", 322648, true, 0, {1, 2, 3, 4, 5})

mod.vb.mindLinkIcon = 1
mod.vb.inubationCount = 0
mod.vb.mindlinkCount = 0
mod.vb.expulsionCount = 0
mod.vb.poisonCount = 0
--mod.vb.parasiteCount = 0

--[[
function mod:InfesterTarget(targetname, uId)
	if not targetname then return end
	warnInfestor:Show(targetname)
	if targetname == UnitName("player") then
		yellParasiticInfester:Yell()
	end
end
--]]

--Sometimes boss skips first accelerated incubation after shield interrupt
--So we have to detect this and restart timer for 2nd cast
local function FixBlizzardBug(self)
	self.vb.inubationCount = self.vb.inubationCount + 1
	--"Accelerated Incubation-322550-npc:164517-00006F8E89 = pull:11.0, 40.3, 52.6, 35.0",
	timerAcceleratedIncubationCD:Start(30, self.vb.inubationCount+1)
end

function mod:OnCombatStart(delay)
	self.vb.mindLinkIcon = 1
	self.vb.inubationCount = 0
	self.vb.mindlinkCount = 0
	self.vb.expulsionCount = 0
	self.vb.poisonCount = 0
	--self.vb.parasiteCount = 0
	timerAcidExpulsionCD:Start(6.9-delay, 1)
	timerAcceleratedIncubationCD:Start(10.9-delay, 1)
	timerMindLinkCD:Start(24.9-delay, 1)
	if self:IsMythic() then
		timerCoalescingPoisonCD:Start(26-delay, 1)
	end
	--if self:IsMythic() then
	--	timerParasiticInfesterCD:Start(11.7-delay, 1)
	--end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 322550 then
		self:Unschedule(FixBlizzardBug)
		self.vb.inubationCount = self.vb.inubationCount + 1
		specWarnAcceleratedIncubation:Show(self.vb.inubationCount)
		specWarnAcceleratedIncubation:Play("killmob")
		timerAcceleratedIncubationCD:Start(nil, self.vb.inubationCount+1)
	elseif spellId == 322614 then
		self.vb.mindLinkIcon = 2
	elseif spellId == 463602 then
		self.vb.poisonCount = self.vb.poisonCount + 1
		specWarnCoalescingPoison:Show(self.vb.poisonCount)
		specWarnCoalescingPoison:Play("pullin")
		specWarnCoalescingPoison:ScheduleVoice(2, "justrun")
		timerCoalescingPoisonCD:Start(nil, self.vb.poisonCount+1)
	--elseif spellId == 337235 or spellId == 337249 or spellId == 337255 then
	--	self.vb.parasiteCount = self.vb.parasiteCount + 1
	--	self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "InfesterTarget", 0.1, 8)
	--	timerParasiticInfesterCD:Start(nil, self.vb.parasiteCount)
	--	if self:CheckInterruptFilter(args.sourceGUID, false, true) then
	--		specWarnParasiticInfesterKick:Show(args.sourceName, self.vb.parasiteCount)
	--		specWarnParasiticInfesterKick:Play("kickcast")
	--	end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 322614 then
		self.vb.mindLinkIcon = 2
		self.vb.mindlinkCount = self.vb.mindlinkCount + 1
		timerMindLinkCD:Start(nil, self.vb.mindlinkCount+1)
	elseif spellId == 322654 and self:AntiSpam(3, 1) then
		self.vb.expulsionCount = self.vb.expulsionCount + 1
		specWarnAcidExpulsion:Show(self.vb.expulsionCount)
		specWarnAcidExpulsion:Play("watchstep")
		timerAcidExpulsionCD:Start(nil, self.vb.expulsionCount+1)
	end
end

function mod:SPELL_INTERRUPT(args)
	if type(args.extraSpellId) == "number" and (args.extraSpellId == 337235 or args.extraSpellId == 337249 or args.extraSpellId == 337255) then
		self:UnscheduleMethod("BossTargetScanner")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 322527 then--Gorging Shield (Consumption starting)
		self:Unschedule(FixBlizzardBug)
		timerMindLinkCD:Stop()
		timerAcidExpulsionCD:Stop()
		timerMarkedPreyCD:Stop()
		timerAcceleratedIncubationCD:Stop()
		timerCoalescingPoisonCD:Stop()
		if self:AntiSpam(3, 1) then
			specWarnConsumption:Show()
			specWarnConsumption:Play("watchstep")
		end
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	elseif spellId == 331172 or spellId == 322648 then
		if self.Options.SetIconOnMindLink then
			--Always set Star on parent link
			self:SetIcon(args.destName, spellId == 322648 and 1 or self.vb.mindLinkIcon)
		end
		if args:IsPlayer() then
			specWarnMindLink:Show()
			specWarnMindLink:Play("lineapart")
			yellMindLink:Yell()
		end
		if spellId == 331172 then
			self.vb.mindLinkIcon = self.vb.mindLinkIcon + 1
			--if self.vb.mindLinkIcon == 6 then
			--	self.vb.mindLinkIcon = 2
			--end
		end
	elseif spellId == 322563 then
		if args:IsPlayer() then
			specWarnMarkedPrey:Show()
			specWarnMarkedPrey:Play("targetyou")
		else
			warnMarkedPrey:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 322450 then--Consumption ended
		--TODO, maybe update timers that are all spell queued at this point, which will
		timerAcidExpulsionCD:Start(6.9, self.vb.expulsionCount+1)
		timerAcceleratedIncubationCD:Start(10.9, self.vb.inubationCount+1)
		self:Unschedule(FixBlizzardBug)
		self:Schedule(15.9, FixBlizzardBug, self)
		timerMarkedPreyCD:Start(14.5, self.vb.mindlinkCount+1)
		timerMindLinkCD:Start(24.9, self.vb.mindlinkCount+1)
		if self:IsMythic() then
			timerCoalescingPoisonCD:Start(26, self.vb.poisonCount+1)
		end
	elseif spellId == 322527 then--Gorging Shield
		specWarnConsumptionKick:Show(args.destName)
		specWarnConsumptionKick:Play("kickcast")
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 326309 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
