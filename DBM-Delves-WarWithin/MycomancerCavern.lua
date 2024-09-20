local mod	= DBM:NewMod("z2679", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)

mod:RegisterCombat("scenario", 2679)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 454213 449965 453897",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

local warnSporesong							= mod:NewCastAnnounce(453897, 2)
local warnSwampBolt							= mod:NewSpellAnnounce(449965, 2)

local specWarnMuckCharge					= mod:NewSpecialWarningDodge(454213, nil, nil, nil, 2, 2)

local timerMuckChargeCD						= mod:NewCDTimer(25.5, 454213, nil, nil, nil, 3)
local timerSporesongCD						= mod:NewCDTimer(25.5, 453897, nil, nil, nil, 3)
local timerSwampBoltCD						= mod:NewCDTimer(27.9, 449965, nil, nil, nil, 5)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 454213 then
		--"Muck Charge-454213-npc:220314-0000497D69 = pull:5.8, 25.5, 25.5, 25.5, 27.9, 29.1",
		specWarnMuckCharge:Show()
		specWarnMuckCharge:Play("chargemove")
		timerMuckChargeCD:Start()

	elseif args.spellId == 449965 then
		--"Swamp Bolt-449965-npc:220314-0000497D69 = pull:10.6, 27.9, 27.9, 27.9, 27.9, 27.9",
		warnSwampBolt:Show()
		timerSwampBoltCD:Start()
	elseif args.spellId == 453897 then
		--"Sporesong-453897-npc:220314-0000497D69 = pull:15.5, 29.1, 29.1, 29.1, 29.1, 29.1",
		warnSporesong:Show()
		timerSporesongCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 453897 then
		--"Sporesong-453897-npc:220314-0000497D69 = pull:15.5, 29.1, 29.1, 29.1, 29.1, 29.1",
		warnSporesong:Show()
		timerSporesongCD:Start()
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
	if eID == 2960 then--Bogpiper
		--Start some timers
		timerMuckChargeCD:Start(5.8)
		timerSwampBoltCD:Start(10.6)
		timerSporesongCD:Start(15.5)
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2960 then--Bogpiper
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerMuckChargeCD:Stop()
			timerSwampBoltCD:Stop()
			timerSporesongCD:Stop()
		end
	end
end
