if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("HarbingerOfSin", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3141)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 1219420 1219387"
)

-- Pull of the damned --> run out until he casts inferno
-- "<132.78 17:03:34> [CLEU] SPELL_CAST_START#Creature-0-5209-2875-4757-237964-00001A506F#Harbinger of Sin##nil#1219420#Pull of the damned#nil#nil#nil#nil#nil#nil",
-- "<135.78 17:03:37> [CLEU] SPELL_CAST_SUCCESS#Creature-0-5209-2875-4757-237964-00001A506F#Harbinger of Sin##nil#1219420#Pull of the damned#nil#nil#nil#nil#nil#nil",
-- "<145.79 17:03:47> [CLEU] SPELL_CAST_START#Creature-0-5209-2875-4757-237964-00001A506F#Harbinger of Sin##nil#1220927#Inferno#nil#nil#nil#nil#nil#nil",
-- "<150.99 17:03:52> [CLEU] SPELL_CAST_SUCCESS#Creature-0-5209-2875-4757-237964-00001A506F#Harbinger of Sin##nil#1220927#Inferno#nil#nil#nil#nil#nil#nil",
--"Pull of the damned-1219420-npc:237964-00001A506F = pull:33.5, 45.7, 48.6, 45.0, 45.7",
--"Pull of the damned-1219420-npc:237964-00001F341A = pull:33.4, 43.7, 45.7",
--"Pull of the damned-1219420-npc:237964-00001E0279 = pull:33.6, 47.0, 43.7",

local enrageTimer	= mod:NewBerserkTimer(300)
local timerInfero	= mod:NewCastTimer(18.2, 1220927)
local timerPull		= mod:NewVarTimer("v43.7-48.6", 1219420)

local specWarnPull	= mod:NewSpecialWarningSoon(1219420, nil, nil, nil, 4, 2)

-- Flame thingy to dodge, generic "soon" announce because the actual damaging spell triggers way after the cast of this is done
local warnFlameWhirl = mod:NewSoonAnnounce(1219387, nil, nil, "Healer|Tank", 2)

function mod:OnCombatStart(delay)
	enrageTimer:Start(-delay)
	timerPull:Start(33.5 - delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(1219420) then -- 3 sec cast
		timerInfero:Start()
		specWarnPull:Show()
		specWarnPull:ScheduleVoiceOverLap(2, "justrun")
		specWarnPull:ScheduleVoiceOverLap(18, "safenow") -- 200ms before it's actually safe, it's fine, it's fine with the time to play audio/start walking
		-- update timer to exactly 3 sec remaining, a bit ugly with var timers?
		local _, pullTimerTotal = timerPull:GetTime()
		if not pullTimerTotal or pullTimerTotal == 0 then
			pullTimerTotal = 45
		end
		DBM:Debug("Before cancel: " .. tostring(timerPull:GetRemaining()))
		timerPull:Cancel()
		DBM:Debug("After cancel: " .. tostring(timerPull:GetRemaining()))
		timerPull:Update(pullTimerTotal - 3, pullTimerTotal)
		timerPull:DelayedStart(3)
	elseif args:IsSpell(1219387) then
		warnFlameWhirl:Show()
	end
end
