local mod	= DBM:NewMod("z2688", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)

mod:RegisterCombat("scenario", 2688)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 449072 448644 449038 448663",
	--"SPELL_CAST_SUCCESS",
	--"SPELL_AURA_APPLIED",
	--"SPELL_AURA_REMOVED",
	--"SPELL_PERIODIC_DAMAGE",
	"ENCOUNTER_START",
	"ENCOUNTER_END",
	"UNIT_DIED"
)

local warnDrones							= mod:NewSpellAnnounce(449072, 2)

local specWarnBurrowingTremors				= mod:NewSpecialWarningRun(448644, nil, nil, nil, 4, 2)--Boss
local specWarnImpalingStrikes				= mod:NewSpecialWarningDodge(449038, nil, nil, nil, 2, 2)--Boss
local specWarnStingingSwarm					= mod:NewSpecialWarningSpell(448663, nil, nil, nil, 2, 2)--Puppetmaster

local timerBurrowingTremorsCD				= mod:NewCDTimer(31.5, 448644, nil, nil, nil, 5)
local timerCallDronesCD						= mod:NewCDTimer(31.5, 449072, nil, nil, nil, 1)
local timerImpalingStrikesCD				= mod:NewCDTimer(31.5, 449038, nil, nil, nil, 3)
local timerStingingSwarmCD					= mod:NewCDTimer(30, 448663, nil, nil, nil, 3)--Puppetmaster

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

mod.vb.impalingCount = 0

function mod:SPELL_CAST_START(args)
	if args.spellId == 449072 then
		--"Burrowing Tremors-448644-npc:220437-00001EA118 = pull:12.3, 32.4, 31.6, 31.6, 31.6",
		warnDrones:Show()
		timerCallDronesCD:Start()
	elseif args.spellId == 448644 then
		--"Call Drones-449072-npc:220437-00001EA118 = pull:22.8, 38.9, 31.6, 31.6, 31.6",
		specWarnBurrowingTremors:Show()
		specWarnBurrowingTremors:Play("justrun")
		specWarnBurrowingTremors:ScheduleVoice(1.5, "keepmove")
		timerBurrowingTremorsCD:Start()
	elseif args.spellId == 449038 then
		--6.2, 21.5, 28.0, 31.6, 31.6, 31.6
		self.vb.impalingCount = self.vb.impalingCount + 1
		specWarnImpalingStrikes:Show()
		specWarnImpalingStrikes:Play("watchstep")
		if self.vb.impalingCount < 3 then
			timerImpalingStrikesCD:Start(21.5)
		else
			timerImpalingStrikesCD:Start(31.5)
		end
	elseif args.spellId == 448663 then
		specWarnStingingSwarm:Show()
		specWarnStingingSwarm:Play("aesoon")
		timerStingingSwarmCD:Start()
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

function mod:ENCOUNTER_START(eID)
	if eID == 2990 then--Overseer Kaskel
		self.vb.impalingCount = 0
		timerImpalingStrikesCD:Start(6.2)
		timerBurrowingTremorsCD:Start(12.3)
		timerCallDronesCD:Start(22.8)
	elseif eID == 3006 then--The Puppetmaster
		timerStingingSwarmCD:Start(12.2)
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2990 then--Overseer Kaskel
		if success == 1 then
			DBM:EndCombat(self)
		else
			timerImpalingStrikesCD:Stop()
			timerBurrowingTremorsCD:Stop()
			timerCallDronesCD:Stop()
		end
	elseif eID == 3006 then--The Puppetmaster
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerStingingSwarmCD:Stop()
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 220510 then--One of Puppetmasters
		timerStingingSwarmCD:Stop()
	end
end
