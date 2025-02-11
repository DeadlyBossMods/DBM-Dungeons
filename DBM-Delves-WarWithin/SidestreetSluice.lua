if DBM:GetTOC() < 110100 then return end
local mod	= DBM:NewMod("z2826", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2826)

mod:RegisterCombat("scenario", 2826)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1215870 1215957 1215905 1215975",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 1215975",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

--local warnSporesong							= mod:NewCastAnnounce(453897, 2)
local warnJuiceItUp								= mod:NewCastAnnounce(1215975, 2)

local specWarnSprocketSmash						= mod:NewSpecialWarningSpell(1215870, nil, nil, nil, 1, 2)
local specWarnTremorClaw						= mod:NewSpecialWarningSpell(1215957, nil, nil, nil, 2, 2)
local specWarnCarnageCannon						= mod:NewSpecialWarningDodge(1215905, nil, nil, nil, 2, 2)
local specWarnJuiceItUpDispel					= mod:NewSpecialWarningDispel(1215975, "RemoveEnrage", nil, nil, 1, 2)

local timerSprocketSmashCD						= mod:NewVarTimer("v10.9-14.5", 1215870, nil, nil, nil, 3)
local timerTremorClawCD							= mod:NewVarTimer("v18.2-20.6", 1215957, nil, nil, nil, 2)
local timerCarnageCannonCD						= mod:NewNextTimer(21.8, 1215905, nil, nil, nil, 3)
local timerJuiceItUpCD							= mod:NewCDTimer(30, 1215975, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 1215870 then
		--19.5, 13.3, 11.0, 14.5, 12.2, 10.8, 10.9, 12.2
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnSprocketSmash:Show()
			specWarnSprocketSmash:Play("carefly")
		end
		timerSprocketSmashCD:Start()
	elseif args.spellId == 1215957 then
		--7.0, 18.2, 18.2, 20.6, 18.2
		specWarnTremorClaw:Show()
		specWarnTremorClaw:Play("carefly")
		timerTremorClawCD:Start()
	elseif args.spellId == 1215905 then
		--pull:13.0, 21.9, 21.9, 21.8
		specWarnCarnageCannon:Show()
		specWarnCarnageCannon:Play("watchstep")
		timerCarnageCannonCD:Start()
	elseif args.spellId == 1215975 then
		--pull:19.1, 41.3
		warnJuiceItUp:Show()
		timerJuiceItUpCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 453897 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 1215975 then
		specWarnJuiceItUpDispel:Show(args.destName)
		specWarnJuiceItUpDispel:Play("dispelboss")
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
	if eID == 3104 then--Golden Elemental
		DBM:AddMsg("Boss alerts/timers not yet implemented for Golden Elemental")
	elseif eID == 3173 then--Vindle Snapcrank
		timerSprocketSmashCD:Start(19.5)
	elseif eID == 3174 then--Geargrave
		timerTremorClawCD:Start(7)
		timerCarnageCannonCD:Start(13)
		timerJuiceItUpCD:Start(19.1)
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 3104 then--Golden Elemental
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	elseif eID == 3173 then--Vindle Snapcrank
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerSprocketSmashCD:Stop()
		end
	elseif eID == 3174 then--Geargrave
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerTremorClawCD:Stop()
			timerCarnageCannonCD:Stop()
			timerJuiceItUpCD:Stop()
		end
	end
end
