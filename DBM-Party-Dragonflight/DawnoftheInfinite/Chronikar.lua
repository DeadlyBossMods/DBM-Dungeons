local mod	= DBM:NewMod(2521, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198995)
mod:SetEncounterID(2666)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20230711000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 413105 413013 401421",
	"SPELL_AURA_APPLIED 407147",
--	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED 413013"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 413105 or ability.id = 413013 or ability.id = 401421) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
local warnEonShatter						= mod:NewCountAnnounce(413105, 3)--Second and Third Jump
local warnChronoShear						= mod:NewFadesAnnounce(413013, 1, nil, "Healer|Tank")

local specWarnEonShatter					= mod:NewSpecialWarningDodgeCount(413105, nil, nil, nil, 2, 2)
local specWarnChronoShear					= mod:NewSpecialWarningDefensive(413013, nil, nil, nil, 1, 2)
local specWarnSandStomp						= mod:NewSpecialWarningMoveAwayCount(401421, nil, nil, nil, 2, 2)
--local yellManaBomb								= mod:NewYell(386181)
--local yellManaBombFades							= mod:NewShortFadesYell(386181)
local specWarnGTFO							= mod:NewSpecialWarningGTFO(407147, nil, nil, nil, 1, 8)

local timerEonShatterCD						= mod:NewCDTimer(19.4, 413105, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerEonResidue						= mod:NewCastCountTimer("d7.5", 401421, DBM_COMMON_L.SoakC, nil, nil, 5, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerChronoShearCD					= mod:NewCDCountTimer(19.4, 413013, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSandStompCD						= mod:NewCDCountTimer(19.4, 401421, nil, nil, nil, 3)


--mod:AddInfoFrameOption(391977, true)

mod.vb.shatterCount = 0
mod.vb.shearCount = 0
mod.vb.stompCount = 0

function mod:OnCombatStart(delay)
	self.vb.shatterCount = 0
	self.vb.shearCount = 0
	self.vb.stompCount = 0
	timerSandStompCD:Start(7.4-delay, 1)
	timerEonShatterCD:Start(19.5-delay)
	timerChronoShearCD:Start(48.2, 1)
end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 413105 then
		self.vb.shatterCount = self.vb.shatterCount + 1
		if self.vb.shatterCount == 1 then
			specWarnEonShatter:Show(self.vb.shatterCount)
			specWarnEonShatter:Play("watchstep")
			if self:IsMythic() then
				timerEonResidue:Start(nil, self.vb.shatterCount)
			end
--			timerEonShatterCD:Start(5)
		else--Cast 2 and 3
			warnEonShatter:Show(self.vb.shatterCount)
			if self.vb.shatterCount == 3 then
				self.vb.shatterCount = 1
				timerEonShatterCD:Start(41.7)--41.7
--			else
--				timerEonShatterCD:Start(5)
			end
		end
	elseif spellId == 413013 then
		self.vb.shearCount = self.vb.shearCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnChronoShear:Show()
			specWarnChronoShear:Play("defensive")
		end
		timerChronoShearCD:Start(52.9, self.vb.shearCount+1)
	elseif spellId == 401421 then
		self.vb.stompCount = self.vb.stompCount + 1
		specWarnSandStomp:Show(self.vb.stompCount)
		specWarnSandStomp:Play("scatter")
		if self.vb.stompCount % 2 == 0 then
			timerSandStompCD:Start(17, self.vb.stompCount+1)
		else--Eon Shatter causes delay
			timerSandStompCD:Start(34.8, self.vb.stompCount+1)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 407147 and args:IsPlayer() and self:AntiSpam(2, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 413013 then
		warnChronoShear:Show()
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 386201 and destGUID == UnitGUID("player") and self:AntiSpam(2, 4) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 353193 then

	end
end
--]]
