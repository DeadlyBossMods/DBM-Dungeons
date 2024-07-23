local mod	= DBM:NewMod("z2686", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)

mod:RegisterCombat("scenario", 2686)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 443840 443908 443837",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

--NOTE: This one lacks encounter ID for easy win detection and boss timers
local warnFire								= mod:NewSpellAnnounce(443908, 2)

local specWarnDesolateSurge					= mod:NewSpecialWarningDodge(443840, nil, nil, nil, 2, 2)
local specWarnShadowSweep					= mod:NewSpecialWarningDodge(443837, nil, nil, nil, 2, 2)

--local timerShadowsofStrifeCD				= mod:NewCDNPTimer(12.4, 449318, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDesolateSurgeCD					= mod:NewCDTimer(27.9, 443840, nil, nil, nil, 3)
local timerFireCD							= mod:NewCDTimer(12.1, 443908, nil, nil, nil, 3)
local timerShadowSweepCD					= mod:NewCDTimer(13.4, 443837, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 443840 then
		--"Desolate Surge-443840-npc:217570-00001EAF20 = pull:20.3, 27.9, 29.1, 27.9, 29.1, 27.9, 28.0",
		specWarnDesolateSurge:Show()
		specWarnDesolateSurge:Play("watchstep")
		timerDesolateSurgeCD:Start()
	elseif args.spellId == 443908 then
		--"Fire!-443908-npc:217570-00001EAF20 = pull:9.3, 15.8, 12.2, 15.8, 12.2, 17.0, 12.1, 15.8, 12.1, 17.0, 12.2, 15.8, 12.2, 15.8",
		warnFire:Show()
		timerFireCD:Start()
	elseif args.spellId == 443837 then
		--"Shadow Sweep-443837-npc:217570-00001EAF20 = pull:5.7, 24.3, 14.6, 14.6, 14.6, 14.6, 13.4, 14.5, 14.6, 14.6, 13.4, 13.4, 14.6, 13.4",
		specWarnShadowSweep:Show()
		specWarnShadowSweep:Play("shockwave")
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 138680 then

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

function mod:ENCOUNTER_START(eID)
	if eID == 2998 then--Reformed Fury
		DBM:AddMsg("Boss alerts/timers not yet implemented for Reformed Fury")
	elseif eID == 3007 then--Speaker Halven
		timerShadowSweepCD:Start(5.7)
		timerFireCD:Start(9.3)
		timerDesolateSurgeCD:Start(20.3)
	elseif eID == 3008 then--Speaker Pelzeth
		DBM:AddMsg("Boss alerts/timers not yet implemented for Speaker Pelzeth")
	end
end


function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2998 then--Reformed Fury
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	elseif eID == 3007 then--Speaker Halven
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerDesolateSurgeCD:Stop()
			timerFireCD:Stop()
			timerShadowSweepCD:Stop()
		end
	elseif eID == 3008 then--Speaker Pelzeth
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	end
end

