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

local enrageTimer	= mod:NewBerserkTimer(300)
local infernoTimer	= mod:NewCastTimer(18.2, 1220927)
local pullTimer		= mod:NewVarTimer("v45-48.6", 1219420)

local specWarnInferno = mod:NewSpecialWarningRun(1220927, nil, nil, nil, 4, 2)

-- Flame thingy to dodge, generic "soon" announce because the actual damaging spell triggers way after the cast of this is done
local warnFlameWhirl = mod:NewSoonAnnounce(1219387)

function mod:OnCombatStart(delay)
	enrageTimer:Start()
	pullTimer:Start(33.5) -- TODO: validate this
end

function mod:SPELL_CAST_START(args)
	if args:IsSpell(1219420) then
		infernoTimer:Start()
		specWarnInferno:Show()
		specWarnInferno:Play("justrun")
		specWarnInferno:ScheduleVoice(18.1, "safenow") -- 100ms before it's actually safe, should be fine with time to play the audio
		pullTimer:Start()
	elseif args:IsSpell(1219387) then
		warnFlameWhirl:Show()
	end
end
