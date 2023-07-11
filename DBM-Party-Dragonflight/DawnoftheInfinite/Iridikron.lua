local mod	= DBM:NewMod(2537, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(198933)
mod:SetEncounterID(2669)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20230706000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 409261 414535 409456 409635 414184",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 409266 414376",
	"SPELL_AURA_REMOVED 409456"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
)

--[[
(ability.id = 409261 or ability.id = 414535 or ability.id = 409456 or ability.id = 409635 or ability.id = 414184) and type = "begincast"
 or ability.id = 409456 and type = "removebuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--NOTES: Crushing Onslaught seems utterly passive and not much point in warning for it really
local warnExtinctionBlast						= mod:NewTargetNoFilterAnnounce(409261, 4)
local warnEarthsurge							= mod:NewCountAnnounce(409456, 3)
local warnEarthsurgeOver						= mod:NewEndAnnounce(409456, 1)
local warnCataclysmicObliteration				= mod:NewCastAnnounce(414184, 4)

local specWarnExtinctionBlast					= mod:NewSpecialWarningMoveTo(409261, nil, nil, nil, 2, 2)--Warn everyone
local yellExtinctionBlast						= mod:NewYell(409261)--But have target of it do yell
local specWarnStonecrackerBarrage				= mod:NewSpecialWarningSoakCount(414535, nil, nil, nil, 2, 2)
local specWarnPulvBreath						= mod:NewSpecialWarningDodgeCount(409635, nil, nil, nil, 2, 2)
local specWarnGTFO								= mod:NewSpecialWarningGTFO(414376, nil, nil, nil, 1, 8)

local timerExtinctionBlastCD					= mod:NewCDCountTimer(19.4, 409261, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerStonecrackerBarrageCD				= mod:NewCDCountTimer(19.4, 414535, nil, nil, nil, 5, nil, DBM_COMMON_L.IMPORTANT_ICON)
local timerEarthSurgeCD							= mod:NewCDCountTimer(19.4, 409456, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON..DBM_COMMON_L.HEALER_ICON)
local timerPulverizingExhalationCD				= mod:NewCDCountTimer(19.4, 409635, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerCataclysmicObliteration				= mod:NewCastTimer(30, 414184, nil, nil, nil, 2)

--mod:AddInfoFrameOption(391977, true)

mod.vb.surgeCount = 0

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self.vb.surgeCount = 0
	timerExtinctionBlastCD:Start(8.5, 1)
	timerStonecrackerBarrageCD:Start(16.3, 1)
	timerEarthSurgeCD:Start(35.2, 1)
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
	if spellId == 409261 then
	elseif spellId == 414535 then
		specWarnStonecrackerBarrage:Show(self.vb.surgeCount+1)
		specWarnStonecrackerBarrage:Play("helpsoak")
	elseif spellId == 409456 then
		self.vb.surgeCount = self.vb.surgeCount + 1
		warnEarthsurge:Show(self.vb.surgeCount)
	elseif spellId == 409635 then
		specWarnPulvBreath:Show(self.vb.surgeCount)
		specWarnPulvBreath:Play("breathsoon")
		if self:IsMythic() then
			specWarnPulvBreath:ScheduleVoice(2, "scatter")
		end
	elseif spellId == 414184 then
		self:SetStage(2)
		timerExtinctionBlastCD:Stop()
		timerStonecrackerBarrageCD:Stop()
		timerEarthSurgeCD:Stop()
		timerPulverizingExhalationCD:Stop()
		warnCataclysmicObliteration:Show()
		timerCataclysmicObliteration:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 387691 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 409266 then
		if args:IsPlayer() then
			specWarnExtinctionBlast:Show(DBM_COMMON_L.SHIELD)
			specWarnExtinctionBlast:Play("findshelter")
			yellExtinctionBlast:Yell()
		else
			warnExtinctionBlast:Show(args.destName)
		end
	elseif spellId == 414376 and args:IsPlayer() and self:AntiSpam(3, 1) then
		specWarnGTFO:Show(args.spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 409456 then--Earthsurge
		warnEarthsurgeOver:Show()
		timerPulverizingExhalationCD:Start(9.2, self.vb.surgeCount)
		timerExtinctionBlastCD:Start(31, self.vb.surgeCount+1)
		timerStonecrackerBarrageCD:Start(39, self.vb.surgeCount+1)
		timerEarthSurgeCD:Start(58.9, self.vb.surgeCount+1)
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
