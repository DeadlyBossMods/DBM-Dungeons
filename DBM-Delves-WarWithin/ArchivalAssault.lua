local mod	= DBM:NewMod("z2803", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2803)

mod:RegisterCombat("scenario", 2803)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1242142 1241991 1241753 1239350 1239445 1239427 1239134 1238919",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 1239427",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

local warnImplosion						= mod:NewSpellAnnounce(1242142, 2)
local warnKareshiTimebomb				= mod:NewSpellAnnounce(1241991, 2)
local warnPortalInfusion				= mod:NewSpellAnnounce(1241753, 2)
local warnAllHands						= mod:NewSpellAnnounce(1239350, 2)
local warnBroadside						= mod:NewSpellAnnounce(1239445, 2)
local warnScuttleThatOne				= mod:NewTargetNoFilterAnnounce(1239427, 2)
local warnCosmicTranquilization			= mod:NewSpellAnnounce(1239134, 2)
local warnVoidEmpowerment				= mod:NewSpellAnnounce(1238919, 2)

local timerImplosionCD					= mod:NewCDTimer(35, 1242142, nil, nil, nil, 3)
local timerKareshiTimebombCD			= mod:NewCDTimer(35, 1241991, nil, nil, nil, 3)
local timerPortalInfusionCD				= mod:NewCDTimer(35, 1241753, nil, nil, nil, 5)
local timerAllHandsCD					= mod:NewCDTimer(31.4, 1239350, nil, nil, nil, 1)--Needs more data
local timerBroadsideCD					= mod:NewCDTimer(32.6, 1239445, nil, nil, nil, 3)--Needs more data
local timerScuttleThatOneCD				= mod:NewCDTimer(30.2, 1239427, nil, nil, nil, 3)--Needs more data
local timerCosmicTranquilizationCD		= mod:NewCDTimer(17.5, 1239134, nil, nil, nil, 3)--Needs more data
--local timerVoidEmpowermentCD			= mod:NewCDTimer(20.5, 1238919, nil, nil, nil, 5)--Needs more data


--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 1242142 then
		warnImplosion:Show()
		timerImplosionCD:Start()
	elseif args.spellId == 1241991 then
		warnKareshiTimebomb:Show()
		timerKareshiTimebombCD:Start()
	elseif args.spellId == 1241753 then
		warnPortalInfusion:Show()
		timerPortalInfusionCD:Start()
	elseif args.spellId == 1239350 then
		warnAllHands:Show()
		timerAllHandsCD:Start()
	elseif args.spellId == 1239445 then
		warnBroadside:Show()
		timerBroadsideCD:Start()
	elseif args.spellId == 1239427 then
		timerScuttleThatOneCD:Start()
	elseif args.spellId == 1239134 then
		warnCosmicTranquilization:Show()
		timerCosmicTranquilizationCD:Start()
	elseif args.spellId == 1238919 then
		warnVoidEmpowerment:Show()
--		timerVoidEmpowermentCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 447143 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 1239427 then
		warnScuttleThatOne:Show(args.destName)
	end
end

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
	if eID == 3279 then--Captain Nil'hitan
		timerAllHandsCD:Start(10.9)
		timerScuttleThatOneCD:Start(20.5)
		timerBroadsideCD:Start(30.3)
	elseif eID == 3329 then--Portalmaster Halsan
		timerPortalInfusionCD:Start(3.4)
		timerKareshiTimebombCD:Start(19.2)
		timerImplosionCD:Start(30.2)
--	elseif eID == 3330 then--Voidrider Challnax
		--Something is iffy about these so commenting out for now
--		timerCosmicTranquilizationCD:Start(32.7)
--		timerVoidEmpowermentCD:Start(35.1)
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 3279 then--Captain Nil'hitan
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerAllHandsCD:Stop()
			timerBroadsideCD:Stop()
			timerScuttleThatOneCD:Stop()
		end
	elseif eID == 3329 then--Portalmaster Halsan
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerImplosionCD:Stop()
			timerKareshiTimebombCD:Stop()
		end
	elseif eID == 3330 then--Voidrider Challnax
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerCosmicTranquilizationCD:Stop()
			--timerVoidEmpowermentCD:Stop()
		end
	end
end
