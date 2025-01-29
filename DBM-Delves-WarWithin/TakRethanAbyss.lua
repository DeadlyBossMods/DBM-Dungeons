local mod	= DBM:NewMod("z2689", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2689, 2768)

mod:RegisterCombat("scenario", 2689, 2768)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 446300 446230",
	"SPELL_CAST_SUCCESS 446405",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

--local warnDrones							= mod:NewSpellAnnounce(449072, 2)

local specWarnDeepseaPolyps					= mod:NewSpecialWarningDodge(446300, nil, nil, nil, 2, 2)
local specWarnRepellingBlast				= mod:NewSpecialWarningRun(446230, nil, nil, nil, 4, 2)
local specWarnFungalInfection				= mod:NewSpecialWarningDodge(446405, nil, nil, nil, 2, 15)

local timerDeepseaPolypsCD					= mod:NewCDTimer(17, 446300, nil, nil, nil, 3)
local timerRepellingBlastCD					= mod:NewCDTimer(20.7, 446230, nil, nil, nil, 3)
local timerFungalInfectionCD				= mod:NewCDTimer(20.7, 446405, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 446300 then
		specWarnDeepseaPolyps:Show()
		specWarnDeepseaPolyps:Play("watchstep")
		timerDeepseaPolypsCD:Start()
	elseif args.spellId == 446230 then
		specWarnRepellingBlast:Show()
		specWarnRepellingBlast:Play("justrun")
		timerRepellingBlastCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 446405 then
		specWarnFungalInfection:Show()
		specWarnFungalInfection:Play("frontal")
		timerFungalInfectionCD:Start()
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
	if eID == 2895 then--Undersea Abomination
		--"Deepsea Polyps-446300-npc:214348-00001E9222 = pull:11.6, 23.1, 20.7, 21.9, 23.1, 21.9, 21.9",
		--"Repelling Blast-446230-npc:214348-00001E9222 = pull:22.5, 42.5, 23.1, 21.9, 21.9",
		--"Fungal Infection-446405-npc:214348-00001E9222 = pull:4.3, 23.1, 20.7, 21.9, 23.1, 21.9, 21.9", (success)
		timerDeepseaPolypsCD:Start(11.6)
		timerRepellingBlastCD:Start(21.5)
		timerFungalInfectionCD:Start(4.3)
	elseif eID == 3004 then--Evolved Nerubian Leaders
		DBM:AddMsg("Boss alerts/timers not yet implemented for Evolved Nerubian Leaders")
	elseif eID == 3124 then--Vindle Snapcrank
		DBM:AddMsg("Boss alerts/timers not yet implemented for Vindle Snapcrank")
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2895 then--Undersea Abomination
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerDeepseaPolypsCD:Stop()
			timerRepellingBlastCD:Stop()
			timerFungalInfectionCD:Stop()
		end
	elseif eID == 3004 then--Evolved Nerubian Leaders
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	end
end
