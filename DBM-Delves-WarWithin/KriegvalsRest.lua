local mod	= DBM:NewMod("z2681", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2681)

mod:RegisterCombat("scenario", 2681)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 449242 449295 449339",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 449339",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

local warnGroundSlam						= mod:NewCastAnnounce(449295, 3)

local specWarnFlamestorm					= mod:NewSpecialWarningDodge(449242, nil, nil, nil, 2, 2)
local specWarnRagingTantrum					= mod:NewSpecialWarningSpell(449339, nil, nil, nil, 2, 2)
local specWarnRagingTantrumDispel			= mod:NewSpecialWarningDispel(449339, "RemoveEnrage", nil, nil, 1, 2)

local timerFlamestormCD						= mod:NewCDTimer(17, 449242, nil, nil, nil, 3)
local timerGroundSlamCD						= mod:NewCDTimer(27.9, 449295, nil, nil, nil, 3)
local timerRagingTantrumCD					= mod:NewCDTimer(31.6, 449339, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 449242 then
		specWarnFlamestorm:Show()
		specWarnFlamestorm:Play("watchstep")
		timerFlamestormCD:Start()
	elseif args.spellId == 449295 then
		warnGroundSlam:Show()
		timerGroundSlamCD:Start()
	elseif args.spellId == 449339 then
		specWarnRagingTantrum:Show()
		specWarnRagingTantrum:Play("carefly")
		timerRagingTantrumCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 138680 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 449339 then
		specWarnRagingTantrumDispel:Show(args.destName)
		specWarnRagingTantrumDispel:Play("enrage")
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
	if eID == 2878 then--Tomb-Raider Drywhisker
		--6.1, 19.1, 18.5, 18.2, 19.9
		timerFlamestormCD:Start(6.1)
		--18.2, 29.1, 27.9
		timerGroundSlamCD:Start(18.2)
		--30.4, 35.1
		timerRagingTantrumCD:Start(30.3)
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2878 then--Tomb-Raider Drywhisker
		if success == 1 then
			DBM:EndCombat(self)
		else
			timerFlamestormCD:Stop()
			timerGroundSlamCD:Stop()
			timerRagingTantrumCD:Stop()
		end
	end
end
