local mod	= DBM:NewMod("z2951", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,mythic"

mod:SetRevision("@file-date-integer@")
--mod:SetCreatureID(225204)--Non hard one placeholder on load. Real one set in OnCombatStart
--mod:SetEncounterID(2987, 2985)
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2951)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_START",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED"
)

--local warnDrones						= mod:NewSpellAnnounce(449072, 2)

--local specWarnVoidRend				= mod:NewSpecialWarningDodge(447187, nil, nil, nil, 2, 2)
--local specWarnEncasingWebshot			= mod:NewSpecialWarningInterrupt(447143, nil, nil, nil, 1, 2)

--local timerVoidRendCD					= mod:NewCDTimer(27.9, 447187, nil, nil, nil, 3)
--local timerEncasingWebshotCD			= mod:NewCDTimer(31.1, 447143, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

--[[
function mod:SPELL_CAST_START(args)
	if args.spellId == 447187 then

	end
end
--]]

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 447143 then

	end
end
--]]

--[[
function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 1098 then

	end
end
--]]

--[[
function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 1098 then

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
	if cid == 208242 then
	end
end
--]]
