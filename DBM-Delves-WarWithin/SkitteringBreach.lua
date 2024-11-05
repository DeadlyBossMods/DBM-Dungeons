local mod	= DBM:NewMod("z2685", "DBM-Delves-WarWithin")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetHotfixNoticeRev(20240422000000)
mod:SetMinSyncRevision(20240422000000)
mod:SetZone(2685)

mod:RegisterCombat("scenario", 2685)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 440806",
--	"SPELL_CAST_SUCCESS",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
--	"SPELL_PERIODIC_DAMAGE",
--	"UNIT_DIED",
	"ENCOUNTER_START",
	"ENCOUNTER_END"
)

--This zone has 4 encounterIDs flagged to it, i'm gonna guess the 3 zones missing one, are mis zone flagged.
local warnDarkAbatement					= mod:NewSpellAnnounce(454762, 2)

local specWarnDarkriftSmash				= mod:NewSpecialWarningDodge(440806, nil, nil, nil, 2, 2)

local timerDarkAbatementCD				= mod:NewCDTimer(20, 454762, nil, nil, nil, 1, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerDarkriftSmashCD				= mod:NewCDTimer(12.1, 440806, nil, nil, nil, 5)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 misc, 7 off interrupt

function mod:SPELL_CAST_START(args)
	if args.spellId == 440806 then
		--"Darkrift Smash-440806-npc:219676-00001EA30B = pull:8.7, 15.4, 13.4, 13.3, 13.4, 13.4, 13.3, 14.6, 13.3, 14.6, 12.2, 14.5, 14.6, 12.1",
		specWarnDarkriftSmash:Show()
		specWarnDarkriftSmash:Play("watchstep")
		timerDarkriftSmashCD:Start()
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
	if eID == 2946 then--Nerl'athekk the Skulking
		timerDarkAbatementCD:Start(2.2)
		timerDarkriftSmashCD:Start(8.5)
		self:RegisterShortTermEvents(
			"UNIT_SPELLCAST_SUCCEEDED boss1"
		)
	elseif eID == 2947 then--Speaker Xanventh
		DBM:AddMsg("Boss alerts/timers not yet implemented for Speaker Xanventh")
	elseif eID == 2948 then--Cave Giant Boss
		DBM:AddMsg("Boss alerts/timers not yet implemented for Cave Giant Boss")
	elseif eID == 2949 then--Faceless One
		DBM:AddMsg("Boss alerts/timers not yet implemented for Faceless One")
	end
end

function mod:ENCOUNTER_END(eID, _, _, _, success)
	if eID == 2946 then--Nerl'athekk the Skulking
		self:UnregisterShortTermEvents()
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
			timerDarkriftSmashCD:Stop()
			timerDarkAbatementCD:Stop()
		end
	elseif eID == 2947 then--Speaker Xanventh
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	elseif eID == 2948 then--Cave Giant Boss
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	elseif eID == 2949 then--Faceless One
		if success == 1 then
			DBM:EndCombat(self)
		else
			--Stop Timers manually
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 458183 then
		--"Dark Abatement-458183-npc:219676-00001EA30B = pull:2.2, 20.6, 20.0, 20.0, 20.0, 21.2, 20.1, 20.0, 21.3, 26.8",
		--2.4, 20.6, 21.3, 21.2, 21.2, 20.0
		warnDarkAbatement:Show()
		timerDarkAbatementCD:Start()
	end
end
