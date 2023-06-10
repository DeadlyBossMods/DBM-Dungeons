if DBM:GetTOC() < 100105 then return end
local mod	= DBM:NewMod(2535, "DBM-Party-Dragonflight", 9, 1209)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(194181)
mod:SetEncounterID(2668)
--mod:SetUsedIcons(1, 2, 3)
--mod:SetHotfixNoticeRev(20221015000000)
--mod:SetMinSyncRevision(20221015000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[

--]]
--local warnArcaneOrbs							= mod:NewCountAnnounce(385974, 3)

--local specWarnManaBomb							= mod:NewSpecialWarningMoveAway(386181, nil, nil, nil, 1, 2)
--local yellManaBomb								= mod:NewYell(386181)
--local yellManaBombFades							= mod:NewShortFadesYell(386181)
--local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

--local timerManaBombsCD							= mod:NewAITimer(19.4, 386173, nil, nil, nil, 3)
--local timerArcaneExpulsionCD					= mod:NewAITimer(19.4, 385958, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

--mod:AddInfoFrameOption(391977, true)

--function mod:OnCombatStart(delay)

--end

--function mod:OnCombatEnd()
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
--	if self.Options.InfoFrame then
--		DBM.InfoFrame:Hide()
--	end
--end

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 388537 then

	end
end
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 387691 then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 386181 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 386181 then

	end
end
--]]

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
