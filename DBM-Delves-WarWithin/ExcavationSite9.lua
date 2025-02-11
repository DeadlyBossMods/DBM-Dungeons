if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod("z2815", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2815)

mod:RegisterCombat("scenario", 2815)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1213776 1213700 1213785 1214135 1214504",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 1213838",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

--TODO, possibly improve variance with more data
local warnTearItDown							= mod:NewCastAnnounce(1213785, 2)
local warnGoblinIngenuity						= mod:NewCastAnnounce(1214504, 2)
local warnUnansweredCall						= mod:NewTargetNoFilterAnnounce(1213700, 2)

local specWarnHopelessCurse						= mod:NewSpecialWarningInterrupt(1213776, nil, nil, nil, 1, 2)
local specWarnUnansweredCall					= mod:NewSpecialWarningRun(1213700, nil, nil, nil, 4, 2)
local specWarnMakeItRain						= mod:NewSpecialWarningDodge(1214135, nil, nil, nil, 2, 2)

local timerTearItDownCD							= mod:NewVarTimer("v13.3-20.7", 1213785, nil, nil, nil, 2)
local timerHopelessCurseCD						= mod:NewVarTimer("v18.2-36.5", 454213, nil, nil, nil, 4)
local timerUnansweredCallCD						= mod:NewVarTimer("v35.2-36.5", 1213700, nil, nil, nil, 5)
local timerMakeItRainCD							= mod:NewVarTimer("v13.4-17", 1214135, nil, nil, nil, 3)
local timerGoblinIngenuityCD					= mod:NewVarTimer("v17-19.4", 1214504, nil, nil, nil, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 1213776 then
		--pull:6.0, 23.2, 19.4, 31.6, 36.5, 18.2, 20.7
		specWarnHopelessCurse:Show(args.sourceName)
		specWarnHopelessCurse:Play("kickcast")
		timerHopelessCurseCD:Start()
	elseif args.spellId == 1213700 then
		--pull:30.3, 35.2, 36.5, 35.3
		timerUnansweredCallCD:Start()
	elseif args.spellId == 1213785 then
		--pull:10.8, 13.4, 20.7, 13.3, 26.8, 13.4, 19.5, 13.4, 20.7, 13.3
		warnTearItDown:Show()
		timerTearItDownCD:Start()
	elseif args.spellId == 1214135 then
		--pull:7.3, 17.0, 17.0, 13.4, 14.6, 15.8, 14.6
		specWarnMakeItRain:Show()
		specWarnMakeItRain:Play("watchstep")
		timerMakeItRainCD:Start()
	elseif args.spellId == 1214504 then
		--pull:10.9, 17.0, 19.4, 17.0, 19.4, 19.4
		warnGoblinIngenuity:Show()
		timerGoblinIngenuityCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 453897 then

		warnSporesong:Show()
		timerSporesongCD:Start()
	end
end
--]]


function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 1213838 then
		if args:IsPlayer() then
			specWarnUnansweredCall:Show()
			specWarnUnansweredCall:Play("justrun")
		else
			warnUnansweredCall:Show(args.destName)
		end
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
	if eID == 3095 then--Craggle Fritzbrains
		timerMakeItRainCD:Start(7.3)
		timerGoblinIngenuityCD:Start(10.9)
	elseif eID == 3096 then--Harbinger Ul'thul
		timerHopelessCurseCD:Start(6)
		timerTearItDownCD:Start(10.8)
		timerUnansweredCallCD:Start(30.3)
	elseif eID == 3099 then--Xel'anegh the Many
		DBM:AddMsg("Boss alerts/timers not yet implemented for Xel'anegh the Many")
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 3095 then--Craggle Fritzbrains
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerMakeItRainCD:Stop()
			timerGoblinIngenuityCD:Stop()
		end
	elseif eID == 3096 then--Harbinger Ul'thul
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerHopelessCurseCD:Stop()
			timerTearItDownCD:Stop()
			timerUnansweredCallCD:Stop()
		end
	elseif eID == 3099 then--Xel'anegh the Many
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	end
end
