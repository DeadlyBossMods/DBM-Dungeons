local mod	= DBM:NewMod("z2683", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2683)

mod:RegisterCombat("scenario", 2683)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 450142 450128 450330",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

local warnThrowWax							= mod:NewSpellAnnounce(450330, 2)

local specWarnBurnAway						= mod:NewSpecialWarningSpell(450142, nil, nil, nil, 2, 2)
local specWarnNoxiousGas					= mod:NewSpecialWarningDodge(450128, nil, nil, nil, 2, 2)

local timerBurnAwayCD						= mod:NewCDTimer(21.9, 450142, nil, nil, nil, 2)
local timerNoxiousGasCD						= mod:NewCDTimer(14.6, 450128, nil, nil, nil, 3)
local timerThrowWaxCD						= mod:NewCDTimer(14.5, 450330, nil, nil, nil, 1)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 450142 then
		specWarnBurnAway:Show()
		specWarnBurnAway:Play("aesoon")
		--18.2, 21.9, 21.9, 21.9
		timerBurnAwayCD:Start()
	elseif args.spellId == 450128 then
		specWarnNoxiousGas:Show()
		specWarnNoxiousGas:Play("watchstep")
		--3.6, 20.7, 21.9, 21.9, 21.9
		timerNoxiousGasCD:Start()
	elseif args.spellId == 450330 then
		warnThrowWax:Show()
		--7.2, 20.7, 21.9, 21.9, 21.9
		timerThrowWaxCD:Start()
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
	if eID == 2894 then--Waxface
		timerNoxiousGasCD:Start(3.3)
		timerThrowWaxCD:Start(7.0)
		timerBurnAwayCD:Start(18.2)
	elseif eID == 3139 then--Shroomspew
		DBM:AddMsg("Boss alerts/timers not yet implemented for Shroomspew")
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2894 then--Waxface
		if success == 1 then
			DBM:EndCombat(self)
		else
			timerNoxiousGasCD:Stop()
			timerThrowWaxCD:Stop()
			timerBurnAwayCD:Stop()
		end
	elseif eID == 3139 then--Shroomspew
		if success == 1 then
			DBM:EndCombat(self)
		else

		end
	end
end
