local mod	= DBM:NewMod(2521, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198995)
mod:SetEncounterID(2666)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20231102000000)
mod:SetMinSyncRevision(20231102000000)
mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 413105 413013 401421",
	"SPELL_AURA_APPLIED 413142",
	"SPELL_AURA_REMOVED 413013 413142"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--[[
(ability.id = 413105 or ability.id = 413013 or ability.id = 401421) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 413142 and type = "applydebuff"
--]]
local warnEonShatter						= mod:NewCountAnnounce(413142, 3, nil, nil, 47482)--Second and Third Jump
local warnChronoShear						= mod:NewFadesAnnounce(413013, 1, nil, "Healer|Tank")

local specWarnEonShatter					= mod:NewSpecialWarningDodgeCount(413142, nil, 47482, nil, 2, 2)--Warn on initial casts
local yellEonShatter						= mod:NewYell(413142, 47482)
local yellEonShatterFades					= mod:NewShortFadesYell(413142)
local specWarnChronoShear					= mod:NewSpecialWarningDefensive(413013, nil, nil, nil, 1, 2)
local specWarnSandStomp						= mod:NewSpecialWarningMoveAwayCount(401421, nil, nil, nil, 2, 2)
--local specWarnGTFO							= mod:NewSpecialWarningGTFO(407147, nil, nil, nil, 1, 8)

local timerEonShatterCD						= mod:NewCDTimer(19.4, 413142, 47482, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--"Leap" shorttext
local timerEonResidue						= mod:NewCastCountTimer("d7.5", 403486, DBM_COMMON_L.GROUPSOAKS.." (%s)", nil, nil, 5, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerChronoShearCD					= mod:NewCDCountTimer(47, 413013, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSandStompCD						= mod:NewCDCountTimer(19.4, 401421, DBM_COMMON_L.POOLS.." (%s)", nil, nil, 3)

mod.vb.shatterCount = 0
mod.vb.shatterSet = 0
mod.vb.shearCount = 0
mod.vb.stompCount = 0

function mod:OnCombatStart(delay)
	self.vb.shatterCount = 0
	self.vb.shatterSet = 0
	self.vb.shearCount = 0
	self.vb.stompCount = 0
	timerSandStompCD:Start(7.4-delay, 1)
	timerEonShatterCD:Start(19.5-delay)
	timerChronoShearCD:Start(43.8, 1)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 413105 then
		if self:AntiSpam(15, 1) then
			self.vb.shatterSet = self.vb.shatterSet + 1
			self.vb.shatterCount = 0
			timerEonShatterCD:Start(47, self.vb.shatterSet+1)
		end
		self.vb.shatterCount = self.vb.shatterCount + 1
		if self:IsMythic() then
			timerEonResidue:Start(nil, self.vb.shatterCount)
		end
		if self.vb.shatterCount == 1 then
			specWarnEonShatter:Show(self.vb.shatterSet.." - "..self.vb.shatterCount)
			specWarnEonShatter:Play("watchstep")
		else--Cast 2
			warnEonShatter:Show(self.vb.shatterSet.." - "..self.vb.shatterCount)
			--if self.vb.shatterCount == 2 then
			--	timerEonShatterCD:Start(42)
			--end
		end
	elseif spellId == 413013 then
		self.vb.shearCount = self.vb.shearCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnChronoShear:Show()
			specWarnChronoShear:Play("defensive")
		end
		timerChronoShearCD:Start(47, self.vb.shearCount+1)
	elseif spellId == 401421 then
		self.vb.stompCount = self.vb.stompCount + 1
		specWarnSandStomp:Show(self.vb.stompCount)
		specWarnSandStomp:Play("scatter")
		if self.vb.stompCount % 2 == 0 then
			timerSandStompCD:Start(17, self.vb.stompCount+1)--17-18.6
		else--Eon Shatter causes delay
			timerSandStompCD:Start(29, self.vb.stompCount+1)--29-31.1
		end
	end
end


function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 413142 then
		if args:IsPlayer() then
			yellEonShatter:Yell()
			yellEonShatterFades:Countdown(spellId)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 413013 then
		warnChronoShear:Show()
	elseif spellId == 413142 then
		if args:IsPlayer() then
			yellEonShatterFades:Cancel()
		end
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
