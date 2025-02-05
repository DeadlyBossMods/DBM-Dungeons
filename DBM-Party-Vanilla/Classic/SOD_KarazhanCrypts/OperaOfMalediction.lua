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
-- "<966.55 20:17:01> [CHAT_MSG_MONSTER_YELL] For your evenings entertainment, comes a brave tale of survival, loss, and conviction.#Edgar###Charlescoins##0#0##0#2061#nil#0#false#false#false#false",
-- "<972.99 20:17:08> [CHAT_MSG_MONSTER_YELL] Our woodland creatures find themselves constantly assailed by a vicious quilboar, Trizivast!
-- "<981.86 20:17:17> [DBM_Debug] ENCOUNTER_START event fired: 3144 Opera of Malediction 1 5#nil",
-- "<981.87 20:17:17> [CLEU] SPELL_DAMAGE#Player-5827-01DA4D4D#Khalkotaurus#Creature-0-5251-2875-26526-238428-00002267B0#Trizivast#29228#Flame Shock",


-- Hänsel and Gretel
-- Two bosses that didn't really do anything, tank and spank.
-- "<353.53 10:26:06> [CHAT_MSG_MONSTER_YELL] For your evenings entertainment, comes the lost fable of two children attempting to find their way!#Edgar###Gufhajs##0#0##0#755#nil#0#false#false#false#false",
-- "<384.43 10:26:37> [CLEU] SWING_MISSED#Creature-0-5252-2875-2792-238424-00001F3A30#Grandma Finette#Player-5827-026569E3#Gufhajs#MISS#false#nil#nil#nil#nil#nil#nil",
-- "<384.43 10:26:37> [NAME_PLATE_UNIT_ADDED] Grandma Finette#Creature-0-5252-2875-2792-238424-00001F3A30",
-- This is not yet the actual boss, encounter doesn't start yet. Bring that mob down to ~20% to trigger fight.
-- "<392.03 10:26:45> [UNIT_SPELLCAST_SUCCEEDED] Grandma Finette(9.2%-0.0%){Target:Gufhajs} -Transformation- [[nameplate1:Cast-3-5252-2875-2792-1222280-00029F3A54:1222280]]",
-- "<394.38 10:26:47> [CHAT_MSG_MONSTER_YELL] We're sorry grandmother. Your time has expired.#Hans###Shabah##0#0##0#767#nil#0#false#false#false#false",
-- "<394.38 10:26:47> [CHAT_MSG_MONSTER_YELL] We're sorry grandmother. Your time has expired.#Greta###Shabah##0#0##0#768#nil#0#false#false#false#false",
-- "<405.48 10:26:58> [ENCOUNTER_START] 3168#Opera of Malediction#1#5",
-- "<405.48 10:26:58> [CLEU] SWING_DAMAGE#Creature-0-5252-2875-2792-238422-00001F3A30#Hans#Player-5827-026569E3#Gufhajs#902#-1#nil#nil#false#false#nil#nil",
-- "<405.48 10:26:58> [IsEncounterInProgress()] true",
-- "<405.48 10:26:58> [NAME_PLATE_UNIT_ADDED] Hans#Creature-0-5252-2875-2792-238422-00001F3A30",

-- Engineers
-- Lots of goblins, the only notable ability was War Stomp, one of them charging into us and stunning us all, annoying, but timer looks very random:
-- "War Stomp-27758-npc:238419-00001D1EBD = pull:13.3, 37.3, 14.8, 22.4, 24.3, 17.8, 22.7",
-- Combat start:
-- "<29.04 20:03:03> [CHAT_MSG_MONSTER_YELL] For your evening viewing we have a tragic story of a humble technician who has been outcast!#Edgar###Assassyn##0#0##0#2363#nil#0#false#false#false#false",
-- "<59.94 20:03:34> [ENCOUNTER_START] 3169#Opera of Malediction#1#5",
-- "<59.95 20:03:34> [CLEU] SWING_MISSED#Vehicle-0-5209-2875-6705-238417-00001D1E64#Beengis#Player-5827-0270D5C9#Assassyn#PARRY#false#nil#nil#nil#nil#nil#nil",



local timerCombatStart = mod:NewCombatTimer(10)

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:match(L.PullTrizivast) then
		timerCombatStart:Start(15.31)
	elseif msg:match(L.PullHanselAndGretel1) then
		timerCombatStart:Start(30.9)
	elseif msg:match(L.PullHanselAndGretel2) then
		if not timerCombatStart:IsStarted() then
			timerCombatStart:Start(11.1)
		else
			timerCombatStart:Update(2.35, 13.45)
		end
	elseif msg:match(L.PullEngineers) then
		timerCombatStart:Start(30.9)
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellId)
	if spellId == 1222280 then
		timerCombatStart:Start(13.45)
	end
end
