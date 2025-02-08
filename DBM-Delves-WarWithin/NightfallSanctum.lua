local mod	= DBM:NewMod("z2686", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2686)

mod:RegisterCombat("scenario", 2686)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 443840 443908 443837 444408 443482 458874",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

--NOTE: This one lacks encounter ID for easy win detection and boss timers
--"Blessing of Dusk-443482-npc:229855-000036A342 = pull:17.0, 29.0, 28.1",
--"Blessing of Dusk-443482-npc:230904-000036A342 = pull:10.8, 30.3",
--NOTE: Shadow Wave is a shared ability with Xanventh in Skittering Breach, but so far not shared by any trash so duplicated instead of trash mod
local warnFire								= mod:NewSpellAnnounce(443908, 2)--Speaker Halven

local specWarnDesolateSurge					= mod:NewSpecialWarningDodge(443840, nil, nil, nil, 2, 2)--Speaker Halven
local specWarnShadowSweep					= mod:NewSpecialWarningDodge(443837, nil, nil, nil, 2, 15)--Speaker Halven
local specWarnSpeakersWrath					= mod:NewSpecialWarningDodge(444408, nil, nil, nil, 2, 2)--Speaker Davenruth
local specWarnShadowWave					= mod:NewSpecialWarningDodge(458874, nil, nil, nil, 2, 15)

--local timerShadowsofStrifeCD				= mod:NewCDNPTimer(12.4, 449318, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerDesolateSurgeCD					= mod:NewCDTimer(26.7, 443840, nil, nil, nil, 3)--Speaker Halven
local timerFireCD							= mod:NewCDTimer(12.1, 443908, nil, nil, nil, 3)--Speaker Halven
local timerShadowSweepCD					= mod:NewCDTimer(12.1, 443837, nil, nil, nil, 3)--Speaker Halven and Speaker Davenruth (need more data on Davenruth's timer)
local timerSpeakersWrathCD					= mod:NewAITimer(12.1, 444408, nil, nil, nil, 3)--Speaker Davenruth
local timerShadowWaveCD						= mod:NewCDNPTimer(12, 458874, nil, nil, nil, 5)

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
		--"Shadow Sweep-443837-npc:218022-00003A6A23 = pull:3.7, 9.7, 10.9, 7.3",
		specWarnShadowSweep:Show()
		specWarnShadowSweep:Play("frontal")
		if args:GetSrcCreatureID() == 217570 then
			timerShadowSweepCD:Start(12.1) --correctly
		else
			timerShadowSweepCD:Start(7.3)
		end
	elseif args.spellId == 444408 then
		specWarnSpeakersWrath:Show()
		specWarnSpeakersWrath:Play("watchstep")
		timerSpeakersWrathCD:Start()
	elseif args.spellId == 458874 then
		--"Shadow Wave-458874-npc:229855-000036A342 = pull:10.3, 12.5, 12.1, 14.6, 12.5",
		--"Shadow Wave-458874-npc:230904-000036A342 = pull:14.5, 12.0, 18.2, 12.1, 12.1",
		specWarnShadowWave:Show()
		specWarnShadowWave:Play("frontal")
		timerShadowWaveCD:Start(nil, args.sourceGUID)
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
	if args.spellId == 470592 or args.spellId == 443482 then

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

function mod:UNIT_DIED(args)
	--if args.destGUID == UnitGUID("player") then--Solo scenario, a player death is a wipe

	--end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 229855 or cid == 230904 then
		timerShadowWaveCD:Stop(args.destGUID)
	end
end

function mod:ENCOUNTER_START(eID)
	if eID == 2998 then--Reformed Fury (Speaker Davenruth)
		timerShadowSweepCD:Start(3.6)
		timerSpeakersWrathCD:Start(1)--12.1
	elseif eID == 3007 then--Speaker Halven
		timerShadowSweepCD:Start(5.7)
		timerFireCD:Start(8.8)
		timerDesolateSurgeCD:Start(20.3)
	elseif eID == 3008 then--Speaker Pelzeth
		DBM:AddMsg("Boss alerts/timers not yet implemented for Speaker Pelzeth")
--	elseif eID == 3050 then--Cult Leaders

	elseif eID == 3147 then--Speaker Wicke
		DBM:AddMsg("Boss alerts/timers not yet implemented for Speaker Wicke")
	end
end


function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2998 then--Reformed Fury (Speaker Davenruth)
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerShadowSweepCD:Stop()
			timerSpeakersWrathCD:Stop()
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
	elseif eID == 3050 then--Cult Leaders
		if success == 1 then
			DBM:EndCombat(self)
--		else
			--Stop Timers manually
		end
	elseif eID == 3147 then--Speaker Wicke
		if success == 1 then
			DBM:EndCombat(self)
--		else
			--Stop Timers manually
		end
	end
end

