local mod	= DBM:NewMod("z2680", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2680)

mod:RegisterCombat("scenario", 2680)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 448443 448444 449568 1217905 1217913",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END",
	"UNIT_SPELLCAST_SUCCEEDED"
)

local warnCurseOfAgony						= mod:NewSpellAnnounce(448443, 2)
local warnRunicShackles						= mod:NewSpellAnnounce(448444, 2)
local warnCallMoleMachine					= mod:NewSpellAnnounce(1217905, 2)

local specWarnBurningCart					= mod:NewSpecialWarningDodge(448412, nil, nil, nil, 2, 2)
local specWarnDarkBurning					= mod:NewSpecialWarningSpell(1217913, nil, nil, nil, 2, 2)

local timerCurseOfAgonyCD					= mod:NewCDTimer(23.2, 448443, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerRunicShacklesCD					= mod:NewCDTimer(32.9, 448444, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerWebBoltCD						= mod:NewCDTimer(6, 449568, nil, false, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerBurningCartCD					= mod:NewCDTimer(35.2, 448412, nil, nil, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)
local timerCallMoleMachineCD				= mod:NewVarTimer("v16.9-19.3", 1217905, nil, nil, nil, 1)
local timerDarkBurningCD					= mod:NewCDTimer(21.7, 1217913, nil, nil, nil, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 448443 then
		--8.1, 24.2, 25.5, 24.3"
		warnCurseOfAgony:Show()
		timerCurseOfAgonyCD:Start()
	elseif args.spellId == 448444 then
		--22.1, 37.2
		--20.6, 37.6, 32.9
		warnRunicShackles:Show()
		timerRunicShacklesCD:Start()
	elseif args.spellId == 449568 then
		timerWebBoltCD:Start()
	elseif args.spellId == 1217905 then
		--"Call Mole Machine-1217905-npc:216863-00005738DD = pull:3.8, 18.1, 16.9, 17.1, 19.3",
		warnCallMoleMachine:Show()
		timerCallMoleMachineCD:Start()
	elseif args.spellId == 1217913 then
		--"Dark Burn-1217913-npc:216863-00005738DD = pull:18.3, 21.9, 21.7, 22.0",
		specWarnDarkBurning:Show()
		specWarnDarkBurning:Play("aesoon")
		timerDarkBurningCD:Start()
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
	if eID == 2877 then--Web General Ab'enar
		--Start some timers
		timerWebBoltCD:Start(2.2)
		timerCurseOfAgonyCD:Start(5.9)
		timerBurningCartCD:Start(12.1)
		timerRunicShacklesCD:Start(20.2)
	elseif eID == 3005 then--Maklin Drillstab
		timerCallMoleMachineCD:Start(3.8)
		timerDarkBurningCD:Start(18.3)
	elseif eID == 3100 then--The Biggest Bug
		DBM:AddMsg("Boss alerts/timers not yet implemented for The Biggest Bug")
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2877 then--Web General Ab'enar
		if success == 1 then
			DBM:EndCombat(self)
		else
			timerWebBoltCD:Stop()
			timerCurseOfAgonyCD:Stop()
			timerBurningCartCD:Stop()
			timerRunicShacklesCD:Stop()
		end
	elseif eID == 3005 then--Maklin Drillstab
		if success == 1 then
			DBM:EndCombat(self)
		else
			timerCallMoleMachineCD:Stop()
			timerDarkBurningCD:Stop()
		end
	elseif eID == 3100 then--The Biggest Bug
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Timers
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 448348 then
		self:SendSync("Cart")
	end
end

function mod:OnSync(msg)
	if msg == "Cart" then
		--12.1, 35.2, 35.3
		specWarnBurningCart:Show()
		specWarnBurningCart:Play("watchstep")
		timerBurningCartCD:Start()
	end
end
