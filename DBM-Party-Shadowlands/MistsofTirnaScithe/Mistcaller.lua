local mod	= DBM:NewMod(2402, "DBM-Party-Shadowlands", 3, 1184)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(164501)
mod:SetEncounterID(2392)
mod:SetHotfixNoticeRev(20240808000000)
mod:SetUsedIcons(1, 2, 3, 4)
mod:SetZone(2290)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 336499 321471 321834 321873 321828 321669 341709",
	"SPELL_SUMMON 321873",
	"SPELL_AURA_APPLIED 321891 321828",
	"SPELL_AURA_REMOVED 321891 336499 321471",
	"SPELL_INTERRUPT",
	"UNIT_DIED"
--	"SPELL_CAST_SUCCESS",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE: Timers get delayed by guessing game (which is health based phasing) by 3 seconds.
--[[
(ability.id = 321834 or ability.id = 321873 or ability.id = 321828 or ability.id = 341709) and type = "begincast"
 or ability.id = 336499
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 321669 and type = "begincast"
--]]
local warnGuessingGame				= mod:NewCastAnnounce(336499, 4)
local warnGuessingGameOver			= mod:NewEndAnnounce(321873, 1)
local warnFreezeTag					= mod:NewCountAnnounce(321873, 3)
local warnFixate					= mod:NewTargetNoFilterAnnounce(321891, 2)
local warnPattyCake					= mod:NewTargetNoFilterAnnounce(321828, 3)

local specWarnDodgeBall				= mod:NewSpecialWarningDodgeCount(321834, nil, nil, nil, 2, 2)
local specWarnFixate				= mod:NewSpecialWarningRun(321891, nil, nil, nil, 4, 2)
local specWarnPattyCake				= mod:NewSpecialWarningInterrupt(321828, nil, nil, nil, 3, 2)
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

local timerDodgeBallCD				= mod:NewVarCountTimer("v12.1-18", 321834, nil, nil, nil, 3)--12.1-18
local timerFreezeTagCD				= mod:NewVarCountTimer("v21.8-25", 321873, nil, nil, nil, 3)--21.8-25
local timerPattyCakeCD				= mod:NewVarCountTimer("v19.4-26", 321828, nil, nil, nil, 4, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.INTERRUPT_ICON)--20-26
local timerPattyCake				= mod:NewCastTimer(2.5, 321828, nil, nil, nil, 5, nil, DBM_COMMON_L.DEADLY_ICON..DBM_COMMON_L.INTERRUPT_ICON)

mod:AddNamePlateOption("NPAuraOnFixate", 321891)--Sets NP icon if you're target of fixate
mod:AddNamePlateOption("NPAuraOnFreezeTag2", 321873)--Sets NP on it at all times
mod:AddSetIconOption("SetIconOnAdds2", -21691, true, 5, {1, 2, 3, 4})
--mod:GroupSpells(321873, 321891)--Freeze Tag and associated fixate

local seenAdds = {}
mod.vb.addIcon = 1
mod.vb.dodgeballCount = 0
mod.vb.tagCount = 0
mod.vb.pattyCount = 0

function mod:OnCombatStart(delay)
	table.wipe(seenAdds)
	self.vb.addIcon = 1
	self.vb.dodgeballCount = 0
	self.vb.tagCount = 0
	self.vb.pattyCount = 0
	timerDodgeBallCD:Start(6-delay, 1)
	timerPattyCakeCD:Start(12.2-delay, 1)--12.2-14.3
	timerFreezeTagCD:Start(15.9-delay, 1)--15.9-18.5, Sometimes cast is skipped?
	if self.Options.NPAuraOnFixate or self.Options.NPAuraOnFreezeTag2 then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	table.wipe(seenAdds)
	if self.Options.NPAuraOnFreezeTag2 or self.Options.NPAuraOnFreezeTag2 then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 336499 or spellId == 321471 then
		self.vb.addIcon = 1
		warnGuessingGame:Show()
	elseif spellId == 321834 and self:AntiSpam(8, 1) then
		self.vb.dodgeballCount = self.vb.dodgeballCount + 1
		specWarnDodgeBall:Show(self.vb.dodgeballCount)
		specWarnDodgeBall:Play("farfromline")
		--timerDodgeBallCD:Start()--Outside of first case, rest are too chaotic
	elseif spellId == 321873 or spellId == 341709 then
		self.vb.tagCount = self.vb.tagCount + 1
		warnFreezeTag:Show(self.vb.tagCount)
		timerFreezeTagCD:Start(nil, self.vb.tagCount+1)
	elseif spellId == 321828 then
		self.vb.pattyCount = self.vb.pattyCount + 1
		if self:IsTanking("player", "boss1", nil, true, nil, true) then
			--Only target of spell can interrupt it
			specWarnPattyCake:Show(args.sourceName)
			specWarnPattyCake:Play("kickcast")
		end
		timerPattyCake:Start(2.5)
		timerPattyCakeCD:Start(nil, self.vb.pattyCount+1)
	elseif spellId == 321669 then
		if not seenAdds[args.sourceGUID] then
			seenAdds[args.sourceGUID] = true
			if self.Options.SetIconOnAdds2 then--Only use up to 5 icons
				self:ScanForMobs(args.sourceGUID, 2, self.vb.addIcon, 1, nil, 12)
			end
			self.vb.addIcon = self.vb.addIcon + 1
		end
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 321873 then
		if self.Options.NPAuraOnFreezeTag2 then
			DBM.Nameplate:Show(true, args.destGUID, spellId, 5333906)
		end
	end
end

function mod:SPELL_INTERRUPT(args)
	if not self.Options.Enabled then return end
	if type(args.extraSpellId) ~= "number" then return end
	if args.extraSpellId == 321828 then
		timerPattyCake:Stop()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 321891 then
		if args:IsPlayer() then
			specWarnFixate:Show()
			specWarnFixate:Play("runout")
			if self.Options.NPAuraOnFixate then
				DBM.Nameplate:Show(true, args.sourceGUID, spellId, nil, 6)
			end
		else
			warnFixate:Show(args.destName)
		end
	elseif spellId == 321828 then
		warnPattyCake:Show(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 321891 then
		if args:IsPlayer() then
			if self.Options.NPAuraOnFixate then
				DBM.Nameplate:Hide(true, args.sourceGUID, spellId)
			end
		end
	elseif spellId == 336499 or spellId == 321471 then
		warnGuessingGameOver:Show()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 165251 then--Illusionary Vulpin
		if self.Options.NPAuraOnFreezeTag2 then
			DBM.Nameplate:Hide(true, args.destGUID, 321873, 5333906)
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
