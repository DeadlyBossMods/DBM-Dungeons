if not DBM:IsSeasonal("SeasonOfDiscovery") then return end
local mod	= DBM:NewMod("OperaOfMalediction", "DBM-Party-Vanilla", 22)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetEncounterID(3144)
--mod:SetCreatureID()
mod:SetZone(2875)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

-- I guess there could be different bosses, let's see
-- 			"<535.07 16:50:23> [CHAT_MSG_MONSTER_YELL] Our woodland creatures find themselves constantly assailed by a vicious quilboar, Trizivast! This barbaric beast will stop at nothing to rid his realm of these small wolves.\13\ (...) (wtf, there's a \r in the message...?)
-- 			"<545.95 16:50:34> [ENCOUNTER_START] 3144#Opera of Malediction#1#5",
-- 			"<545.95 16:50:34> [CLEU] SPELL_DAMAGE#Player-5827-02484403#Ðjs#Creature-0-5209-2875-4757-238428-00001A4E3B#Trizivast#29228#Flame Shock",

-- The boss itself didn't really do anything, tank & spank, didn't even notice that that was already the boss.
local timerCombatStart = mod:NewCombatTimer(10)

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:match(L.PullTrizivast) then
		timerCombatStart:Start()
	end
end
