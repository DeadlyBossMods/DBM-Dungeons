local mod	= DBM:NewMod("z2690", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2690)

mod:RegisterCombat("scenario", 2690)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 447187",
	"SPELL_CAST_SUCCESS 447143",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

--local warnDrones							= mod:NewSpellAnnounce(449072, 2)

local specWarnVoidRend				= mod:NewSpecialWarningDodge(447187, nil, nil, nil, 2, 2)
local specWarnEncasingWebshot		= mod:NewSpecialWarningInterrupt(447143, nil, nil, nil, 1, 2)

local timerVoidRendCD				= mod:NewCDTimer(27.9, 447187, nil, nil, nil, 3)
local timerEncasingWebshotCD		= mod:NewCDTimer(31.1, 447143, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 447187 then
		--"Rend Void-447187-npc:220078-00001E9A9F = pull:7.0, 29.2, 29.2, 29.1, 29.2, 29.2, 29.2, 29.1",
		specWarnVoidRend:Show()
		specWarnVoidRend:Play("watchstep")
		timerVoidRendCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 447143 then
		--"Encasing Webs-447143-npc:220078-00001E9A9F = pull:13.0, 32.9, 35.2, 32.8, 34.0, 31.6, 36.4",
		specWarnEncasingWebshot:Show(args.sourceName)
		specWarnEncasingWebshot:Play("kickcast")
		timerEncasingWebshotCD:Start()
	end
end

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

function mod:ENCOUNTER_START(eID)
	if eID == 2991 then--Researcher Ven'kex
		DBM:AddMsg("Boss alerts/timers not yet implemented for Researcher Ven'kex")
	elseif eID == 2992 then--Researcher Xik'vik
		timerVoidRendCD:Start(6.2)
		timerEncasingWebshotCD:Start(12.2)
	elseif eID == 2993 then--Crazed Abomination
		DBM:AddMsg("Boss alerts/timers not yet implemented for Crazed Abomination")
	elseif eID == 3106 then--Torque Clanfire and Sprok
		DBM:AddMsg("Boss alerts/timers not yet implemented for Torque Clanfire and Sprok")
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2991 then--Researcher Ven'kex
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	elseif eID == 2992 then--Researcher Xik'vik
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerVoidRendCD:Stop()
			timerEncasingWebshotCD:Stop()
		end
	elseif eID == 2993 then--Crazed Abomination
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	elseif eID == 3106 then--Torque Clanfire and Sprok
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	end
end
