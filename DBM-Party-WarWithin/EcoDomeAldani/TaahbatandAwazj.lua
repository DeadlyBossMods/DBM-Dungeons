local mod	= DBM:NewMod(2676, "DBM-Party-WarWithin", 10, 1303)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(207207)
mod:SetEncounterID(3108)
--mod:SetHotfixNoticeRev(20250303000000)
--mod:SetMinSyncRevision(20250303000000)
mod:SetZone(2830)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[

 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--local warnVoidShell						= mod:NewTargetNoFilterAnnounce(445262, 3)

--local specWarnNullUpheaval				= mod:NewSpecialWarningDodgeCount(423305, nil, nil, nil, 1, 2)
--local yellSomeAbility					= mod:NewYell(372107)

--local timerNullUpheavalCD				= mod:NewAITimer(30, 423305, nil, nil, nil, 3)

--mod:AddInfoFrameOption(445262)
--mod:AddNamePlateOption("NameplateOnReshape", 428269)

function mod:OnCombatStart(delay)

end

--function mod:OnCombatEnd()

--end

--[[
function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 423305 then

	end
end
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 458082 then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 445262 then

	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
--]]

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 445262 then

	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 433067 and destGUID == UnitGUID("player") and self:AntiSpam(3, 3) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
