if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("OperaOfMalediction", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3144, 3168, 3169)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_SPELLCAST_SUCCEEDED"
)

-- A different boss every day

-- Trizivast
-- The boss itself didn't really do anything, tank & spank, didn't even notice that that was already the boss.
-- Pull timer:
-- "<515.62 16:50:03> [CHAT_MSG_MONSTER_YELL] Good evening ladies and gentlemen! Welcome to tonights presentation!#Edgar###Onlyveins##0#0##0#4823#nil#0#false#false#false#false",
-- "<528.58 16:50:16> [CHAT_MSG_MONSTER_YELL] For your evenings entertainment, comes a brave tale of survival, loss, and conviction.#Edgar###Onlyveins##0#0##0#4833#nil#0#false#false#false#false",
-- "<535.07 16:50:23> [CHAT_MSG_MONSTER_YELL] Our woodland creatures find themselves constantly assailed by a vicious quilboar, Trizivast! This barbaric beast will stop at nothing to rid his realm of these small wolves.\13\ (\13 == \r, kek)
-- "<545.95 16:50:34> [ENCOUNTER_START] 3144#Opera of Malediction#1#5",
-- "<545.95 16:50:34> [CLEU] SPELL_DAMAGE#Player-5827-02484403#Ðjs#Creature-0-5209-2875-4757-238428-00001A4E3B#Trizivast#29228#Flame Shock",

-- Hänsel and Gretel
-- Two bosses that didn't really do anything, tank and spank.
-- "<7.72 20:22:17> [CHAT_MSG_MONSTER_YELL] Good evening ladies and gentlemen! Welcome to tonights presentation!#Edgar###Tandanu##0#0##0#2480#nil#0#false#false#false#false",
-- "<20.73 20:22:30> [CHAT_MSG_MONSTER_YELL] For your evenings entertainment, comes the lost fable of two children attempting to find their way!#Edgar###Tandanu##0#0##0#2489#nil#0#false#false#false#false",
-- "<60.10 20:23:09> [CLEU] SPELL_DAMAGE#Player-5827-01CD3776#Xiga#Creature-0-5252-2875-24589-238424-00001BD175#Grandma Finette#424919#Main Gauche",
-- This is not yet the actual boss, encounter doesn't start yet. Bring that mob down to ~20% to trigger fight.
-- "<64.21 20:23:13> [UNIT_SPELLCAST_SUCCEEDED] Grandma Finette(18.9%-0.0%){Target:Xiga} -Transformation- [[target:Cast-3-5252-2875-24589-1222280-00089BD1A0:1222280]]",
-- "<65.69 20:23:14> [CHAT_MSG_MONSTER_YELL] We're sorry grandmother. Your time has expired.#Hans###Hunterlogic##0#0##0#2519#nil#0#false#false#false#false",
-- "<65.69 20:23:14> [CHAT_MSG_MONSTER_YELL] We're sorry grandmother. Your time has expired.#Greta###Hunterlogic##0#0##0#2520#nil#0#false#false#false#false",
-- "<76.80 20:23:26> [ENCOUNTER_START] 3168#Opera of Malediction#1#5",
-- "<78.49 20:23:27> [NAME_PLATE_UNIT_ADDED] Greta#Creature-0-5252-2875-24589-238423-00001BD175",


local timerCombatStart = mod:NewCombatTimer(10)

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:match(L.PullTrizivast) then
		timerCombatStart:Start(17.37)
	elseif msg:match(L.PullHanselAndGretel1) then
		timerCombatStart:Start(39.37)
	elseif msg:match(L.PullHanselAndGretel2) then
		if not timerCombatStart:IsStarted() then
			timerCombatStart:Start(12.8)
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 1222280 then
		timerCombatStart:Start(14.28)
	end
end
