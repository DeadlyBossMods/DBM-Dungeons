local mod	= DBM:NewMod("z2684", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)

mod:RegisterCombat("scenario", 2684)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 448644 448634 448663",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

local warnStingingSwarm						= mod:NewSpellAnnounce(448663, 2)

local specWarnBurrowingTremors				= mod:NewSpecialWarningDodge(448644, nil, nil, nil, 2, 2)
local specWarnImpale						= mod:NewSpecialWarningDodge(448634, nil, nil, nil, 2, 2)

local timerBurrowingTremorsCD				= mod:NewCDTimer(31.5, 448644, nil, nil, nil, 5)
local timerImpaleCD							= mod:NewCDTimer(14.6, 448634, nil, nil, nil, 3)
local timerStingingSwarmCD					= mod:NewCDTimer(32.8, 448663, nil, nil, nil, 3)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 448644 then
		--12.2, 32.4, 31.6, 31.5, 32.0
		specWarnBurrowingTremors:Show()
		specWarnBurrowingTremors:Play("watchstep")
		timerBurrowingTremorsCD:Start()
	elseif args.spellId == 448634 then
		--6.2, 26.3, 23.1, 14.6, 17.0, 14.6, 17.0, 15.0, 17.0
		specWarnImpale:Show()
		specWarnImpale:Play("watchstep")
		timerImpaleCD:Start()
	elseif args.spellId == 448663 then
		--23.2, 34.8, 32.8, 33.2, 33.6
		warnStingingSwarm:Show()
--		timerStingingSwarmCD:Start()
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
	if eID == 2989 then--Under-Lord Vik'tis
		timerImpaleCD:Start(6.1)
		timerBurrowingTremorsCD:Start(12.1)
		timerStingingSwarmCD:Start(23.2)
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2989 then--Under-Lord Vik'tis
		if success == 1 then
			DBM:EndCombat(self)
		else
			timerBurrowingTremorsCD:Stop()
			timerImpaleCD:Stop()
			timerStingingSwarmCD:Stop()
		end
	end
end
