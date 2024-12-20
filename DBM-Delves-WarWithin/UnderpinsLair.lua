local mod	= DBM:NewMod("z2831", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"--Best way to really call it

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(225204)--Non hard one placeholder on load. Real one set in OnCombatStart
mod:SetEncounterID(3126, 3138)
--mod:SetHotfixNoticeRev(20240914000000)
--mod:SetMinSyncRevision(20240914000000)
mod:SetZone(2831)

--mod:RegisterCombat("scenario", 2682)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED"
)

--local warnEnfeeblingSpittle					= mod:NewCountAnnounce(450505, 2)

--local specWarnCallWebTerror					= mod:NewSpecialWarningCount(450568, nil, nil, nil, 1, 2)

--local timerAnglersWebCD						= mod:NewAITimer(21.8, 450519, nil, nil, nil, 5)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
function mod:OnCombatStart(delay)
	if self:IsMythic() then
		--self:SetStage(1)
		--self:SetCreatureID(221427)
	else
		--self:SetCreatureID(225204)
	end
end
--]]

--[[
function mod:SPELL_CAST_START(args)
	if args.spellId == 450519 then

	end
end
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 138680 then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 450505 then
	end
end
--]]

--[[
function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 451003 then

	end
end
--]]

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 138561 and destGUID == UnitGUID("player") and self:AntiSpam() then

	end
end
--]]

--[[
function mod:UNIT_DIED(args)
	--if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe

	--end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 224077 then--Egg Cocoon

	end
end
--]]
