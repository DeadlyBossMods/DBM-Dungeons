local mod	= DBM:NewMod(2487, "DBM-Party-Dragonflight", 2, 1197)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(184018)
mod:SetEncounterID(2556)
mod:SetUsedIcons(8)
mod:SetHotfixNoticeRev(20230508000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 369675 369754 369703 382303",
	"SPELL_CAST_SUCCESS 369605 369703",
	"SPELL_AURA_APPLIED 369725",
	"UNIT_DIED"
)

--TODO, warn trogg Ambush casts?
--TODO, target scan thundering slam to notify direction of attack?
--TODO, rangecheck for chain lighting? it doesn't tell what range of "nearby enemy" means
--TODO, Mythic timer and heroic timers may actually differ but it's hard to review heroic timers when logs can't be searched
--TODO, https://www.wowhead.com/beta/spell=369674/stone-spike added in newer build but seems like low prio interrupt over Chain Lightning
--[[
(ability.id = 369754 or ability.id = 369703 or ability.id = 382303) and type = "begincast"
 or ability.id = 369605 and type = "cast"
 or ability.id = 369725
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 369675 and type = "begincast"
--]]
local warnCalloftheDeep							= mod:NewCountAnnounce(369605, 3)
local warnBloodlust								= mod:NewSpellAnnounce(369754, 3)

local specWarnQuakingTotem						= mod:NewSpecialWarningSwitchCount(369700, "-Healer", nil, nil, 1, 2)
local specWarnChainLightning					= mod:NewSpecialWarningInterrupt(369675, "HasInterrupt", nil, nil, 1, 2)
local specWarnThunderingSlam					= mod:NewSpecialWarningDodgeCount(369703, nil, nil, nil, 2, 2)

local timerCalloftheDeepCD						= mod:NewCDCountTimer(27.4, 369605, nil, nil, nil, 1)--28-30
local timerQuakingTotemCD						= mod:NewCDCountTimer(30, 369700, nil, nil, nil, 5)
local timerBloodlustCD							= mod:NewCDTimer(30, 369754, nil, nil, nil, 5)
local timerThunderingSlamCD						= mod:NewCDCountTimer(18.2, 369703, nil, nil, nil, 3)--18-23
local timerChainLightningCD						= mod:NewCDNPTimer(23, 369675, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--23-25

mod.vb.callCount = 0
mod.vb.thunderingCount = 0
mod.vb.totemCount = 0

function mod:OnCombatStart(delay)
	self.vb.callCount = 0
	self.vb.thunderingCount = 1
	self.vb.totemCount = 0
	timerCalloftheDeepCD:Start(5-delay, 1)
	timerThunderingSlamCD:Start(12.1-delay, 1)
	timerQuakingTotemCD:Start(20.4-delay, 1)
	timerBloodlustCD:Start(27-delay)
	--Trash is often pulled with this boss, so we want to enable trash mod functionality during fight
	local trashMod = DBM:GetModByName("UldamanLegacyofTyrTrash")
	if trashMod then
		trashMod.isTrashModBossFightAllowed = true
	end
end

function mod:OnCombatEnd()
	local trashMod = DBM:GetModByName("UldamanLegacyofTyrTrash")
	if trashMod then
		trashMod.isTrashModBossFightAllowed = false
	end
end


function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 369675 and args:GetSrcCreatureID() == 186658 then--186658 boss version of mob
		timerChainLightningCD:Start(nil, args.sourceGUID)
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnChainLightning:Show(args.sourceName)
			specWarnChainLightning:Play("kickcast")
		end
	elseif spellId == 369754 then
		warnBloodlust:Show()
		timerBloodlustCD:Start()
	elseif spellId == 369703 then
		specWarnThunderingSlam:Show(self.vb.thunderingCount)
		specWarnThunderingSlam:Play("watchstep")
	elseif spellId == 382303 then
		self.vb.totemCount = self.vb.totemCount + 1
		specWarnQuakingTotem:Show(self.vb.totemCount)
		specWarnQuakingTotem:Play("attacktotem")
		timerQuakingTotemCD:Start(nil, self.vb.totemCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 369605 then
		self.vb.callCount = self.vb.callCount + 1
		warnCalloftheDeep:Show(self.vb.callCount)
		timerCalloftheDeepCD:Start(nil, self.vb.callCount+1)
	elseif spellId == 369703 then
		self.vb.thunderingCount = self.vb.thunderingCount + 1
		timerThunderingSlamCD:Start(14.7, self.vb.thunderingCount+1)--18.2 - 3.5
	end
end


function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 369725 then--Tremor
		timerCalloftheDeepCD:AddTime(10, self.vb.callCount+1)
		timerThunderingSlamCD:AddTime(10, self.vb.thunderingCount+1)
		timerQuakingTotemCD:AddTime(10, self.vb.totemCount+1)
		timerBloodlustCD:AddTime(10)
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 186658 then--Stonevault Geomancer (Boss Version)
		timerChainLightningCD:Stop(args.destGUID)
--		timerStoneSpikeCD:Stop(args.destGUID)
	end
end